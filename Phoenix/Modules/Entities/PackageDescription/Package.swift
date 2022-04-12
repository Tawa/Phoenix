// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PackageDescription",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PackageDescription",
            type: .dynamic,
            targets: ["PackageDescription"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PackageDescription",
            dependencies: []),
        .testTarget(
            name: "PackageDescriptionTests",
            dependencies: ["PackageDescription"]),
    ]
)
