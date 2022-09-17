// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PackagePathProviderContract",
    products: [
        .library(
            name: "PackagePathProviderContract",
            targets: ["PackagePathProviderContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "PackagePathProviderContract",
            dependencies: [
                "SwiftPackage"
            ]
        )
    ]
)
