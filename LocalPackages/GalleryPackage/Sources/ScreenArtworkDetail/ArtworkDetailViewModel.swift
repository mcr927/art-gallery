import Interfaces
import Models
import Observation

/// 詳細画面の状態を持つ。
///
/// 一覧の `ArtworkListViewModel` と構造を揃えている。
/// `@MainActor` を書いていないのは、Package.swift で UI 系ターゲットに
/// `.defaultIsolation(MainActor.self)` を指定しているため。
@Observable
final class ArtworkDetailViewModel {

    /// 画面が取りうる状態。
    ///
    /// 一覧と違い `empty` は無い。1件を取得できるか、できないかの二択であり、
    /// 「見つからない」は `failed(.server(statusCode: 404))` として扱う。
    enum State: Equatable {
        case loading
        case loaded(Artwork)
        case failed(ArtworkRepositoryError)
    }

    private(set) var state: State = .loading

    private let repository: any ArtworkRepository
    private let artworkID: Artwork.ID

    /// 一覧から `Artwork` を丸ごと受け取らず ID だけを受け取る。
    /// ID さえあれば画面が成立する形にしておくことで、
    /// 一覧を経由しない導線（ディープリンク・状態復元）に開いておける。
    init(repository: any ArtworkRepository, artworkID: Artwork.ID) {
        self.repository = repository
        self.artworkID = artworkID
    }

    func load() async {
        state = .loading
        await fetch()
    }

    private func fetch() async {
        do {
            let artwork = try await repository.artwork(id: artworkID)
            state = .loaded(artwork)
        } catch {
            // 一覧と同様、画面を離れたことによる中断はエラー表示にしない。
            guard error != .cancelled else { return }
            state = .failed(error)
        }
    }
}
