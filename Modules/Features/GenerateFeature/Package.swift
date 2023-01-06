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
        .package(path: "../../Contracts/Generators/ProjectGeneratorContract")
    ],
    targets: [
        .target(
            name: "GenerateFeature",
            dependencies: [
                "ProjectGeneratorContract"
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
