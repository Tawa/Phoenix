// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "GenerateFeatureDataStore",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "GenerateFeatureDataStore",
            targets: ["GenerateFeatureDataStore"])
    ],
    dependencies: [
        .package(path: "../../Contracts/DataStores/GenerateFeatureDataStoreContract")
    ],
    targets: [
        .target(
            name: "GenerateFeatureDataStore",
            dependencies: [
                "GenerateFeatureDataStoreContract"
            ]
        ),
        .testTarget(
            name: "GenerateFeatureDataStoreTests",
            dependencies: [
                "GenerateFeatureDataStore"
            ]
        )
    ]
)
