// swift-tools-version: 5.7

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
        .package(path: "../../Contracts/Generators/DemoAppGeneratorContract"),
        .package(path: "../../Contracts/Providers/ComponentDetailsProviderContract"),
        .package(path: "../../Contracts/Syncers/PBXProjectSyncerContract"),
        .package(path: "../../Entities/Component"),
        .package(path: "../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "DemoAppFeature",
            dependencies: [
                "DemoAppGeneratorContract",
                "ComponentDetailsProviderContract",
                "PBXProjectSyncerContract",
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
