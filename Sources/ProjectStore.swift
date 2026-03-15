import Foundation
import Observation

@Observable
final class ProjectStore {
    var repos: [GitHubRepo] = []
    var lastRefresh: Date?
    var searchQuery: String = "" {
        didSet { scheduleSearch() }
    }
    var showDone = false
    private(set) var doneNames: Set<String> = []

    private var searchTask: Task<Void, Never>?
    private var filteredBySearch: [GitHubRepo]?

    private static let dataDir: URL = {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".local/share/projects-widget")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private static let doneFile: URL = dataDir.appendingPathComponent("done.json")

    var filteredRepos: [GitHubRepo] {
        let source = searchQuery.isEmpty ? repos : (filteredBySearch ?? [])
        if showDone { return source }
        return source.filter { !doneNames.contains($0.fullName) }
    }

    var doneCount: Int { doneNames.count }

    init() {
        loadDone()
    }

    func markDone(_ fullName: String) {
        doneNames.insert(fullName)
        saveDone()
    }

    func unmarkDone(_ fullName: String) {
        doneNames.remove(fullName)
        saveDone()
    }

    func isDone(_ fullName: String) -> Bool {
        doneNames.contains(fullName)
    }

    private func loadDone() {
        guard let data = try? Data(contentsOf: Self.doneFile),
              let names = try? JSONDecoder().decode(Set<String>.self, from: data)
        else { return }
        doneNames = names
    }

    private func saveDone() {
        guard let data = try? JSONEncoder().encode(doneNames) else { return }
        try? data.write(to: Self.doneFile)
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        let query = searchQuery

        if query.isEmpty {
            filteredBySearch = nil
            return
        }

        searchTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            self.filteredBySearch = self.repos.filter { $0.matchesSearch(query) }
        }
    }

    @MainActor
    func refresh() async {
        let result = await Task.detached {
            GitHubService.fetchRepos()
        }.value
        self.repos = result
        self.lastRefresh = Date()
    }
}
