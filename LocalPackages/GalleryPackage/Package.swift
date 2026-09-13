// swift-tools-version: 6.2

import PackageDescription

// MARK: - Swift Settings

/// ドメイン層・通信層向け。MainActorデフォルトは意図的に付けない。
/// ここにMainActor隔離を効かせると Interfaces のprotocol requirementが暗黙に
/// @MainActor となり、APIClientのデコードやユニットテストが不必要にメインスレッドへ縛られる。
let coreSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
]

/// UI層向け。SwiftUIのViewとDesignSystemは実質MainActor上でしか動かないため、
/// 個別の @MainActor 記述を省いて記述量を抑える。
let uiSwiftSettings: [SwiftSetting] = coreSwiftSettings + [
    .defaultIsolation(MainActor.self),
]

// MARK: - Package

let package = Package(
    name: "GalleryPackage",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Interfaces", targets: ["Interfaces"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "APIClient", targets: ["APIClient"]),
        .library(name: "TestSupport", targets: ["TestSupport"]),
        .library(name: "ScreenArtworkList", targets: ["ScreenArtworkList"]),
        .library(name: "ScreenArtworkDetail", targets: ["ScreenArtworkDetail"]),
    ],
    targets: [
        // 純粋な型のみ。依存ゼロ。
        .target(
            name: "Models",
            swiftSettings: coreSwiftSettings
        ),

        // protocolのみ。モジュール間の結節点。
        .target(
            name: "Interfaces",
            dependencies: ["Models"],
            swiftSettings: coreSwiftSettings
        ),

        // 色・タイポグラフィ・ドメイン非依存の共通コンポーネント。
        // Modelsに依存させない。作品セルのようなドメイン依存のViewは画面モジュール側に置く。
        .target(
            name: "DesignSystem",
            swiftSettings: uiSwiftSettings
        ),

        // Interfacesの実装。アプリターゲット（合成ルート）からのみ参照される。
        .target(
            name: "APIClient",
            dependencies: ["Interfaces"],
            swiftSettings: coreSwiftSettings
        ),

        // Interfacesのモック実装。テストおよびPreviewから使う。
        .target(
            name: "TestSupport",
            dependencies: ["Interfaces"],
            swiftSettings: coreSwiftSettings
        ),

        // 画面モジュールは APIClient に依存しない。
        .target(
            name: "ScreenArtworkList",
            dependencies: [
                "Interfaces",
                "DesignSystem",
            ],
            swiftSettings: uiSwiftSettings
        ),

        .target(
            name: "ScreenArtworkDetail",
            dependencies: [
                "Interfaces",
                "DesignSystem",
            ],
            swiftSettings: uiSwiftSettings
        ),
        
        .testTarget(
            name: "APIClientTests",
            dependencies: ["APIClient"],
            swiftSettings: coreSwiftSettings
        ),
    ]
)
