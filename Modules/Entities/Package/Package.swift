// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Package",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Package",
            targets: ["Package"]),
    ],
    targets: [
        .target(
            name: "Package"
        ),
        .testTarget(
            name: "PackageTests",
            dependencies: [
                "Package",
            ]
        ),
    ]
)
