// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AppVersionProvider",
    platforms: [
        .macOS(.v12)
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
