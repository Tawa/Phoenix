// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ProjectGeneratorContract",
    products: [
        .library(
            name: "ProjectGeneratorContract",
            targets: ["ProjectGeneratorContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "ProjectGeneratorContract",
            dependencies: [
                "PhoenixDocument"
            ]
        )
    ]
)