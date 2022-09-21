// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "PhoenixViews",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PhoenixViews",
            targets: ["PhoenixViews"])
    ],
    targets: [
        .target(
            name: "PhoenixViews"
        ),
        .testTarget(
            name: "PhoenixViewsTests",
            dependencies: [
                "PhoenixViews"
            ]
        )
    ]
)
