// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "AppVersionProviderContract",
    platforms: [
        .macOS(.v10_15)
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
