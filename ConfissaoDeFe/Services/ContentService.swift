import Foundation
import Combine

// MARK: - ContentService
// Loads and caches the parsed chapters. Parsing is done once on first launch;
// subsequent launches restore the JSON cache from disk.

final class ContentService: ObservableObject {

    @Published private(set) var chapters: [Chapter] = []
    @Published private(set) var isLoading = false

    private let cacheFilename = "chapters_cache_v4.json"

    init() {
        // Warm launches should come up with content immediately when the cache already exists.
        if let cached = loadFromDisk() {
            chapters = cached
        } else {
            load()
        }
    }

    // MARK: - Public

    func chapter(id: Int) -> Chapter? {
        chapters.first { $0.id == id }
    }

    // MARK: - Loading

    func load() {
        guard chapters.isEmpty else { return }
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            // Try disk cache first for fast startup
            if let cached = self.loadFromDisk() {
                DispatchQueue.main.async {
                    self.chapters = cached
                    self.isLoading = false
                }
                return
            }

            // Parse HTML and persist cache
            let parsed = HTMLParser.parseConfession()
            self.saveToDisk(parsed)

            DispatchQueue.main.async {
                self.chapters = parsed
                self.isLoading = false
            }
        }
    }

    // MARK: - Cache

    private var cacheURL: URL? {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(cacheFilename)
    }

    private func loadFromDisk() -> [Chapter]? {
        guard let url = cacheURL,
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Chapter].self, from: data)
    }

    private func saveToDisk(_ chapters: [Chapter]) {
        guard let url = cacheURL,
              let data = try? JSONEncoder().encode(chapters) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
