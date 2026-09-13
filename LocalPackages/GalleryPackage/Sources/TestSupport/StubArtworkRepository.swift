import Foundation
import Interfaces
import Models

/// `ArtworkRepository` のテスト・プレビュー用スタブ実装。
///
/// 呼び出し記録を保持しないため、Meszaros の分類では Mock ではなく Stub にあたる。
/// 記録を持たせる場合は可変状態の同期（actor / Mutex）が必要になるが、
/// 現時点で呼び出し回数を検証する場面がないため意図的に持たせていない。
public struct StubArtworkRepository: ArtworkRepository {

    /// スタブの振る舞い。
    public enum Behavior: Sendable {
        /// 指定したページを返す。
        case success(ArtworkPage)
        /// 指定したエラーを送出する。
        case failure(ArtworkRepositoryError)
        /// キャンセルされるまで完了しない。ローディング状態の確認に使う。
        case pending
    }

    private let behavior: Behavior

    public init(behavior: Behavior = .success(.preview)) {
        self.behavior = behavior
    }

    public func artworks(query: ArtworkQuery) async throws(ArtworkRepositoryError) -> ArtworkPage {
        switch behavior {
        case .success(let page):
            return page
        case .failure(let error):
            throw error
        case .pending:
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
            }
            throw .cancelled
        }
    }

    public func artwork(id: Artwork.ID) async throws(ArtworkRepositoryError) -> Artwork {
        switch behavior {
        case .success(let page):
            guard let artwork = page.items.first(where: { $0.id == id }) else {
                // 一覧に含まれない ID が要求された場合は API と同じく 404 として扱う。
                throw .server(statusCode: 404)
            }
            return artwork
        case .failure(let error):
            throw error
        case .pending:
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
            }
            throw .cancelled
        }
    }
}
