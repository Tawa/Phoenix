// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PackageStringProviderContract",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PackageStringProviderContract",
            targets: ["PackageStringProviderContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "PackageStringProviderContract",
            dependencies: [
                "SwiftPackage"
            ]
        )
    ]
)
