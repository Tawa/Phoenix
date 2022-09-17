// swift-tools-version: 5.6

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
