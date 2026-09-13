import Foundation

// MARK: - Response Roots

/// `GET /artworks` および `GET /artworks/search` のレスポンス
struct ArtworkListResponseDTO: Decodable, Sendable {
    let data: [ArtworkDTO]
    let pagination: PaginationDTO
    let config: ConfigDTO
}

/// `GET /artworks/{id}` のレスポンス
struct ArtworkDetailResponseDTO: Decodable, Sendable {
    let data: ArtworkDTO
    let config: ConfigDTO
}

// MARK: - Artwork

struct ArtworkDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let imageId: String?
    let artistTitle: String?
    let dateDisplay: String?
    let departmentTitle: String?
    let shortDescription: String?
    let thumbnail: ThumbnailDTO?
}

struct ThumbnailDTO: Decodable, Sendable {
    let altText: String?
    let width: Int?
    let height: Int?
}

// MARK: - Metadata

struct PaginationDTO: Decodable, Sendable {
    let currentPage: Int
    let totalPages: Int
}

struct ConfigDTO: Decodable, Sendable {
    let iiifUrl: String
}
