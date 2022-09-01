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
        .package(path: "../../../Entities/Package")
    ],
    targets: [
        .target(
            name: "PackagePathProviderContract",
            dependencies: [
                "Package"
            ]
        )
    ]
)
