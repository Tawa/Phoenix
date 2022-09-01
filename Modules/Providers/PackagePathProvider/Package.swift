// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PackagePathProvider",
    products: [
        .library(
            name: "PackagePathProvider",
            targets: ["PackagePathProvider"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/PackagePathProviderContract"),
        .package(path: "../../Entities/Package")
    ],
    targets: [
        .target(
            name: "PackagePathProvider",
            dependencies: [
                "PackagePathProviderContract",
                "Package"
            ]
        ),
        .testTarget(
            name: "PackagePathProviderTests",
            dependencies: [
                "PackagePathProvider"
            ]
        )
    ]
)
