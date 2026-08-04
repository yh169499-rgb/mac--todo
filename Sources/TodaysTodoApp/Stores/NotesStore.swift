import Foundation
import Combine

@MainActor
final class NotesStore: ObservableObject {
    @Published var text: String = "" {
        didSet {
            if !isLoading { save() }
        }
    }

    private let storageURL: URL
    private var isLoading = true

    init(storageURL: URL? = nil) {
        if let storageURL {
            self.storageURL = storageURL
        } else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            self.storageURL = support.appendingPathComponent("TodaysTodoApp/notes.txt")
        }
        if let saved = try? String(contentsOf: self.storageURL, encoding: .utf8) {
            text = saved
        }
        isLoading = false
    }

    private func save() {
        do {
            let directory = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try text.write(to: storageURL, atomically: true, encoding: .utf8)
        } catch {
            // Notes remain available in memory if the local file cannot be written.
        }
    }
}
