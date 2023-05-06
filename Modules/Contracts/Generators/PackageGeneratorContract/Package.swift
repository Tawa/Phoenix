// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "PackageGeneratorContract",
    products: [
        .library(
            name: "PackageGeneratorContract",
            targets: ["PackageGeneratorContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "PackageGeneratorContract",
            dependencies: [
                "SwiftPackage"
            ]
        )
    ]
)
