## CustomFont 示例说明

### 功能简述
- 展示一组文案列表，并支持点击顶部标签循环切换不同字体。
- 自定义字体文件存放在 `Fonts/` 目录，通过 Info.plist 注册后在界面中展示。

### Swift 知识点提炼
- `UITableViewDataSource/Delegate`：实现行数、单元格配置和行高，使用 `dequeueReusableCell` 复用单元格。
- 自定义字体加载：`UIFont(name:size:)` 依赖 Info.plist 中 *Fonts provided by application* 注册的字体文件，未注册时会返回 `nil`，需要安全回退到系统字体。
- 交互手势：`UITapGestureRecognizer` 绑定到 `UILabel`，并将手势 selector 标记为 `@objc` 以暴露给 Objective-C runtime。
- 属性与封装：使用 `private` 修饰数据源、字体数组、行高等，避免外部误用；通过计算属性 `currentFontName` 简化当前字体获取。
- UI 圆角与交互：在 `viewDidLoad` 中设置 `cornerRadius`、`masksToBounds` 与 `isUserInteractionEnabled`，确保 Label 可点击且保持圆角形态。
- 常量化配置：将行高、复用标识等硬编码值提取为常量，便于维护并减少魔法数字。

