// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Component",
    products: [
        .library(
            name: "Component",
            targets: ["Component"])
    ],
    dependencies: [
        .package(path: "../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "Component",
            dependencies: [
                "SwiftPackage"
            ]
        ),
        .testTarget(
            name: "ComponentTests",
            dependencies: [
                "Component"
            ]
        )
    ]
)
