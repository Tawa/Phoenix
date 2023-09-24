// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PBXProjectSyncerContract",
    platforms: [
        .macOS(.v12)
    ],
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
