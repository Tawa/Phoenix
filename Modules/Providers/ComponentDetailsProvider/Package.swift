// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ComponentDetailsProvider",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ComponentDetailsProvider",
            targets: ["ComponentDetailsProvider"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/ComponentDetailsProviderContract"),
        .package(path: "../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "ComponentDetailsProvider",
            dependencies: [
                "ComponentDetailsProviderContract",
                "PhoenixDocument"
            ]
        ),
        .testTarget(
            name: "ComponentDetailsProviderTests",
            dependencies: [
                "ComponentDetailsProvider"
            ]
        )
    ]
)
