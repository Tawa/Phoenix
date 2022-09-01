// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PackageStringProviderContract",
    products: [
        .library(
            name: "PackageStringProviderContract",
            targets: ["PackageStringProviderContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/Package")
    ],
    targets: [
        .target(
            name: "PackageStringProviderContract",
            dependencies: [
                "Package"
            ]
        )
    ]
)
