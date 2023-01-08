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
        .package(path: "../../Contracts/Generators/ProjectGeneratorContract"),
        .package(path: "../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "GenerateFeature",
            dependencies: [
                "ProjectGeneratorContract",
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
