// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "DemoAppFeature",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DemoAppFeature",
            targets: ["DemoAppFeature"])
    ],
    dependencies: [
        .package(path: "../../Entities/PhoenixDocument"),
        .package(path: "../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "DemoAppFeature",
            dependencies: [
                "PhoenixDocument",
                "SwiftPackage"
            ]
        ),
        .testTarget(
            name: "DemoAppFeatureTests",
            dependencies: [
                "DemoAppFeature"
            ]
        )
    ]
)
