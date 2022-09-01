// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "DependencyGraphView",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DependencyGraphView",
            targets: ["DependencyGraphView"])
    ],
    targets: [
        .target(
            name: "DependencyGraphView"
        ),
        .testTarget(
            name: "DependencyGraphViewTests",
            dependencies: [
                "DependencyGraphView"
            ]
        )
    ]
)
