// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PhoenixDocument",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PhoenixDocument",
            targets: ["PhoenixDocument"])
    ],
    dependencies: [
        .package(path: "../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "PhoenixDocument",
            dependencies: [
                "SwiftPackage"
            ]
        ),
        .testTarget(
            name: "PhoenixDocumentTests",
            dependencies: [
                "PhoenixDocument"
            ]
        )
    ]
)
