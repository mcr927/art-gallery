import Interfaces
import Models
import SwiftUI

/// `ArtworkDetailScreenBuilding` のプレビュー・テスト用スタブ。
///
/// 実体を返さずプレースホルダを返すことで、
/// 一覧画面のプレビューが `ScreenArtworkDetail` に依存せずに済む。
/// 遷移先が何であれ一覧の見た目は変わらない、という関係をそのまま表している。
@MainActor
public struct StubArtworkDetailScreenBuilder: ArtworkDetailScreenBuilding {

    public init() {}

    public func build(artworkID: Artwork.ID) -> AnyView {
        AnyView(
            Text(verbatim: "Detail placeholder: \(artworkID)")
                .font(.footnote.monospaced())
        )
    }
}
