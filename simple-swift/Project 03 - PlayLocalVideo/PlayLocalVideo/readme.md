# PlayLocalVideo

一个使用 `AVPlayerViewController` 播放本地 mp4 并展示视频列表的示例。主要演示 UITableView、AVKit 基础用法与常见 Swift 代码习惯。

## 运行方式
- 使用 Xcode 打开 `PlayLocalVideo.xcodeproj`。
- 目标设备选择 iPhone 模拟器或真机，直接运行即可。

## 主要知识点
- AVKit 播放本地资源：`AVPlayerViewController` + `AVPlayer` 播放 Bundle 中的 mp4。
- 表格视图数据源：`UITableViewDataSource/Delegate` 的 section、row、高度配置与单元格复用。
- nib/Storyboard 连接：`@IBOutlet` 默认使用 `weak` 以避免循环引用；IBAction 触发播放。
- 数据模型：`struct Video` 作为轻量值类型，复制安全且线程友好。
- 延迟加载与不可变性：`lazy var` 延迟创建播放器控制器，`let` 数组保证列表数据只读，减少意外修改。
- 可复用单元格：`reuseIdentifier` 常量化，提供 `configure(with:)` 统一填充入口。
- 安全编码：使用 `guard` 处理可选资源，避免强制解包导致崩溃。
- 性能小技巧：`final` 限制继承，略减动态派发开销。

## 本次优化说明
- 播放逻辑：使用 `Bundle.main.url` + `guard` 获取本地视频，避免 `path!` 强制解包带来的崩溃风险。
- 复用与可读性：表格的复用标识集中在 `VideoCell.reuseIdentifier`，单元格填充收敛到 `configure(with:)`，控制器更简洁。
- 数据安全：视频列表改为 `let` 常量，防止运行时被意外修改。
- 结构化标记：`MARK` 分段和注释补充了 Swift/UIKit 常见习惯，便于学习查阅。
- Section 数量：修正为单 section，避免多余空白区域。

## 可能的扩展方向
- 增加播放控制（暂停/拖动进度）。
- 加入播放完成的通知处理，自动重播或跳转下一条。
- 为视频列表接入远程数据并做缓存。
