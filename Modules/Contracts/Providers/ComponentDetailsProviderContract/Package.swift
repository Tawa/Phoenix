// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ComponentDetailsProviderContract",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ComponentDetailsProviderContract",
            targets: ["ComponentDetailsProviderContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "ComponentDetailsProviderContract",
            dependencies: [
                "PhoenixDocument"
            ]
        )
    ]
)
