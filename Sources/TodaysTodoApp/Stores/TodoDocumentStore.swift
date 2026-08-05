import Foundation

@MainActor
final class TodoDocumentStore {
    private let storageURL: URL
    private var date = ""
    private var notes = ""
    private var items: [TodoItem] = []

    init(storageURL: URL? = nil) {
        if let storageURL {
            self.storageURL = storageURL
        } else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            self.storageURL = support.appendingPathComponent("TodaysTodoApp/Todo记录.md")
        }
    }

    func update(date: String? = nil, notes: String? = nil, items: [TodoItem]? = nil) {
        if let date { self.date = date }
        if let notes { self.notes = notes }
        if let items { self.items = items }
        write()
    }

    private func write() {
        let todoLines = items.isEmpty
            ? "- 暂无待办"
            : items.map { item in
                let marker = item.isCompleted ? "x" : " "
                let label = item.isCarryOver ? "（延续）" : ""
                return "- [\(marker)] \(item.title)\(label)"
            }.joined(separator: "\n")
        let document = """
        # 今日待办记录

        日期：\(date.isEmpty ? "未设置" : date)

        ## 注意事项

        \(notes.isEmpty ? "暂无注意事项" : notes)

        ## 待办事项

        \(todoLines)
        """
        do {
            let directory = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try document.write(to: storageURL, atomically: true, encoding: .utf8)
        } catch {
            // The JSON and text stores remain the source of truth if Markdown export fails.
        }
    }
}
