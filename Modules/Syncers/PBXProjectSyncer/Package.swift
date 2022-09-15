// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PBXProjectSyncer",
    products: [
        .library(
            name: "PBXProjectSyncer",
            targets: ["PBXProjectSyncer"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/PackagePathProviderContract"),
        .package(path: "../../Contracts/Syncers/PBXProjectSyncerContract"),
        .package(path: "../../Entities/Package"),
        .package(path: "../../Entities/PhoenixDocument"),
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "8.8.0")
    ],
    targets: [
        .target(
            name: "PBXProjectSyncer",
            dependencies: [
                "PackagePathProviderContract",
                "PBXProjectSyncerContract",
                "Package",
                "PhoenixDocument",
                "XcodeProj"
            ]
        ),
        .testTarget(
            name: "PBXProjectSyncerTests",
            dependencies: [
                "PBXProjectSyncer"
            ]
        )
    ]
)
