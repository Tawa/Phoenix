// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "PhoenixDocument",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "PhoenixDocument",
            targets: ["PhoenixDocument"]),
    ],
    dependencies: [
        .package(path: "../../Entities/Package"),
    ],
    targets: [
        .target(
            name: "PhoenixDocument",
            dependencies: [
                "Package",
            ]
        ),
        .testTarget(
            name: "PhoenixDocumentTests",
            dependencies: [
                "PhoenixDocument",
            ]
        ),
    ]
)
