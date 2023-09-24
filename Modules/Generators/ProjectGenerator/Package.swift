// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ProjectGenerator",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ProjectGenerator",
            targets: ["ProjectGenerator"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Generators/PackageGeneratorContract"),
        .package(path: "../../Contracts/Generators/ProjectGeneratorContract"),
        .package(path: "../../Contracts/Providers/ComponentDetailsProviderContract"),
        .package(path: "../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "ProjectGenerator",
            dependencies: [
                "PackageGeneratorContract",
                "ProjectGeneratorContract",
                "ComponentDetailsProviderContract",
                "PhoenixDocument"
            ]
        ),
        .testTarget(
            name: "ProjectGeneratorTests",
            dependencies: [
                "ProjectGenerator"
            ]
        )
    ]
)
