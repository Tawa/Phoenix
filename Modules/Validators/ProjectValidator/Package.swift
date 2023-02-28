// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ProjectValidator",
    products: [
        .library(
            name: "ProjectValidator",
            targets: ["ProjectValidator"])
    ],
    dependencies: [
        .package(path: "../../Contracts/Validators/ProjectValidatorContract"),
        .package(path: "../../Entities/PhoenixDocument")
    ],
    targets: [
        .target(
            name: "ProjectValidator",
            dependencies: [
                "ProjectValidatorContract",
                "PhoenixDocument"
            ]
        ),
        .testTarget(
            name: "ProjectValidatorTests",
            dependencies: [
                "ProjectValidator"
            ]
        )
    ]
)
