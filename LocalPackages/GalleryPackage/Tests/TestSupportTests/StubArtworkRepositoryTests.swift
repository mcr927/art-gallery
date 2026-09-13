import Testing
import Foundation
@testable import TestSupport
import Interfaces
import Models

@Suite("StubArtworkRepository")
struct StubArtworkRepositoryTests {

    @Test("success では指定したページをそのまま返す")
    func returnsConfiguredPage() async throws {
        let repository = StubArtworkRepository(behavior: .success(.preview))

        let page = try await repository.artworks(query: ArtworkQuery(departmentTitle: nil))

        #expect(page.items.count == 6)
        #expect(page.nextPage == 2)
        #expect(page.items.first?.id == 27992)
    }

    @Test("failure では指定したエラーを送出する")
    func throwsConfiguredError() async {
        let repository = StubArtworkRepository(behavior: .failure(.offline))

        let error = await #expect(throws: ArtworkRepositoryError.self) {
            try await repository.artworks(query: ArtworkQuery(departmentTitle: nil))
        }

        guard case .offline = error else {
            Issue.record("offline が送出されること。実際: \(String(describing: error))")
            return
        }
    }

    @Test("success でも一覧に存在しない ID には 404 を返す")
    func throwsNotFoundForUnknownIdentifier() async {
        let repository = StubArtworkRepository(behavior: .success(.preview))

        let error = await #expect(throws: ArtworkRepositoryError.self) {
            try await repository.artwork(id: 999_999)
        }

        guard case .server(let statusCode) = error else {
            Issue.record("server が送出されること。実際: \(String(describing: error))")
            return
        }
        #expect(statusCode == 404)
    }
}
