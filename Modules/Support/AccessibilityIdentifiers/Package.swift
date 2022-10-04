// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AccessibilityIdentifiers",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "AccessibilityIdentifiers",
            targets: ["AccessibilityIdentifiers"])
    ],
    targets: [
        .target(
            name: "AccessibilityIdentifiers"
        ),
        .testTarget(
            name: "AccessibilityIdentifiersTests",
            dependencies: [
                "AccessibilityIdentifiers"
            ]
        )
    ]
)
