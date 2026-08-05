# mac桌面小插件（todo）

一个原生 macOS 今日待办悬浮窗：常驻菜单栏，支持任务增删改、完成勾选、注意事项长期保存、未完成待办跨天延续、收起/展开，并在每天 10:00–19:00 每小时通过 macOS 通知提醒查看。

## 使用

需要 macOS 13 或更高版本。用 Xcode 打开项目根目录的 `Package.swift`，选择 `TodaysTodoApp` scheme 后运行；首次启动请允许通知权限。

也可以在终端执行：

```bash
swift run TodaysTodoApp
```

## 打包成 macOS 应用

运行下面的脚本会生成真正可双击的 `dist/TodaysTodoApp.app`：

```bash
./scripts/package-app.sh
open dist/TodaysTodoApp.app
```

首次打开时，如果 macOS 提示“无法验证开发者”，可在“系统设置 → 隐私与安全性”中允许打开。应用是本地 ad-hoc 签名，未做 App Store 公证。

待办数据存储在 `~/Library/Application Support/TodaysTodoApp/todos.json`，注意事项存储在同目录的 `notes.txt`；同时会持续更新同目录的 `Todo记录.md`，作为可阅读、可备份的永久记录文档。应用启动时会尝试注册登录启动；系统设置或未签名运行环境可能限制该行为。

## 验证

```bash
swift test
swift build -c release
```
