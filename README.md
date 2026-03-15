# macos-widget-projects

A native macOS desktop widget that tracks your active projects. Answers: "what should I be working on?"

Auto-discovers repos from your GitHub account, shows last commit date, staleness, and lets you mark projects as done. A personal kanban floating on your desktop.

## Planned features

- Auto-discover repos via `gh` CLI, cached locally
- Show: repo name, last commit, uncommitted changes, open PRs
- Status: active / stalled (2+ weeks) / done (manual)
- Nudges for stalled projects
- Click to open in editor or GitHub
- Same SwiftUI+AppKit floating window pattern as [linkedin-desktop-widget](https://github.com/sderosiaux/linkedin-desktop-widget)

## Prerequisites

- macOS 14+
- Swift 5.9+
- [GitHub CLI](https://cli.github.com) (`gh`) authenticated

## Status

Scaffolded. Not yet implemented.

## License

MIT
