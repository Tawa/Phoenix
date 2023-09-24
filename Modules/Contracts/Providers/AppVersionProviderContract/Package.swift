// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AppVersionProviderContract",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AppVersionProviderContract",
            targets: ["AppVersionProviderContract"])
    ],
    targets: [
        .target(
            name: "AppVersionProviderContract"
        )
    ]
)
