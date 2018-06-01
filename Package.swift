// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppleBot",
    dependencies: [
        .package(url: "https://github.com/Azoy/Sword", .branch("master")),
        .package(url: "https://github.com/vapor-community/sockets", Version(2,2,3)...Version(2,2,3))
    ],
    targets: [
        .target(
            name: "AppleBot",
            dependencies: ["Sword"]),
    ]
)
