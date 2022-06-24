// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "DependencyGraphViewContract",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "DependencyGraphViewContract",
            targets: ["DependencyGraphViewContract"])
    ],
    targets: [
        .target(
            name: "DependencyGraphViewContract"
        )
    ]
)
