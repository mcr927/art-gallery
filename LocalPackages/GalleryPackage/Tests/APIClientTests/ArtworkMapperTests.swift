import Foundation
import Testing
@testable import APIClient
import Models

@Suite("ArtworkMapper")
struct ArtworkMapperTests {

    // MARK: - Fixtures

    /// 実レスポンスから必要なフィールドのみを抜いたもの。
    private func listJSON(
        artworks: String,
        currentPage: Int = 1,
        totalPages: Int = 3,
        iiifURL: String = "https://www.artic.edu/iiif/2"
    ) -> Data {
        """
        {
          "pagination": {
            "current_page": \(currentPage),
            "total_pages": \(totalPages)
          },
          "data": [\(artworks)],
          "config": {
            "iiif_url": "\(iiifURL)"
          }
        }
        """.data(using: .utf8)!
    }

    private let artworkWithImage = """
    {
      "id": 27992,
      "title": "A Sunday on La Grande Jatte",
      "image_id": "1adf2696-8489-499b-cad2-821d7fde4b33",
      "artist_title": "Georges Seurat",
      "date_display": "1884-86",
      "department_title": "Painting and Sculpture of Europe",
      "short_description": "A painting.",
      "thumbnail": {
        "alt_text": "A vast park is populated by figures.",
        "width": 8330,
        "height": 5545
      }
    }
    """

    private let anotherArtworkWithImage = """
    {
      "id": 28560,
      "title": "The Bedroom",
      "image_id": "25c31d8d-21a4-9ea1-1d73-6a2eca4dda7e",
      "artist_title": "Vincent van Gogh",
      "date_display": "1889",
      "department_title": "Painting and Sculpture of Europe",
      "short_description": "A painting.",
      "thumbnail": {
        "alt_text": "Painting of a bedroom.",
        "width": 5376,
        "height": 4192
      }
    }
    """

    private let artworkWithoutImage = """
    {
      "id": 99999,
      "title": "Untitled",
      "image_id": null,
      "artist_title": null,
      "date_display": null,
      "department_title": null,
      "short_description": null,
      "thumbnail": null
    }
    """

    private func decodeList(_ data: Data) throws -> ArtworkListResponseDTO {
        try JSONDecoder.gallery.decode(ArtworkListResponseDTO.self, from: data)
    }

    // MARK: - Tests

    @Test("画像を持つ作品がすべて変換される")
    func mapsArtworksWithImage() throws {
        let response = try decodeList(
            listJSON(artworks: "\(artworkWithImage),\(anotherArtworkWithImage)")
        )

        let page = try ArtworkMapper.page(from: response)

        #expect(page.items.count == 2)
        #expect(page.items.first?.id == 27992)
        #expect(page.items.first?.title == "A Sunday on La Grande Jatte")
        #expect(page.items.first?.artistName == "Georges Seurat")
        #expect(page.items.first?.image.identifier == "1adf2696-8489-499b-cad2-821d7fde4b33")
        #expect(page.items.first?.image.pixelWidth == 8330)
        #expect(page.items.first?.summary == "A painting.")
    }

    @Test("画像を持たない作品は取り除かれ、次ページ番号には影響しない")
    func dropsArtworksWithoutImage() throws {
        let response = try decodeList(
            listJSON(artworks: "\(artworkWithImage),\(artworkWithoutImage)")
        )

        let page = try ArtworkMapper.page(from: response)

        #expect(page.items.count == 1)
        #expect(page.items.first?.id == 27992)
        // 件数が pageSize を下回っても最終ページ扱いにはしない
        #expect(page.nextPage == 2)
    }

    @Test("テスト環境のIIIFホストは本番に正規化される")
    func normalizesTestIIIFHost() throws {
        let response = try decodeList(
            listJSON(
                artworks: artworkWithImage,
                iiifURL: "https://www-test.artic.edu/iiif/2"
            )
        )

        let page = try ArtworkMapper.page(from: response)

        #expect(page.items.first?.image.baseURL.absoluteString == "https://www.artic.edu/iiif/2")
    }

    @Test("正常なIIIFホストはそのまま使われる")
    func keepsValidIIIFHost() throws {
        let response = try decodeList(listJSON(artworks: artworkWithImage))

        let page = try ArtworkMapper.page(from: response)

        #expect(page.items.first?.image.baseURL.absoluteString == "https://www.artic.edu/iiif/2")
    }

    @Test("最終ページでは次ページ番号がnilになる")
    func returnsNilNextPageOnLastPage() throws {
        let response = try decodeList(
            listJSON(artworks: artworkWithImage, currentPage: 3, totalPages: 3)
        )

        let page = try ArtworkMapper.page(from: response)

        #expect(page.nextPage == nil)
    }
}
