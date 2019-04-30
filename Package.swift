// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rop",
    products: [
        .library(
        name: "Rop",
        targets: ["Rop"]),
    ],
    targets: [
        .target(name: "Rop"),
        .testTarget(name: "RopTests"),
    ],
    swiftLanguageVersions: [.version("5")]
)
