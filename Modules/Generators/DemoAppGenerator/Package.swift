// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "DemoAppGenerator",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DemoAppGenerator",
            targets: ["DemoAppGenerator"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Generators/DemoAppGeneratorContract"),
        .package(path: "../../Contracts/Providers/RelativeURLProviderContract"),
        .package(path: "../../Entities/Package")
    ],
    targets: [
        .target(
            name: "DemoAppGenerator",
            dependencies: [
                "DemoAppGeneratorContract",
                "RelativeURLProviderContract",
                "Package"
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
