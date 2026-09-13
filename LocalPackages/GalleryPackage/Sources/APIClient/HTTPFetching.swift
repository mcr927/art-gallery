import Foundation

/// HTTP 通信の抽象。テストでの差し替えのために APIClient 内部に閉じる。
///
/// URLProtocol によるスタブは Swift 6 の strict concurrency 下で
/// 共有可変状態の扱いが煩雑になるため採用していない。
protocol HTTPFetching: Sendable {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

/// 本番実装。
///
/// URLSession に直接 HTTPFetching を適合させると retroactive conformance に
/// なるため、ラッパを用意している。HTTPURLResponse へのキャストも
/// ここ1箇所に閉じられる。
struct URLSessionHTTPClient: HTTPFetching {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, httpResponse)
    }
}
