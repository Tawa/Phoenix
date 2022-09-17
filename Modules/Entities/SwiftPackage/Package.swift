// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SwiftPackage",
    products: [
        .library(
            name: "SwiftPackage",
            targets: ["SwiftPackage"])
    ],
    targets: [
        .target(
            name: "SwiftPackage"
        ),
        .testTarget(
            name: "SwiftPackageTests",
            dependencies: [
                "SwiftPackage"
            ]
        )
    ]
)
