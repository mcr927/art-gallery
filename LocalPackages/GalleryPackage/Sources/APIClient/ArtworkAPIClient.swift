import Foundation
import Interfaces
import Models

public struct ArtworkAPIClient: ArtworkRepository {

    private let httpClient: any HTTPFetching
    private let baseURL: URL
    private let userAgent: String

    /// テナントの概念は持たない。部門での絞り込みは合成ルートが
    /// ArtworkQuery.departmentTitle に詰める責務とする。
    public init(
        baseURL: URL? = nil,
        userAgent: String = "art-gallery"
    ) {
        self.init(
            httpClient: URLSessionHTTPClient(),
            baseURL: baseURL,
            userAgent: userAgent
        )
    }

    init(
        httpClient: any HTTPFetching,
        baseURL: URL? = nil,
        userAgent: String = "art-gallery"
    ) {
        self.httpClient = httpClient
        self.baseURL = baseURL ?? ArtworkRequestBuilder.defaultBaseURL
        self.userAgent = userAgent
    }

    // MARK: - ArtworkRepository

    public func artworks(
        query: ArtworkQuery
    ) async throws(ArtworkRepositoryError) -> ArtworkPage {
        do {
            guard let request = ArtworkRequestBuilder.listRequest(
                query: query,
                baseURL: baseURL,
                userAgent: userAgent
            ) else {
                throw ArtworkRepositoryError.unknown
            }

            let response: ArtworkListResponseDTO = try await perform(request)
            return try ArtworkMapper.page(from: response)
        } catch {
            throw Self.mapped(error)
        }
    }

    public func artwork(
        id: Artwork.ID
    ) async throws(ArtworkRepositoryError) -> Artwork {
        do {
            guard let request = ArtworkRequestBuilder.detailRequest(
                id: id,
                baseURL: baseURL,
                userAgent: userAgent
            ) else {
                throw ArtworkRepositoryError.unknown
            }

            let response: ArtworkDetailResponseDTO = try await perform(request)
            return try ArtworkMapper.artwork(from: response)
        } catch {
            throw Self.mapped(error)
        }
    }

    // MARK: - Private

    /// 送信・ステータス検査・デコードまで。
    /// エラー型の変換は呼び出し側の catch で一度だけ行う。
    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await httpClient.data(for: request)

        guard (200..<300).contains(response.statusCode) else {
            throw ArtworkRepositoryError.server(statusCode: response.statusCode)
        }

        return try JSONDecoder.gallery.decode(T.self, from: data)
    }

    /// 発生しうるエラーを ArtworkRepositoryError に寄せる。
    private static func mapped(_ error: any Error) -> ArtworkRepositoryError {
        // Mapper や perform が投げたものはそのまま通す。
        // ここを忘れると .decoding が .unknown に潰れる。
        if let repositoryError = error as? ArtworkRepositoryError {
            return repositoryError
        }

        if error is CancellationError {
            return .cancelled
        }

        if error is DecodingError {
            return .decoding
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                return .offline
            case .cancelled:
                return .cancelled
            default:
                return .unknown
            }
        }

        return .unknown
    }
}
