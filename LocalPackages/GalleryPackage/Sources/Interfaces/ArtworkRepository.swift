import Models

/// 作品データの取得口。
/// 画面モジュールはこの protocol だけを知り、実体は合成ルートが注入する。
public protocol ArtworkRepository: Sendable {
    func artworks(query: ArtworkQuery) async throws(ArtworkRepositoryError) -> ArtworkPage
    func artwork(id: Artwork.ID) async throws(ArtworkRepositoryError) -> Artwork
}
