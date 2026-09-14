import Models
import Testing
import TestSupport
@testable import ScreenArtworkDetail

@Suite("ArtworkDetailViewModel")
struct ArtworkDetailViewModelTests {

    private func makeViewModel(
        behavior: StubArtworkRepository.Behavior,
        artworkID: Artwork.ID
    ) -> ArtworkDetailViewModel {
        ArtworkDetailViewModel(
            repository: StubArtworkRepository(behavior: behavior),
            artworkID: artworkID
        )
    }

    @Test("生成直後は loading")
    func initialStateIsLoading() {
        let viewModel = makeViewModel(
            behavior: .success(.preview),
            artworkID: Artwork.preview.id
        )
        #expect(viewModel.state == .loading)
    }

    @Test("取得に成功すると loaded になり、要求した作品が入る")
    func loadedOnSuccess() async {
        let viewModel = makeViewModel(
            behavior: .success(.preview),
            artworkID: Artwork.previewPortrait.id
        )

        await viewModel.load()

        #expect(viewModel.state == .loaded(.previewPortrait))
    }

    @Test("存在しないIDは 404 として failed になる")
    func failedOnUnknownID() async {
        let viewModel = makeViewModel(
            behavior: .success(.preview),
            artworkID: 999_999
        )

        await viewModel.load()

        #expect(viewModel.state == .failed(.server(statusCode: 404)))
    }

    @Test("オフラインは failed になる")
    func failedOnOffline() async {
        let viewModel = makeViewModel(
            behavior: .failure(.offline),
            artworkID: Artwork.preview.id
        )

        await viewModel.load()

        #expect(viewModel.state == .failed(.offline))
    }
}
