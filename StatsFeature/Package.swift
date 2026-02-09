// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StatsFeature",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "StatsFeature",
            targets: ["StatsFeature"]
        ),
    ],
    dependencies: [
        .package(path: "../StatsClient"),
    ],
    targets: [
        .target(
            name: "StatsFeature",
            dependencies: [
                "StatsClient",
                .product(name: "StatsClientLive", package: "StatsClient"),
            ]
        ),
    ]
)
