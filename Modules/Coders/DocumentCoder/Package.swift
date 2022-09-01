// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "DocumentCoder",
    products: [
        .library(
            name: "DocumentCoder",
            targets: ["DocumentCoder"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Coders/DocumentCoderContract"),
        .package(path: "../../Contracts/Providers/AppVersionProviderContract"),
        .package(path: "../../Entities/Package")
    ],
    targets: [
        .target(
            name: "DocumentCoder",
            dependencies: [
                "DocumentCoderContract",
                "AppVersionProviderContract",
                "Package"
            ]
        ),
        .testTarget(
            name: "DocumentCoderTests",
            dependencies: [
                "DocumentCoder"
            ]
        )
    ]
)
