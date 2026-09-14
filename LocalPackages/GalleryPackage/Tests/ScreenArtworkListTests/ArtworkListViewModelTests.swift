import Models
import Testing
import TestSupport
@testable import ScreenArtworkList

/// ViewModel は internal のため `@testable import` で参照する。
/// モジュールの公開APIを増やさずに状態遷移を検証するための選択。
@Suite("ArtworkListViewModel")
struct ArtworkListViewModelTests {

    private func makeViewModel(
        behavior: StubArtworkRepository.Behavior
    ) -> ArtworkListViewModel {
        ArtworkListViewModel(
            repository: StubArtworkRepository(behavior: behavior),
            query: ArtworkQuery()
        )
    }

    @Test("生成直後は loading")
    func initialStateIsLoading() {
        let viewModel = makeViewModel(behavior: .success(.preview))
        #expect(viewModel.state == .loading)
    }

    @Test("取得に成功すると loaded になる")
    func loadedOnSuccess() async {
        let viewModel = makeViewModel(behavior: .success(.preview))

        await viewModel.load()

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("loaded を期待したが \(viewModel.state) だった")
            return
        }
        #expect(page.items.count == 6)
        // ページネーション自体は未実装だが、次ページ番号は状態に保持されている。
        #expect(page.nextPage == 2)
    }

    @Test("0件のページは empty として扱う")
    func emptyOnNoItems() async {
        let viewModel = makeViewModel(behavior: .success(.empty))

        await viewModel.load()

        #expect(viewModel.state == .empty)
    }

    @Test("オフラインは failed になり、エラーの種類が保たれる")
    func failedOnOffline() async {
        let viewModel = makeViewModel(behavior: .failure(.offline))

        await viewModel.load()

        #expect(viewModel.state == .failed(.offline))
    }

    @Test("サーバーエラーはステータスコードごと保持される")
    func failedOnServerError() async {
        let viewModel = makeViewModel(behavior: .failure(.server(statusCode: 429)))

        await viewModel.load()

        #expect(viewModel.state == .failed(.server(statusCode: 429)))
    }
}
