// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "PBXProjectSyncer",
    products: [
        .library(
            name: "PBXProjectSyncer",
            targets: ["PBXProjectSyncer"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/ComponentDetailsProviderContract"),
        .package(path: "../../Contracts/Providers/RelativeURLProviderContract"),
        .package(path: "../../Contracts/Syncers/PBXProjectSyncerContract"),
        .package(path: "../../Entities/PhoenixDocument"),
        .package(path: "../../Entities/SwiftPackage"),
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "8.8.0")
    ],
    targets: [
        .target(
            name: "PBXProjectSyncer",
            dependencies: [
                "ComponentDetailsProviderContract",
                "RelativeURLProviderContract",
                "PBXProjectSyncerContract",
                "PhoenixDocument",
                "SwiftPackage",
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
