// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AppVersionProvider",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AppVersionProvider",
            targets: ["AppVersionProvider"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/AppVersionProviderContract")
    ],
    targets: [
        .target(
            name: "AppVersionProvider",
            dependencies: [
                "AppVersionProviderContract"
            ]
        ),
        .testTarget(
            name: "AppVersionProviderTests",
            dependencies: [
                "AppVersionProvider"
            ]
        )
    ]
)
