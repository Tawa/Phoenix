// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "PackageStringProvider",
    products: [
        .library(
            name: "PackageStringProvider",
            targets: ["PackageStringProvider"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/PackageStringProviderContract"),
        .package(path: "../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "PackageStringProvider",
            dependencies: [
                "PackageStringProviderContract",
                "SwiftPackage"
            ]
        ),
        .testTarget(
            name: "PackageStringProviderTests",
            dependencies: [
                "PackageStringProvider"
            ]
        )
    ]
)
