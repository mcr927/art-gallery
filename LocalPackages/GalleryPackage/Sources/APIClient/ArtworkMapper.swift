import Foundation
import Models

/// DTO からドメインモデルへの変換を担う名前空間。
/// ネットワークやデコードには関与せず、入力から出力が一意に決まる純粋関数のみを置く。
enum ArtworkMapper {

    /// API が返す IIIF ベース URL のうち、テスト環境のホストを本番に正規化する。
    ///
    /// `config.iiif_url` はドキュメントの例やレスポンスによって
    /// `www-test.artic.edu` を返すことがあり、そのままでは画像が取得できない。
    static func normalizedIIIFBaseURL(from config: ConfigDTO) -> URL? {
        guard let url = URL(string: config.iiifUrl) else { return nil }
        guard let host = url.host(), host.contains("www-test.artic.edu") else { return url }
        return URL(string: "https://www.artic.edu/iiif/2")
    }

    /// 単一の作品を変換する。画像を持たない作品は `nil` を返す。
    ///
    /// `Artwork.image` が非オプショナルであるため、`imageId` を持たない作品は
    /// ドメインモデルとして表現できない。これは API の正常な応答であり
    /// エラーではないので、throw せず呼び出し側で取り除く。
    static func artwork(from dto: ArtworkDTO, iiifBaseURL: URL) -> Artwork? {
        guard let imageId = dto.imageId else { return nil }

        let image = ArtworkImage(
            identifier: imageId,
            baseURL: iiifBaseURL,
            altText: dto.thumbnail?.altText,
            pixelWidth: dto.thumbnail?.width,
            pixelHeight: dto.thumbnail?.height
        )

        return Artwork(
            id: dto.id,
            title: dto.title,
            image: image,
            artistName: dto.artistTitle,
            dateDisplay: dto.dateDisplay,
            departmentTitle: dto.departmentTitle,
            summary: dto.shortDescription
        )
    }

    /// 一覧レスポンスをページに変換する。
    static func page(from response: ArtworkListResponseDTO) throws(ArtworkRepositoryError) -> ArtworkPage {
        guard let baseURL = normalizedIIIFBaseURL(from: response.config) else {
            throw .decoding
        }

        let items = response.data.compactMap { artwork(from: $0, iiifBaseURL: baseURL) }

        return ArtworkPage(
            items: items,
            nextPage: nextPage(from: response.pagination)
        )
    }

    /// 詳細レスポンスを変換する。
    static func artwork(from response: ArtworkDetailResponseDTO) throws(ArtworkRepositoryError) -> Artwork {
        guard let baseURL = normalizedIIIFBaseURL(from: response.config) else {
            throw .decoding
        }
        guard let artwork = artwork(from: response.data, iiifBaseURL: baseURL) else {
            throw .decoding
        }
        return artwork
    }

    /// 次ページ番号。
    ///
    /// 画像なし作品を取り除いた結果 `items.count` は `pageSize` を下回るため、
    /// 件数からの判定は行わずページ情報のみを根拠にする。
    static func nextPage(from pagination: PaginationDTO) -> Int? {
        pagination.currentPage < pagination.totalPages
            ? pagination.currentPage + 1
            : nil
    }
}
