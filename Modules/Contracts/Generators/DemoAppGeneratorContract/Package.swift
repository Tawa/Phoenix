// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "DemoAppGeneratorContract",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DemoAppGeneratorContract",
            targets: ["DemoAppGeneratorContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/Package")
    ],
    targets: [
        .target(
            name: "DemoAppGeneratorContract",
            dependencies: [
                "Package"
            ]
        )
    ]
)
