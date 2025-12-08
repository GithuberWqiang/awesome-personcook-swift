# SimpleStopWatch 知识点摘录与优化说明

## 功能概览
- 简易秒表：开始、暂停、重置，显示到 0.1 秒精度。
- 防重复点击：运行态禁止再次开始，暂停/停止态禁用暂停按钮。

## 关键实现与知识点
- **整数计时避免浮点误差**：使用 `tickCount`（十分之一秒为单位的 `Int`）+ `tickInterval = 0.1`，通过 `didSet` 联动 `updateTimeLabel()`，彻底规避 `0.1` 累加漂移。
- **Timer 闭包 + weak self**：`Timer.scheduledTimer(withTimeInterval:repeats:) { [weak self] _ in ... }` 避免 `@objc` 选择器和循环引用。
- **RunLoop 模式**：`RunLoop.main.add(timer, forMode: .common)`，保证滚动等 UI 事件不会暂停计时。
- **状态枚举替代布尔值**：`StopwatchState`（`stopped/running/paused`）驱动按钮交互，提升可读性与健壮性。
- **资源释放**：`deinit` 中调用 `stopTimerIfNeeded()`，防止 VC 销毁后 Timer 继续运行或导致内存泄漏。
- **属性观察者**：`didSet` 同步 UI（如 `tickCount` 更新时刷新 `timeLabel`）。

## 交互逻辑
- **开始**：仅非运行态可创建 Timer 并切换到 `running`。
- **暂停**：仅运行态可暂停；停表并切换到 `paused`。
- **重置**：停止计时、归零计数，切换到 `stopped`。
- **按钮状态**：由 `updateButtonState(for:)` 统一管理，避免分散控制导致状态错乱。

## 可进一步扩展
- 增加圈数记录、导出。
- 改用 `DispatchSourceTimer` 进一步提高精度/可控性。
- 将状态提升到 ViewModel，便于测试与复用。

## 运行
打开 Xcode 直接运行 `SimpleStopWatch` 目标，即可在模拟器或真机查看效果。

