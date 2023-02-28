// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ProjectValidatorContract",
    products: [
        .library(
            name: "ProjectValidatorContract",
            targets: ["ProjectValidatorContract"])
    ],
    targets: [
        .target(
            name: "ProjectValidatorContract"
        )
    ]
)
