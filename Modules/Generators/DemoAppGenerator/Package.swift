// swift-tools-version: 5.7

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
        .package(path: "../../Contracts/Providers/ComponentDetailsProviderContract"),
        .package(path: "../../Contracts/Providers/RelativeURLProviderContract"),
        .package(path: "../../Entities/Component")
    ],
    targets: [
        .target(
            name: "DemoAppGenerator",
            dependencies: [
                "DemoAppGeneratorContract",
                "PackageGeneratorContract",
                "ComponentDetailsProviderContract",
                "RelativeURLProviderContract",
                "Component"
            ],
            resources: [
                .copy("Templates")
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
