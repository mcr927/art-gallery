import Foundation
import Testing
@testable import APIClient
import Models

@Suite("ArtworkImage URL")
struct ArtworkImageURLTests {

    @Test("IIIFのサイズ指定に含まれるカンマがエスケープされない")
    func doesNotEscapeCommaInPath() throws {
        // 本来 ModelsTests に置くべきだが、期限の都合で APIClientTests に間借りしている。
        let image = ArtworkImage(
            identifier: "abc-123",
            baseURL: URL(string: "https://www.artic.edu/iiif/2")!,
            altText: nil,
            pixelWidth: nil,
            pixelHeight: nil
        )

        let url = image.url(.large)

        #expect(!url.absoluteString.contains("%2C"))
        #expect(url.absoluteString == "https://www.artic.edu/iiif/2/abc-123/full/843,/0/default.jpg")
    }
}
