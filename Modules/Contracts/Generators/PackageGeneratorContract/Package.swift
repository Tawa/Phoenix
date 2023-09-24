// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PackageGeneratorContract",
    platforms: [
        .macOS(.v12)
    ],
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
