# mac桌面小插件（todo）

一个原生 macOS 今日待办悬浮窗：常驻菜单栏，支持任务增删改、完成勾选、收起/展开，并在每天 10:00–19:00 每小时通过 macOS 通知提醒查看。

## 使用

需要 macOS 13 或更高版本。用 Xcode 打开项目根目录的 `Package.swift`，选择 `TodaysTodoApp` scheme 后运行；首次启动请允许通知权限。

也可以在终端执行：

```bash
swift run TodaysTodoApp
```

数据存储在 `~/Library/Application Support/TodaysTodoApp/todos.json`。应用启动时会尝试注册登录启动；系统设置或未签名运行环境可能限制该行为。

## 验证

```bash
swift test
swift build -c release
```
