// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "DemoAppGeneratorContract",
    products: [
        .library(
            name: "DemoAppGeneratorContract",
            targets: ["DemoAppGeneratorContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/Component")
    ],
    targets: [
        .target(
            name: "DemoAppGeneratorContract",
            dependencies: [
                "Component"
            ]
        )
    ]
)
