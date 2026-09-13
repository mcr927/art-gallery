import Foundation
import Testing
@testable import APIClient
import Models

@Suite("ArtworkRequestBuilder")
struct ArtworkRequestBuilderTests {

    private let userAgent = "art-gallery-test"

    /// クエリの順序に依存しないよう name/value の集合で比較する。
    private func queryItems(of request: URLRequest) throws -> Set<URLQueryItem> {
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        return Set(components.queryItems ?? [])
    }

    @Test("部門指定ありの一覧リクエストを組み立てる")
    func buildsListRequestWithDepartment() throws {
        let query = ArtworkQuery(
            departmentTitle: "Contemporary Art",
            page: 2,
            pageSize: 24,
            publicDomainOnly: true
        )

        let request = try #require(
            ArtworkRequestBuilder.listRequest(query: query, userAgent: userAgent)
        )
        let url = try #require(request.url)

        #expect(url.path() == "/api/v1/artworks/search")

        let items = try queryItems(of: request)
        #expect(items.contains(URLQueryItem(name: "page", value: "2")))
        #expect(items.contains(URLQueryItem(name: "limit", value: "24")))
        #expect(items.contains(URLQueryItem(name: "query[exists][field]", value: "image_id")))
        #expect(items.contains(
            URLQueryItem(name: "query[term][department_title.keyword]", value: "Contemporary Art")
        ))
    }

    @Test("部門指定なしのときは部門のクエリを含まない")
    func omitsDepartmentWhenNil() throws {
        let query = ArtworkQuery(departmentTitle: nil)

        let request = try #require(
            ArtworkRequestBuilder.listRequest(query: query, userAgent: userAgent)
        )

        let names = try Set(queryItems(of: request).map(\.name))
        #expect(!names.contains("query[term][department_title.keyword]"))
        #expect(names.contains("query[exists][field]"))
    }

    @Test("空白を含む値がパーセントエンコードされる")
    func encodesSpacesInValues() throws {
        let query = ArtworkQuery(departmentTitle: "Painting and Sculpture of Europe")

        let request = try #require(
            ArtworkRequestBuilder.listRequest(query: query, userAgent: userAgent)
        )
        let url = try #require(request.url)

        #expect(url.absoluteString.contains("Painting%20and%20Sculpture%20of%20Europe"))
    }

    @Test("AIC-User-Agentヘッダが付与される")
    func setsUserAgentHeader() throws {
        let request = try #require(
            ArtworkRequestBuilder.listRequest(query: ArtworkQuery(), userAgent: userAgent)
        )

        #expect(request.value(forHTTPHeaderField: "AIC-User-Agent") == userAgent)
    }

    @Test("詳細リクエストのパスに作品IDが含まれる")
    func buildsDetailRequest() throws {
        let request = try #require(
            ArtworkRequestBuilder.detailRequest(id: 27992, userAgent: userAgent)
        )
        let url = try #require(request.url)

        #expect(url.path() == "/api/v1/artworks/27992")
    }
}
