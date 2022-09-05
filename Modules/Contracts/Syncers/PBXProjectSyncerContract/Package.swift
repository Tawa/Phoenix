// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PBXProjectSyncerContract",
    products: [
        .library(
            name: "PBXProjectSyncerContract",
            targets: ["PBXProjectSyncerContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/Package"),
        .package(path: "../../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "PBXProjectSyncerContract",
            dependencies: [
                "Package",
                "PhoenixDocument"
            ]
        )
    ]
)
