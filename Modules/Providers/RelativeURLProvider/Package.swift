// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "RelativeURLProvider",
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
