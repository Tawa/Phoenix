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
        .package(path: "../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "PackagePathProvider",
            dependencies: [
                "PackagePathProviderContract",
                "SwiftPackage"
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
