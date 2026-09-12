// swift-tools-version: 6.2

import PackageDescription

let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
]

let package = Package(
    name: "GalleryPackage",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]
        ),
    ],
    targets: [
        .target(
            name: "Models",
            swiftSettings: sharedSwiftSettings
        ),
    ]
)