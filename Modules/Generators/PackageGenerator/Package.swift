// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PackageGenerator",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PackageGenerator",
            targets: ["PackageGenerator"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Generators/PackageGeneratorContract"),
        .package(path: "../../Contracts/Providers/PackageStringProviderContract"),
        .package(path: "../../Entities/SwiftPackage"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "PackageGenerator",
            dependencies: [
                "PackageGeneratorContract",
                "PackageStringProviderContract",
                "SwiftPackage",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "PackageGeneratorTests",
            dependencies: [
                "PackageGenerator"
            ]
        )
    ]
)
