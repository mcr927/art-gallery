import Models
import SwiftUI

/// 画面間遷移。一覧は詳細画面の実装を知らない。
@MainActor
public protocol ArtworkDetailScreenBuilding: Sendable {
    func build(artworkID: Artwork.ID) -> AnyView
}
