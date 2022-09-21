// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PhoenixDocument",
    products: [
        .library(
            name: "PhoenixDocument",
            targets: ["PhoenixDocument"])
    ],
    dependencies: [
        .package(path: "../../Entities/Component")
    ],
    targets: [
        .target(
            name: "PhoenixDocument",
            dependencies: [
                "Component"
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
