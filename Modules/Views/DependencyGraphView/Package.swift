// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "DependencyGraphView",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "DependencyGraphView",
            targets: ["DependencyGraphView"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Views/DependencyGraphViewContract")
    ],
    targets: [
        .target(
            name: "DependencyGraphView",
            dependencies: [
                "DependencyGraphViewContract"
            ]
        ),
        .testTarget(
            name: "DependencyGraphViewTests",
            dependencies: [
                "DependencyGraphView"
            ]
        )
    ]
)
