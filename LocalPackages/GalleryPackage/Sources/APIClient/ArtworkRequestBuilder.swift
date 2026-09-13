import Foundation
import Models

/// `ArtworkQuery` から `URLRequest` を組み立てる名前空間。
/// 送信は行わず、入力から出力が一意に決まる純粋関数のみを置く。
enum ArtworkRequestBuilder {

    static let defaultBaseURL = URL(string: "https://api.artic.edu/api/v1")!

    /// DTO のデコードに必要なフィールドのみを要求する。
    /// 匿名アクセスは 60 req/min のため、レスポンスサイズを抑える意図もある。
    private static let requestedFields = [
        "id",
        "title",
        "image_id",
        "artist_title",
        "date_display",
        "department_title",
        "thumbnail",
    ].joined(separator: ",")

    /// 一覧・検索リクエスト。
    ///
    /// 部門での絞り込みを行うため、フィルタの有無にかかわらず
    /// `/artworks/search` を用いる。
    static func listRequest(
        query: ArtworkQuery,
        baseURL: URL = defaultBaseURL,
        userAgent: String
    ) -> URLRequest? {
        let url = baseURL.appending(path: "artworks/search")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        var items: [URLQueryItem] = [
            URLQueryItem(name: "fields", value: requestedFields),
            URLQueryItem(name: "page", value: String(query.page)),
            URLQueryItem(name: "limit", value: String(query.pageSize)),
        ]

        if let department = query.departmentTitle {
            // 解析済みフィールドでは多語の値が一致しないため keyword サブフィールドを使う。
            items.append(
                URLQueryItem(name: "query[term][department_title.keyword]", value: department)
            )
        }

        components.queryItems = items

        guard let composed = components.url else { return nil }
        return request(for: composed, userAgent: userAgent)
    }

    /// 詳細リクエスト。
    static func detailRequest(
        id: Artwork.ID,
        baseURL: URL = defaultBaseURL,
        userAgent: String
    ) -> URLRequest? {
        let url = baseURL.appending(path: "artworks/\(id)")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = [
            URLQueryItem(name: "fields", value: requestedFields)
        ]

        guard let composed = components.url else { return nil }
        return request(for: composed, userAgent: userAgent)
    }

    private static func request(for url: URL, userAgent: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // 匿名アクセス時に要求されるヘッダ。
        request.setValue(userAgent, forHTTPHeaderField: "AIC-User-Agent")
        return request
    }
}
