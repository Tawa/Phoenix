// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "PackageGenerator",
    products: [
        .library(
            name: "PackageGenerator",
            targets: ["PackageGenerator"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Generators/PackageGeneratorContract"),
        .package(path: "../../Contracts/Providers/PackageStringProviderContract"),
        .package(path: "../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "PackageGenerator",
            dependencies: [
                "PackageGeneratorContract",
                "PackageStringProviderContract",
                "SwiftPackage"
            ]
        ),
        .testTarget(
            name: "PackageGeneratorTests",
            dependencies: [
                "PackageGenerator"
            ]
        )
    ]
)
