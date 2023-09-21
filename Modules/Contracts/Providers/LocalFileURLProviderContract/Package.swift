// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LocalFileURLProviderContract",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LocalFileURLProviderContract",
            targets: ["LocalFileURLProviderContract"])
    ],
    targets: [
        .target(
            name: "LocalFileURLProviderContract"
        )
    ]
)
