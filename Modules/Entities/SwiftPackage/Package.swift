// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftPackage",
    platforms: [
        .macOS(.v12)
    ],
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
