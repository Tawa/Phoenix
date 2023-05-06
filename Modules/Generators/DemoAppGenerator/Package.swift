// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "DemoAppGenerator",
    products: [
        .library(
            name: "DemoAppGenerator",
            targets: ["DemoAppGenerator"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Generators/DemoAppGeneratorContract")
    ],
    targets: [
        .target(
            name: "DemoAppGenerator",
            dependencies: [
                "DemoAppGeneratorContract"
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
