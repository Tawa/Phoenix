// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "PackageStringProvider",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PackageStringProvider",
            targets: ["PackageStringProvider"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/PackageStringProviderContract"),
        .package(path: "../../Entities/Package")
    ],
    targets: [
        .target(
            name: "PackageStringProvider",
            dependencies: [
                "PackageStringProviderContract",
                "Package"
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
