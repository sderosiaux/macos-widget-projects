import SwiftUI

struct WidgetView: View {
    let store: ProjectStore
    let timer = Timer.publish(every: 600, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            searchField
            Divider()
            contentSection
            ResizeHandle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await store.refresh() }
        .onReceive(timer) { _ in
            Task { await store.refresh() }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 6) {
            Text("Projects")
                .font(.title3)
                .fontWeight(.bold)
            if store.doneCount > 0 {
                Button {
                    store.showDone.toggle()
                } label: {
                    Text("\(store.doneCount) done")
                        .font(.subheadline)
                        .foregroundStyle(store.showDone ? Color.blue : Color.secondary)
                }
                .buttonStyle(.plain)
            }
            Spacer()
            if let date = store.lastRefresh {
                Text(date, style: .time)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            headerMenu
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var headerMenu: some View {
        Menu {
            Button("Refresh") {
                Task { await store.refresh() }
            }
            Button(store.showDone ? "Hide done" : "Show done") {
                store.showDone.toggle()
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
    }

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            TextField("Filter by name, language, keyword...", text: Binding(
                get: { store.searchQuery },
                set: { store.searchQuery = $0 }
            ))
            .textFieldStyle(.plain)
            .font(.subheadline)
            if !store.searchQuery.isEmpty {
                Button {
                    store.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.04))
    }

    @ViewBuilder
    private var contentSection: some View {
        if store.filteredRepos.isEmpty {
            Spacer()
            Text(store.repos.isEmpty
                 ? "No repos yet.\nEnsure gh CLI is installed."
                 : "No matches.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(store.filteredRepos) { repo in
                        RepoRow(repo: repo, store: store)
                        if repo.id != store.filteredRepos.last?.id {
                            Divider().padding(.leading, 12)
                        }
                    }
                }
            }
        }
    }
}
