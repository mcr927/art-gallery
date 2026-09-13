import Testing
@testable import APIClient

@Suite("ArtworkAPIClient")
struct ArtworkAPIClientTests {
    @Test("テストターゲットが APIClient を参照できる")
    func moduleIsVisible() {
        _ = ArtworkAPIClient()
    }
}
