// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "GenerateFeature",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "GenerateFeature",
            targets: ["GenerateFeature"])
    ],
    dependencies: [
        .package(path: "../../Contracts/DataStores/GenerateFeatureDataStoreContract"),
        .package(path: "../../Contracts/Generators/ProjectGeneratorContract"),
        .package(path: "../../Contracts/Providers/LocalFileURLProviderContract"),
        .package(path: "../../Contracts/Syncers/PBXProjectSyncerContract"),
        .package(path: "../../Entities/PhoenixDocument"),
        .package(path: "../../Support/AccessibilityIdentifiers")
    ],
    targets: [
        .target(
            name: "GenerateFeature",
            dependencies: [
                "GenerateFeatureDataStoreContract",
                "ProjectGeneratorContract",
                "LocalFileURLProviderContract",
                "PBXProjectSyncerContract",
                "PhoenixDocument",
                "AccessibilityIdentifiers"
            ]
        ),
        .testTarget(
            name: "GenerateFeatureTests",
            dependencies: [
                "GenerateFeature"
            ]
        )
    ]
)
