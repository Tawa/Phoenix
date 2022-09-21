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
        .package(path: "../../Entities/Component"),
        .package(path: "../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "DemoAppFeature",
            dependencies: [
                "Component",
                "PhoenixDocument"
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
