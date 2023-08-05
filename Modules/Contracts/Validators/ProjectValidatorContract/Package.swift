// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ProjectValidatorContract",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ProjectValidatorContract",
            targets: ["ProjectValidatorContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "ProjectValidatorContract",
            dependencies: [
                "PhoenixDocument"
            ]
        )
    ]
)
