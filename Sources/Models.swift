import Foundation
import SwiftUI

struct GitHubRepo: Codable, Identifiable {
    let name: String
    let fullName: String
    let pushedAt: String
    let defaultBranch: String
    let openIssuesCount: Int
    let htmlUrl: String
    let description: String?
    let language: String?
    let isPrivate: Bool

    var id: String { fullName }

    private enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
        case pushedAt = "pushed_at"
        case defaultBranch = "default_branch"
        case openIssuesCount = "open_issues_count"
        case htmlUrl = "html_url"
        case description
        case language
        case isPrivate = "is_private"
    }

    var pushedAtDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: pushedAt) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: pushedAt)
    }

    var daysSinceLastPush: Int {
        guard let date = pushedAtDate else { return 999 }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 999
    }

    var status: RepoStatus {
        let days = daysSinceLastPush
        if days < 7 { return .active }
        if days <= 30 { return .stalled }
        return .dormant
    }

    var statusColor: Color {
        switch status {
        case .active: .green
        case .stalled: .orange
        case .dormant: .red
        }
    }

    var url: URL? {
        URL(string: htmlUrl)
    }

    func matchesSearch(_ query: String) -> Bool {
        let lowered = query.lowercased()
        if name.lowercased().contains(lowered) { return true }
        if let desc = description, desc.lowercased().contains(lowered) { return true }
        if let lang = language, lang.lowercased().contains(lowered) { return true }
        return false
    }
}

enum RepoStatus {
    case active
    case stalled
    case dormant
}
