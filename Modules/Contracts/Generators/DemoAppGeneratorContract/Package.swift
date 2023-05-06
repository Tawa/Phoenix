// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "DemoAppGeneratorContract",
    products: [
        .library(
            name: "DemoAppGeneratorContract",
            targets: ["DemoAppGeneratorContract"])
    ],
    targets: [
        .target(
            name: "DemoAppGeneratorContract"
        )
    ]
)
