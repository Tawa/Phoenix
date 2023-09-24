// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DocumentCoder",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "DocumentCoder",
            targets: ["DocumentCoder"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Coders/DocumentCoderContract"),
        .package(path: "../../Contracts/Providers/AppVersionProviderContract"),
        .package(path: "../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "DocumentCoder",
            dependencies: [
                "DocumentCoderContract",
                "AppVersionProviderContract",
                "SwiftPackage"
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
