// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ProjectValidator",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ProjectValidator",
            targets: ["ProjectValidator"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Coders/DocumentCoderContract"),
        .package(path: "../../Contracts/Generators/ProjectGeneratorContract"),
        .package(path: "../../Contracts/Providers/PackageStringProviderContract"),
        .package(path: "../../Contracts/Validators/ProjectValidatorContract"),
        .package(path: "../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "ProjectValidator",
            dependencies: [
                "DocumentCoderContract",
                "ProjectGeneratorContract",
                "PackageStringProviderContract",
                "ProjectValidatorContract",
                "PhoenixDocument"
            ]
        ),
        .testTarget(
            name: "ProjectValidatorTests",
            dependencies: [
                "ProjectValidator"
            ]
        )
    ]
)
