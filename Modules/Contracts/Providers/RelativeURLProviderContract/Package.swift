// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RelativeURLProviderContract",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RelativeURLProviderContract",
            targets: ["RelativeURLProviderContract"])
    ],
    targets: [
        .target(
            name: "RelativeURLProviderContract"
        )
    ]
)
