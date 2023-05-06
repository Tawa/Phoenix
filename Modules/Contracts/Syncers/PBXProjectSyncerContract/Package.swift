// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "PBXProjectSyncerContract",
    products: [
        .library(
            name: "PBXProjectSyncerContract",
            targets: ["PBXProjectSyncerContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/PhoenixDocument"),
        .package(path: "../../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "PBXProjectSyncerContract",
            dependencies: [
                "PhoenixDocument",
                "SwiftPackage"
            ]
        )
    ]
)
