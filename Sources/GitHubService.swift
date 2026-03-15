import Foundation

enum GitHubService {
    private static let cacheDir: URL = {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".local/share/projects-widget")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private static let cacheFile: URL = cacheDir.appendingPathComponent("repos.json")

    private static var cachedRepos: [GitHubRepo] = []

    static func fetchRepos() -> [GitHubRepo] {
        let pid = ProcessInfo.processInfo.processIdentifier
        let rand = Int.random(in: 0...999_999)
        let tmpFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("projects-widget-\(pid)-\(rand).json")

        let fields = "name,nameWithOwner,pushedAt,defaultBranchRef,issues,url,description,primaryLanguage,isPrivate"

        let command = "gh repo list --json \(fields) --limit 50 --source > \(tmpFile.path)"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                try? FileManager.default.removeItem(at: tmpFile)
                return loadCache()
            }

            let data = try Data(contentsOf: tmpFile)
            try? FileManager.default.removeItem(at: tmpFile)

            let rawRepos = try JSONDecoder().decode([GHApiRepo].self, from: data)
            let repos = rawRepos
                .map { $0.toGitHubRepo() }
                .sorted { ($0.pushedAtDate ?? .distantPast) > ($1.pushedAtDate ?? .distantPast) }

            saveCache(repos)
            cachedRepos = repos
            return repos
        } catch {
            try? FileManager.default.removeItem(at: tmpFile)
            return loadCache()
        }
    }

    private static func loadCache() -> [GitHubRepo] {
        if !cachedRepos.isEmpty { return cachedRepos }
        guard let data = try? Data(contentsOf: cacheFile),
              let repos = try? JSONDecoder().decode([GitHubRepo].self, from: data)
        else { return [] }
        cachedRepos = repos
        return repos
    }

    private static func saveCache(_ repos: [GitHubRepo]) {
        guard let data = try? JSONEncoder().encode(repos) else { return }
        try? data.write(to: cacheFile)
    }
}

private struct GHApiRepo: Codable {
    let name: String
    let nameWithOwner: String
    let pushedAt: String
    let defaultBranchRef: BranchRef?
    let issues: IssueCount?
    let url: String
    let description: String?
    let primaryLanguage: LanguageNode?
    let isPrivate: Bool

    struct BranchRef: Codable {
        let name: String
    }

    struct LanguageNode: Codable {
        let name: String
    }

    struct IssueCount: Codable {
        let totalCount: Int
    }

    func toGitHubRepo() -> GitHubRepo {
        GitHubRepo(
            name: name,
            fullName: nameWithOwner,
            pushedAt: pushedAt,
            defaultBranch: defaultBranchRef?.name ?? "main",
            openIssuesCount: issues?.totalCount ?? 0,
            htmlUrl: url,
            description: description,
            language: primaryLanguage?.name,
            isPrivate: isPrivate
        )
    }
}
