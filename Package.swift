// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AssetsParser",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "AssetsParser",
            targets: [
                "AssetsParser"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/coollazy/Image.git", .upToNextMinor(from: "1.1.0")),
    ],
    targets: [
        .target(
            name: "AssetsParser",
            dependencies: [
                .product(name: "Image", package: "Image"),
            ]
        ),
    ]
)
