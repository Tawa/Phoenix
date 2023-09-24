// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ProjectGeneratorContract",
    platforms: [
        .macOS(.v12)
    ],
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
