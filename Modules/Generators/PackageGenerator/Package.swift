// swift-tools-version: 5.6

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
        .package(path: "../../Entities/Package")
    ],
    targets: [
        .target(
            name: "PackageGenerator",
            dependencies: [
                "PackageGeneratorContract",
                "PackageStringProviderContract",
                "Package"
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
