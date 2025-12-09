//
//  CameraViewController.swift
//  SnapChatMenu
//
//  Created by NightOwl_Thinker on 2025/12/9.
//

import UIKit
import AVFoundation   // AVFoundation: 提供相机、音视频采集等底层能力

/// 核心相机页面，负责：权限检查、会话配置、拍照和结果预览
/// - 知识点：UIViewController 生命周期、AVCaptureSession、委托模式(AVCapturePhotoCaptureDelegate)
class CameraViewController: UIViewController {
    
    //MARK: - 核心属性
    /// 摄像头会话（Session）：
    /// - 知识点：AVCaptureSession 负责“输入(摄像头) -> 输出(照片/视频)”的数据流管理
    /// - 使用 optional：方便在释放时置为 nil，提前释放硬件资源
    private var captureSession: AVCaptureSession?
    /// 摄像头预览层：
    /// - 知识点：AVCaptureVideoPreviewLayer 是 CALayer 的子类，直接挂在 view.layer 上展示相机画面
    private var previewLayer = AVCaptureVideoPreviewLayer()
    /// 照片输出：
    /// - 知识点：AVCapturePhotoOutput 用于拍摄静态照片，并通过代理返回结果
    private var photoOutput = AVCapturePhotoOutput()
    ///拍照按钮
    private  var captureButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkCameraPermission()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 知识点：viewDidLayoutSubviews 会在布局更新后调用
        // 这里适合根据最终的 view.bounds / safeAreaInsets 去设置子视图/子图层的 frame
        // 优化原因：相机预览层依赖最终尺寸，放这里保证横竖屏/旋转下尺寸都正确
        previewLayer.frame = view.bounds
//        previewLayer.frame = view.safeAreaLayoutGuide.layoutFrame
        
        let buttonSize: CGFloat = 80   // 优化：略微减小按钮，视觉更协调
        captureButton.frame = CGRect(
            x: (view.bounds.width - buttonSize) / 2,
            y: view.bounds.height - buttonSize - view.safeAreaInsets.bottom - 24,
            width: buttonSize,
            height: buttonSize
        )
    }
    
    
    /// 初始化 UI：
    /// - 知识点：纯代码布局 vs Storyboard；这里全部使用代码创建 UI
    private func setupUI(){
        view.backgroundColor = .black
        
        // 1.配置预览层
        // videoGravity:
        // - .resizeAspectFill 会按比例填充整个区域，多余部分裁剪
        // - 适合相机取景效果
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // 2.配置拍摄按钮
        captureButton.setTitle("拍摄", for: .normal)
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.backgroundColor = .red.withAlphaComponent(0.8)
        captureButton.layer.cornerRadius = 40
        captureButton.clipsToBounds = true
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
    }
    
    //MARK: - 权限检查
    /// 检查并请求摄像头权限
    /// - 知识点：AVCaptureDevice.authorizationStatus + requestAccess 的标准用法
    private func checkCameraPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            // 已授权：可以直接初始化相机会话
            setupCameraSession()
        case .notDetermined:
            // 未决定：第一次安装 App 时会走到这里，触发系统弹窗
            AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
                // 知识点：权限回调在后台线程，UI 更新需要切回主线程
                DispatchQueue.main.async {
                    if isAuthorized{
                        self?.setupCameraSession()
                    }else{
                        self?.showPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
            
            
        @unknown default:
            break
        }
    }
    
    /// 创建并配置相机会话
    /// - 知识点：targetEnvironment(simulator) 条件编译，避免在模拟器上触发相机相关崩溃
    private func setupCameraSession(){
        // 模拟器直接提示退出
#if targetEnvironment(simulator)
        showSimulatorAlert()
        return
#endif
        
        // 1.初始化会话
        let session = AVCaptureSession()
        // sessionPreset:
        // - 决定输出分辨率，这里使用 .photo，保证照片质量
        session.sessionPreset = .photo
        
        // 2.获取后置摄像头
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            //无后置摄像头,尝试前置摄像头
            guard let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                showErrorAlert(message: "设备无可用摄像头")
                return
            }
            configureCameraInput(session: session, device: frontDevice)
            return
        }
        
        // 3.配置摄像头输入
        configureCameraInput(session: session, device: videoDevice)
        // 4.配置相片输出
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
        }
        
        // 将会话绑定到预览层，并持有会话引用
        previewLayer.session = session
        captureSession = session
        
        // 知识点：startRunning 是同步且耗时的，放到后台队列避免卡住主线程
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    /// 配置摄像头输入
    /// - Parameters:
    ///   - session: 会话
    ///   - device: 具体使用的摄像头（前置/后置）
    private func configureCameraInput(session: AVCaptureSession, device: AVCaptureDevice){
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(videoInput){
                session.addInput(videoInput)
            }else{
                // 优化：避免在失败后继续使用该 session
                showErrorAlert(message:"无法添加摄像头输入")
            }
        } catch  {
            // 知识点：try / catch 用于捕获可抛出错误
            showErrorAlert(message:"摄像头初始化失败: \(error.localizedDescription)")
        }
        
    }
    
    /// 弹出摄像头权限不足提示
    /// - 知识点：UIApplication.openSettingsURLString 可跳转到系统设置
    private func showPermissionAlert(){
        let alert = UIAlertController(title: "权限不足", message: "请在设置中开启摄像头权限,否则无法使用拍照功能", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "去设置", style: .default, handler: { _ in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return  }
            if UIApplication.shared.canOpenURL(settingURL) {
                UIApplication.shared.open(settingURL)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
        
    }
    
    /// 模拟器不支持相机时的提示
    private func showSimulatorAlert(){
        let alert = UIAlertController(
            title: "提示",
            message: "模拟器无摄像头，请在真机上测试拍照功能",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    /// 通用错误提示弹窗
    /// - 优化原因：命名统一为 Alert，便于搜索和阅读
    private func showErrorAlert(message : String){
        let alert = UIAlertController(
            title: "错误",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    /// 拍照入口
    /// - 知识点：@objc 用于暴露给 Objective-C Runtime（如 UIButton 的 target-action）
    @objc private func capturePhoto(){
        // 可用编码检查：防御性代码，避免在极端设备上崩溃
        guard !photoOutput.availablePhotoCodecTypes.isEmpty else {
            showErrorAlert(message: "当前设备不支持拍照")
            return
        }
        
        let photoSettings = AVCapturePhotoSettings()
        // 优化原因：使用更清晰的命名 photoSettings，符合 Apple API 风格
        if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first  {
            photoSettings.previewPhotoFormat = [
                kCVPixelBufferPixelFormatTypeKey as String :  previewPhotoPixelFormatType
            ]
        }
        
        // 知识点：delegate 模式 —> 拍照完成后回调到 AVCapturePhotoCaptureDelegate
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        // 拍照按钮轻微缩放动画
        // 优化原因：增加交互反馈，提升体验
        UIView.animate(withDuration: 0.2) {
            self.captureButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.captureButton.transform = .identity
            }
        }
        
    }
    
    // MARK: - 资源释放
    deinit {
        // 停止会话，释放资源
        // 知识点：deinit 在对象释放前调用，适合做清理工作
        captureSession?.stopRunning()
        captureSession = nil
    }
}


extension CameraViewController : AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            DispatchQueue.main.async {
                if let error = error {
                    // 知识点：AVCapturePhotoCaptureDelegate 的错误只影响当前一次拍照，不影响会话本身
                    self.showErrorAlert(message: "拍照失败：\(error.localizedDescription)")
                    return
                }
                
                // 解析拍摄的照片数据
                guard let imageData = photo.fileDataRepresentation(),
                      let capturedImage = UIImage(data: imageData) else {
                    self.showErrorAlert(message: "无法解析拍摄的照片")
                    return
                }
                
                // 拍照后预览 + 让用户选择【保存到相册】或【取消】
                // 知识点：这里使用一个临时的全屏 UIViewController 做简单预览，
                // 而不是 push 新页面，方便快速关闭返回拍摄界面
                let previewVC = UIViewController()
                previewVC.view.backgroundColor = .black
                previewVC.modalPresentationStyle = .fullScreen
                
                // 图片预览
                let imageView = UIImageView(image: capturedImage)
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                previewVC.view.addSubview(imageView)
                
                // 按钮：取消 / 保存
                let cancelButton = UIButton(type: .system)
                cancelButton.setTitle("取消", for: .normal)
                cancelButton.setTitleColor(.white, for: .normal)
                cancelButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                cancelButton.layer.cornerRadius = 8
                cancelButton.translatesAutoresizingMaskIntoConstraints = false
                
                let saveButton = UIButton(type: .system)
                saveButton.setTitle("保存到相册", for: .normal)
                saveButton.setTitleColor(.white, for: .normal)
                saveButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
                saveButton.layer.cornerRadius = 8
                saveButton.translatesAutoresizingMaskIntoConstraints = false
                
                previewVC.view.addSubview(cancelButton)
                previewVC.view.addSubview(saveButton)
                
                // 约束布局
                let safeArea = previewVC.view.safeAreaLayoutGuide
                NSLayoutConstraint.activate([
                    // 图片占据上方区域
                    imageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
                    imageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
                    imageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
                    imageView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -24),
                    
                    // 按钮在底部水平排列
                    cancelButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
                    cancelButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24),
                    
                    saveButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
                    saveButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24),
                    
                    cancelButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -16),
                    cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor),
                    cancelButton.heightAnchor.constraint(equalToConstant: 44),
                    saveButton.heightAnchor.constraint(equalToConstant: 44)
                ])
                
                // 按钮事件
            cancelButton.addAction(UIAction { _ in
                previewVC.dismiss(animated: true)
            }, for: .touchUpInside)
                
            saveButton.addAction(UIAction { [weak self] _ in
                // 知识点：UIImageWriteToSavedPhotosAlbum 是 C-API 风格，通过 Selector 回调结果
                // 优化原因：弱引用 self，避免闭包强引用导致控制器不能释放
                guard let self = self else { return }
                UIImageWriteToSavedPhotosAlbum(
                    capturedImage,
                    self,
                    #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                    nil
                )
                previewVC.dismiss(animated: true)
            }, for: .touchUpInside)
                
                self.present(previewVC, animated: true)
            }
        }
        
        // 可选：保存到相册的回调
        @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                // 知识点：照片写入相册属于异步 IO 操作，通过回调拿到成功/失败
                showErrorAlert(message: "保存到相册失败：\(error.localizedDescription)")
            } else {
                let alert = UIAlertController(title: "成功", message: "照片已保存到相册", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                present(alert, animated: true)
            }
        }
}
