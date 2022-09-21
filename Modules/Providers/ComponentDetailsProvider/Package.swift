// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ComponentDetailsProvider",
    products: [
        .library(
            name: "ComponentDetailsProvider",
            targets: ["ComponentDetailsProvider"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/ComponentDetailsProviderContract"),
        .package(path: "../../Entities/Component")
    ],
    targets: [
        .target(
            name: "ComponentDetailsProvider",
            dependencies: [
                "ComponentDetailsProviderContract",
                "Component"
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
