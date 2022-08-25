// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "AppVersionProvider",
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
