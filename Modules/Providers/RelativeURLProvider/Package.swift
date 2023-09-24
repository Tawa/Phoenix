// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RelativeURLProvider",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "RelativeURLProvider",
            targets: ["RelativeURLProvider"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Providers/RelativeURLProviderContract")
    ],
    targets: [
        .target(
            name: "RelativeURLProvider",
            dependencies: [
                "RelativeURLProviderContract"
            ]
        ),
        .testTarget(
            name: "RelativeURLProviderTests",
            dependencies: [
                "RelativeURLProvider"
            ]
        )
    ]
)
