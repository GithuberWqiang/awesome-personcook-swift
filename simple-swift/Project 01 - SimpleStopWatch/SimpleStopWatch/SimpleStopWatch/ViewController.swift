//
//  ViewController.swift
//  SimpleStopWatch
//
//  Created by NightOwl_Thinker on 2025/12/8.
//

import UIKit

class ViewController: UIViewController {

    // MARK: var
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    // 使用「十分之一秒」为单位的整数计数，彻底规避 0.1 累加浮点误差
    private let tickInterval: TimeInterval = 0.1
    private var tickCount: Int = 0 {
        didSet { updateTimeLabel() } // 属性观察者：数值变化即联动 UI
    }
    
    // Timer 使用闭包形式并弱引用 self，避免 @objc/循环引用
    private var timer: Timer?
    
    // 状态枚举替代布尔值，提升可读性与可维护性
    private enum StopwatchState {
        case stopped
        case running
        case paused
    }
    
    private var state: StopwatchState = .stopped {
        didSet { updateButtonState(for: state) }
    }
    
    // MARK: aciton
    
    @IBAction func resetButtonDidTouch(_ sender: UIButton) {
        stopTimerIfNeeded()
        tickCount = 0
        state = .stopped
    }
    
    @IBAction func playButtonDidTouch(_ sender: UIButton) {
        // 防御重复点击：运行中直接返回
        guard state != .running else { return }
        startTimer()
        state = .running
    }
    
    @IBAction func pauseButtonDidTouch(_ sender: UIButton) {
        // 仅在运行态才允许暂停
        guard state == .running else { return }
        stopTimerIfNeeded()
        state = .paused
    }
    
    // MARK: override
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        // 只读计算属性，可以去掉get和花括号
        // get 省略的写法：直接返回表达式
        return UIStatusBarStyle.lightContent
    }
    
    
    // MARK: lifecycel
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    deinit {
        // 视图销毁时停止 Timer，避免引用循环或后台继续计时
        stopTimerIfNeeded()
        debugPrint("VC销毁了")
    }
    
    // MARK: private helper
    private func configureUI() {
        tickCount = 0
        state = .stopped
    }
    
    private func startTimer() {
        // 闭包版 Timer，使用 weak self 避免循环引用
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.handleTick()
        }
        // 将 Timer 放到通用 RunLoop 模式，避免 UI 滚动等操作暂停计时
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopTimerIfNeeded() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTick() {
        tickCount += 1
    }
    
    private func updateTimeLabel() {
        let seconds = Double(tickCount) * tickInterval
        timeLabel.text = String(format: "%0.1f", seconds)
    }
    
    private func updateButtonState(for state: StopwatchState) {
        // 根据状态管理交互，避免重复点击带来的逻辑分叉
        switch state {
        case .running:
            playButton.isEnabled = false
            pauseButton.isEnabled = true
        case .paused:
            playButton.isEnabled = true
            pauseButton.isEnabled = false
        case .stopped:
            playButton.isEnabled = true
            pauseButton.isEnabled = false
        }
    }


}

