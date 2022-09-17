// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "DemoAppGenerator",
    products: [
        .library(
            name: "DemoAppGenerator",
            targets: ["DemoAppGenerator"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Generators/DemoAppGeneratorContract"),
        .package(path: "../../Contracts/Generators/PackageGeneratorContract"),
        .package(path: "../../Contracts/Providers/PackagePathProviderContract"),
        .package(path: "../../Contracts/Providers/RelativeURLProviderContract"),
        .package(path: "../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "DemoAppGenerator",
            dependencies: [
                "DemoAppGeneratorContract",
                "PackageGeneratorContract",
                "PackagePathProviderContract",
                "RelativeURLProviderContract",
                "SwiftPackage"
            ],
            resources: [
                .copy("Templates"),
            ]
        ),
        .testTarget(
            name: "DemoAppGeneratorTests",
            dependencies: [
                "DemoAppGenerator"
            ]
        )
    ]
)
