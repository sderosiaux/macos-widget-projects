import SwiftUI

struct RepoRow: View {
    let repo: GitHubRepo
    let store: ProjectStore
    @State private var isHovered = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            rowContent
            if isHovered {
                hoverActions
            }
        }
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }

    private var rowContent: some View {
        Button {
            if let url = repo.url {
                NSWorkspace.shared.open(url)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                repoHeader
                if let desc = repo.description {
                    Text(desc)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                repoMeta
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var repoHeader: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(repo.statusColor)
                .frame(width: 7, height: 7)
            Text(repo.name)
                .font(.body)
                .fontWeight(.bold)
                .lineLimit(1)
            if let lang = repo.language {
                Text(lang)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
            }
            Spacer()
        }
    }

    private var repoMeta: some View {
        HStack(spacing: 12) {
            let days = repo.daysSinceLastPush
            Text("Last push: \(days)d ago")
                .font(.caption)
                .foregroundStyle(.tertiary)
            if repo.openIssuesCount > 0 {
                Label("\(repo.openIssuesCount)", systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            if repo.isPrivate {
                Image(systemName: "lock")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var hoverActions: some View {
        HStack(spacing: 4) {
            hoverButton(store.isDone(repo.fullName) ? "Undo" : "Done") {
                if store.isDone(repo.fullName) {
                    store.unmarkDone(repo.fullName)
                } else {
                    store.markDone(repo.fullName)
                }
            }
            hoverButton("Open") {
                if let url = repo.url {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        .padding(4)
    }

    private func hoverButton(
        _ label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }
}
