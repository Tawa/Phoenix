// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ComponentPackagesProviderContract",
    products: [
        .library(
            name: "ComponentPackagesProviderContract",
            targets: ["ComponentPackagesProviderContract"])
    ],
    dependencies: [
        .package(path: "../../../Entities/SwiftPackage")
    ],
    targets: [
        .target(
            name: "ComponentPackagesProviderContract",
            dependencies: [
                "SwiftPackage"
            ]
        )
    ]
)
