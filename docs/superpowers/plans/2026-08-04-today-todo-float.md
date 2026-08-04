# 今日待办悬浮窗实现计划

> **面向 AI 代理的工作者：** 必需子技能：使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐任务实现此计划。步骤使用复选框（`- [ ]`）语法来跟踪进度。

**目标：** 构建一个原生 macOS SwiftUI/AppKit 菜单栏应用，提供可收起的今日待办悬浮窗和 10:00–19:00 每小时本地通知。

**架构：** 使用 Swift Package Manager 作为可直接用 Xcode 打开的 macOS 可执行项目。SwiftUI 负责任务列表和编辑，AppKit 负责菜单栏、无边框悬浮面板、位置和收起状态；独立的纯 Swift 服务负责本地存储和提醒时间计算。

**技术栈：** Swift 5.9+、macOS 13+、SwiftUI、AppKit、UserNotifications、ServiceManagement、XCTest。

---

## 文件结构

- 创建：`Package.swift` — macOS 可执行目标和测试目标。
- 创建：`Sources/TodaysTodoApp/TodaysTodoApp.swift` — 应用入口和生命周期组装。
- 创建：`Sources/TodaysTodoApp/Models/TodoItem.swift` — 可编码任务模型。
- 创建：`Sources/TodaysTodoApp/Models/TodoDay.swift` — 按日期分组的持久化模型。
- 创建：`Sources/TodaysTodoApp/Stores/TodoStore.swift` — 本地 JSON 存储和任务 CRUD。
- 创建：`Sources/TodaysTodoApp/Reminders/ReminderSchedule.swift` — 纯函数提醒时间计算。
- 创建：`Sources/TodaysTodoApp/Reminders/ReminderScheduler.swift` — 本地通知调度和每日发送状态。
- 创建：`Sources/TodaysTodoApp/UI/TodoPanelView.swift` — 悬浮窗 SwiftUI 内容。
- 创建：`Sources/TodaysTodoApp/UI/FloatingPanelController.swift` — AppKit 面板创建、拖动、展开/收起。
- 创建：`Sources/TodaysTodoApp/UI/StatusBarController.swift` — 菜单栏图标和菜单操作。
- 创建：`Tests/TodaysTodoAppTests/TodoStoreTests.swift` — 存储和 CRUD 测试。
- 创建：`Tests/TodaysTodoAppTests/ReminderScheduleTests.swift` — 整点范围、跨天和睡眠恢复测试。

### 任务 1：建立可编译的 Swift Package

**文件：** `Package.swift`、`Sources/TodaysTodoApp/TodaysTodoApp.swift`

- [ ] **步骤 1：** 编写 `Package.swift`，声明 `.macOS(.v13)` 平台、可执行产品 `TodaysTodoApp`、测试目标。
- [ ] **步骤 2：** 创建 `@main` 应用入口，先渲染一个最小 `WindowGroup`，并确认 `swift build` 可通过。
- [ ] **步骤 3：** 运行 `swift build`，预期输出 `Build complete!`。

### 任务 2：实现任务模型和本地存储

**文件：** `Models/TodoItem.swift`、`Models/TodoDay.swift`、`Stores/TodoStore.swift`、`Tests/TodaysTodoAppTests/TodoStoreTests.swift`

- [ ] **步骤 1：** 先写测试：新建空日期、添加/修改/完成/删除任务、重新创建 store 后能读回 JSON。
- [ ] **步骤 2：** 运行 `swift test --filter TodoStoreTests`，预期测试先因类型或方法不存在而失败。
- [ ] **步骤 3：** 实现 `TodoItem`、`TodoDay` 和 `TodoStore`；通过注入 `storageURL` 支持测试目录，生产默认使用 `Application Support/TodaysTodoApp/todos.json`。
- [ ] **步骤 4：** 为所有写操作使用原子替换，读写失败时保留内存状态并返回可展示错误。
- [ ] **步骤 5：** 运行 `swift test --filter TodoStoreTests`，预期全部 PASS。

### 任务 3：实现提醒时间计算

**文件：** `Reminders/ReminderSchedule.swift`、`Tests/TodaysTodoAppTests/ReminderScheduleTests.swift`

- [ ] **步骤 1：** 先写测试：10:00 和 19:00 有效，09:59 和 19:01 无效；给定当前时间时返回下一个未发送整点；跨天返回次日 10:00；睡眠恢复不补发过去的多个时间点。
- [ ] **步骤 2：** 运行 `swift test --filter ReminderScheduleTests`，预期先失败。
- [ ] **步骤 3：** 实现 `ReminderSchedule.validHours = 10...19`、`isValidHour(_:)`、`nextReminder(after:sent:)` 和 `dayKey(for:)`，所有计算显式接收 `Calendar` 和 `Date` 便于测试。
- [ ] **步骤 4：** 运行过滤测试，预期全部 PASS。

### 任务 4：接入 macOS 本地通知和启动项

**文件：** `Reminders/ReminderScheduler.swift`、`TodaysTodoApp.swift`

- [ ] **步骤 1：** 创建 `UNUserNotificationCenter` 包装器，首次启动请求权限，使用日期组件生成每个整点的唯一通知 ID。
- [ ] **步骤 2：** 让 `ReminderScheduler` 持有当天已发送集合和暂停状态；启动、应用激活、系统时间变化、从睡眠恢复时重新计算下一次通知。
- [ ] **步骤 3：** 使用 `SMAppService.mainApp.register()` 注册登录启动；失败时仅记录日志，不影响主功能。
- [ ] **步骤 4：** 运行 `swift build` 和 `swift test`，预期编译通过且已有测试保持 PASS。

### 任务 5：实现悬浮窗和菜单栏

**文件：** `UI/TodoPanelView.swift`、`UI/FloatingPanelController.swift`、`UI/StatusBarController.swift`

- [ ] **步骤 1：** 先实现 SwiftUI 内容：日期标题、任务行、勾选、删除、新增输入框、空状态和错误提示。
- [ ] **步骤 2：** 创建 `NSPanel`：无边框、圆角视觉、`floating` level、非激活显示；保存展开面板的 frame。
- [ ] **步骤 3：** 实现收起为 42×42 pt 圆形按钮、原位恢复、标题区拖动和右上默认定位。
- [ ] **步骤 4：** 创建 `NSStatusItem` 菜单，接入显示/隐藏、添加任务、暂停/恢复提醒、通知设置入口和退出。
- [ ] **步骤 5：** 运行 `swift build`；在 macOS 上手动验证窗口尺寸、拖动、收起恢复和菜单操作不抢焦点。

### 任务 6：组装、测试和交付说明

**文件：** `TodaysTodoApp.swift`、`README.md`

- [ ] **步骤 1：** 在应用入口组装 `TodoStore`、`ReminderScheduler`、`FloatingPanelController` 和 `StatusBarController`，确保启动时只创建一个实例。
- [ ] **步骤 2：** 添加 `README.md`，说明 `swift run`、Xcode 打开方式、通知权限和登录启动限制。
- [ ] **步骤 3：** 运行 `swift test` 和 `swift build -c release`；预期测试通过、release 构建完成。
- [ ] **步骤 4：** 检查 `git diff --check` 和 `rg "TODO|待定|后续实现"`，清理所有计划占位符。

## 规格覆盖自检

- 悬浮窗、收起/恢复和菜单栏：任务 5。
- 今日任务 CRUD、本地持久化和跨天：任务 2、6。
- 10:00–19:00 每小时通知、暂停、权限和睡眠恢复：任务 3、4。
- 开机启动：任务 4。
- 错误处理：任务 2、4、5。
- 验证标准：任务 2–6 的测试和手动验证步骤。
