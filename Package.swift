// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ProjectsWidget",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "ProjectsWidget", path: "Sources"),
    ]
)
