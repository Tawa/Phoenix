// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "LocalFileURLProvider",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LocalFileURLProvider",
            targets: ["LocalFileURLProvider"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/LocalFileURLProviderContract")
    ],
    targets: [
        .target(
            name: "LocalFileURLProvider",
            dependencies: [
                "LocalFileURLProviderContract"
            ]
        ),
        .testTarget(
            name: "LocalFileURLProviderTests",
            dependencies: [
                "LocalFileURLProvider"
            ]
        )
    ]
)
