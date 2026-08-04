import SwiftUI

struct TodoPanelView: View {
    @ObservedObject var store: TodoStore
    @ObservedObject var notes: NotesStore
    let collapse: () -> Void
    @State private var draft = ""

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: .now)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("今日待办").font(.system(size: 20, weight: .bold, design: .rounded))
                    Text(dateLabel).font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: collapse) { Image(systemName: "minus.circle.fill") }
                    .buttonStyle(.plain).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 18).padding(.top, 16).padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 6) {
                Text("注意事项")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                TextEditor(text: $notes.text)
                    .font(.system(size: 12))
                    .scrollContentBackground(.hidden)
                    .padding(6)
                    .frame(height: 82)
                    .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)

            if store.items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle").font(.system(size: 28)).foregroundStyle(.tint)
                    Text("今天还没有待办").font(.system(size: 14, weight: .medium))
                    Text("把要记住的事情写下来").font(.system(size: 12)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(store.items) { item in
                            TodoRow(item: item, store: store)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 4)
                }
            }

            HStack(spacing: 8) {
                TextField("添加一项待办…", text: $draft)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(add)
                Button(action: add) { Image(systemName: "plus") }
                    .buttonStyle(.borderedProminent)
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(14)
            if let error = store.lastError {
                Text(error).font(.caption2).foregroundStyle(.red).padding(.horizontal, 14).padding(.bottom, 8)
            }
        }
        .frame(width: 300, height: 480)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func add() {
        guard store.add(title: draft) != nil else { return }
        draft = ""
    }
}

private struct TodoRow: View {
    let item: TodoItem
    @ObservedObject var store: TodoStore
    @State private var text: String

    init(item: TodoItem, store: TodoStore) {
        self.item = item
        self.store = store
        _text = State(initialValue: item.title)
    }

    var body: some View {
        HStack(spacing: 8) {
            Button { store.toggle(item) } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? Color.accentColor : Color.secondary)
            }.buttonStyle(.plain)
            TextField("待办", text: $text, onCommit: { store.update(item, title: text) })
                .textFieldStyle(.plain)
                .strikethrough(item.isCompleted)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
            if item.isCarryOver {
                Text("延续")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.orange)
            }
            Button { store.delete(item) } label: { Image(systemName: "xmark") }
                .buttonStyle(.plain).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 10))
    }
}
