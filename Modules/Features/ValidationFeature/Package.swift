// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ValidationFeature",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ValidationFeature",
            targets: ["ValidationFeature"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Validators/ProjectValidatorContract")
    ],
    targets: [
        .target(
            name: "ValidationFeature",
            dependencies: [
                "ProjectValidatorContract"
            ]
        ),
        .testTarget(
            name: "ValidationFeatureTests",
            dependencies: [
                "ValidationFeature"
            ]
        )
    ]
)
