// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ComponentPackagesProvider",
    products: [
        .library(
            name: "ComponentPackagesProvider",
            targets: ["ComponentPackagesProvider"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/ComponentPackagesProviderContract"),
        .package(path: "../../Contracts/Providers/PackagePathProviderContract"),
        .package(path: "../../Entities/Package")
    ],
    targets: [
        .target(
            name: "ComponentPackagesProvider",
            dependencies: [
                "ComponentPackagesProviderContract",
                "PackagePathProviderContract",
                "Package"
            ]
        ),
        .testTarget(
            name: "ComponentPackagesProviderTests",
            dependencies: [
                "ComponentPackagesProvider"
            ]
        )
    ]
)
