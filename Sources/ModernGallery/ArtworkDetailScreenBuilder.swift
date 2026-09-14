import Interfaces
import Models
import ScreenArtworkDetail
import SwiftUI

/// 一覧から詳細への接続点。
///
/// 両方の画面モジュールを知っているのはアプリターゲットだけで、
/// 画面同士は互いを import しない。
/// `AnyView` による型消去は、`some View` を protocol requirement にすると
/// associatedtype が生まれて `any ArtworkDetailScreenBuilding` として
/// 保持できなくなるため。画面遷移の頻度を考えればコストは問題にならない。
@MainActor
struct ArtworkDetailScreenBuilder: ArtworkDetailScreenBuilding {

    private let repository: any ArtworkRepository

    init(repository: any ArtworkRepository) {
        self.repository = repository
    }

    func build(artworkID: Artwork.ID) -> AnyView {
        AnyView(
            ArtworkDetailScreen(repository: repository, artworkID: artworkID)
        )
    }
}
