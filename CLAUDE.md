# Projects Widget

## Stack

- **Language**: Swift 5.9+
- **UI**: SwiftUI + NSVisualEffectView (borderless floating window)
- **Platform**: macOS 14+
- **Build**: Swift Package Manager (`swift build`)
- **Run**: `.build/debug/ProjectsWidget`

## Architecture

```
Sources/
  main.swift              # NSApplication bootstrap
  AppDelegate.swift       # Floating borderless window + vibrancy
  ResizableWindow.swift   # Custom NSWindow with resize corner
  ResizeHandle.swift      # SwiftUI resize indicator
  WidgetView.swift        # Header + search + repo list + timer
  RepoRow.swift           # Single repo row with status dot + hover actions
  Models.swift            # GitHubRepo, RepoStatus
  ProjectStore.swift      # @Observable store, refresh + done/search state
  GitHubService.swift     # Shell out to `gh repo list`, JSON cache
```

## Data Source

| Source | Method | Details |
|---|---|---|
| GitHub | `gh repo list --json ... --source` | Fetches up to 50 source repos, cached to `~/.local/share/projects-widget/repos.json` |

## Key Decisions

- **Status thresholds**: green <7d, orange 7-30d, red >30d (computed in `Models.swift`)
- **Refresh**: every 10 minutes via Timer, fetched on a detached Task
- **GitHub CLI**: shells out to `gh` via `/bin/zsh -c`. Falls back to cache on failure.
- **Done state**: persisted to `~/.local/share/projects-widget/done.json`
- **Search**: debounced 300ms, filters by name/description/language
- **Sorted**: most recently pushed first
- **Window**: borderless, desktop-level, movable, resizable, position persisted via `setFrameAutosaveName`

## Rules

- Requires `gh` CLI authenticated (`gh auth login`)
- Keep all operations read-only
- `swift build` must pass before committing
