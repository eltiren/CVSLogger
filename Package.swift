// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CVSLogger",
    products: [
        .library(
            name: "CVSLogger",
            targets: ["CVSLogger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0"),
    ],
    targets: [
        .target(
            name: "CVSLogger",
            dependencies: [
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack")
            ]),
        .testTarget(
            name: "CVSLoggerTests",
            dependencies: ["CVSLogger"]),
    ]
)
