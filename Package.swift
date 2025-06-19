// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "textios",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "textios",
            targets: ["textios"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI.git", branch: "main")
    ],
    targets: [
        .target(
            name: "textios",
            dependencies: ["OpenAI"],
            path: "WritingApp",
            exclude: ["Info.plist", "WritingApp.entitlements", "Preview Content", "Resources"],
            resources: [
                .process("Resources/Assets.xcassets")
            ]),
        .testTarget(
            name: "textiosTests",
            dependencies: ["textios"]),
    ]
) 