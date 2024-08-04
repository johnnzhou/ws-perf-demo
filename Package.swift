// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ws-perf-demo",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/Local-Connectivity-Lab/websocket-kit", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Client",
            dependencies: [
                .product(name: "WebSocketKit", package: "websocket-kit")
            ]
        ),
        .executableTarget(
            name: "Server",
            dependencies: [
                .product(name: "WebSocketKit", package: "websocket-kit")
            ]
        )
    ]
)
