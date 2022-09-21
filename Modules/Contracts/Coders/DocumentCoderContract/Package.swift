// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DocumentCoderContract",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "DocumentCoderContract",
            targets: ["DocumentCoderContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "DocumentCoderContract",
            dependencies: [
                "PhoenixDocument"
            ]
        )
    ]
)
