// swift-tools-version: 5.7

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
        .package(path: "../../Contracts/Syncers/PBXProjectSyncerContract"),
        .package(path: "../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "GenerateFeature",
            dependencies: [
                "GenerateFeatureDataStoreContract",
                "ProjectGeneratorContract",
                "PBXProjectSyncerContract",
                "PhoenixDocument"
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
