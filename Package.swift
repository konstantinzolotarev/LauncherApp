// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "LauncherApp",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.1"),
    ],
    targets: [
        .executableTarget(
            name: "LauncherApp",
            dependencies: ["HotKey"],
            path: "LauncherApp",
            exclude: ["App/Info.plist", "LauncherApp.entitlements"],
            resources: [.process("Assets.xcassets")]
        ),
        .testTarget(
            name: "LauncherAppTests",
            dependencies: ["LauncherApp"],
            path: "Tests"
        ),
    ]
)
