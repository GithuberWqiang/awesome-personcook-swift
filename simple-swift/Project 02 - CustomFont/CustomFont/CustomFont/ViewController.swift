//
//  ViewController.swift
//  CustomFont
//
//  Created by NightOwl_Thinker on 2025/12/8.
//

import UIKit

final class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // 使用 static 标识符便于与 storyboard 中的复用 ID 保持一致，避免 dequeue 时崩溃
    static let identifier = "FontCell"

    // 演示数据
    private let data = [
        "30 Days Swift",
        "这些字体特别适合打「奋斗」和「理想」",
        "谢谢「造字工房」，本案例不涉及商业使用",
        "使用到造字工房劲黑体，致黑体，童心体",
        "呵呵，再见🤗 See you next Project",
        "微博 @Owl",
        "测试测试测试测试测试测试",
        "123",
        "Owl",
        "@@@@@@"
    ]

    // 自定义字体：需在 Info.plist 的 “Fonts provided by application” 注册字体文件，否则 UIFont(name: ) 会返回 nil
    private let fontNames = [
        "MFTongXin_Noncommercial-Regular",
        "MFJinHei_Noncommercial-Regular",
        "Zapfino",
        "Gaspar Regular"
    ]

    private var fontRowIndex = 0
    private var currentFontName: String { fontNames[fontRowIndex] }
    private let rowHeight: CGFloat = 40

    @IBOutlet private weak var ChangeFontLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 将圆角与点击手势放在 didLoad，避免重复配置
        ChangeFontLabel.layer.cornerRadius = 50
        ChangeFontLabel.layer.masksToBounds = true
        ChangeFontLabel.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.changeFont))
        ChangeFontLabel.addGestureRecognizer(gesture)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = rowHeight
    }

    // @objc 暴露给 Objective-C runtime，供 UITapGestureRecognizer 使用
    @objc private func changeFont() {
        fontRowIndex = (fontRowIndex + 1) % fontNames.count
        print("使用的字体是: \(currentFontName)")
//        tableView.reloadData()
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.identifier, for: indexPath)
        

        // 这里使用可选绑定，若字体未注册成功则回退到系统字体，避免显示异常
        let font = UIFont(name: currentFontName, size: 16) ?? .systemFont(ofSize: 16)
        
//        if #available(iOS 14.0, *) {
//            var contentConfig = cell.defaultContentConfiguration()
//            
//            contentConfig.text = data[indexPath.row]
//            contentConfig.textProperties.font = font
//            contentConfig.textProperties.color = .white
//            
//            cell.contentConfiguration = contentConfig
//        }else{
            cell.textLabel?.text = data[indexPath.row]
            cell.textLabel?.font = font
            cell.textLabel?.textColor = .white
//        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}

