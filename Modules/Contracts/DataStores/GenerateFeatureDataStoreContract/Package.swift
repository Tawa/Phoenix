// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GenerateFeatureDataStoreContract",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "GenerateFeatureDataStoreContract",
            targets: ["GenerateFeatureDataStoreContract"])
    ],
    targets: [
        .target(
            name: "GenerateFeatureDataStoreContract"
        )
    ]
)
