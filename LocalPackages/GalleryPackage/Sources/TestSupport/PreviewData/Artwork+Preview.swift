import Foundation
import Models

extension ArtworkImage {
    /// Art Institute of Chicago の IIIF エンドポイント。
    static let previewBaseURL = URL(string: "https://www.artic.edu/iiif/2")!

    static func preview(
        identifier: String,
        altText: String?,
        pixelWidth: Int? = 1686,
        pixelHeight: Int? = 1254
    ) -> ArtworkImage {
        ArtworkImage(
            identifier: identifier,
            baseURL: previewBaseURL,
            altText: altText,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight
        )
    }
}

extension Artwork {

    // MARK: - 標準ケース

    public static let preview = Artwork(
        id: 27992,
        title: "A Sunday on La Grande Jatte — 1884",
        image: .preview(
            identifier: "2d484387-2509-5e8e-2c43-22f9981972eb",
            altText: "点描で描かれた、島の芝生でくつろぐ人々"
        ),
        artistName: "Georges Seurat",
        dateDisplay: "1884–86",
        departmentTitle: "Painting and Sculpture of Europe",
        summary: "スーラが点描技法を確立した代表作。2年以上を費やして制作された。"
    )

    /// タイトルが長く、Dynamic Type 拡大時のレイアウト崩れを検出するためのケース。
    public static let previewLongTitle = Artwork(
        id: 64818,
        title: "Paris Street; Rainy Day (Rue de Paris, temps de pluie) — 印象派を代表する大画面作品",
        image: .preview(
            identifier: "a38e2828-ec6f-ece1-a30f-70243449197b",
            altText: "雨の降るパリの交差点を傘をさして歩く人々"
        ),
        artistName: "Gustave Caillebotte",
        dateDisplay: "1877",
        departmentTitle: "Painting and Sculpture of Europe",
        summary: "オスマン改造後のパリの街路を、写真的な構図で描いた作品。"
    )

    /// 作者・制作年が欠落しているケース。詳細画面の欠損表示の確認に使う。
    public static let previewMissingMetadata = Artwork(
        id: 111628,
        title: "Nighthawks",
        image: .preview(
            identifier: "831a05de-d3f6-f4fa-a460-23008dd58dda",
            altText: "深夜のダイナーのカウンターに座る3人の客"
        ),
        artistName: nil,
        dateDisplay: nil,
        departmentTitle: "Arts of the Americas",
        summary: nil
    )

    /// 概要文のみ欠落しているケース。
    public static let previewNoSummary = Artwork(
        id: 6565,
        title: "American Gothic",
        image: .preview(
            identifier: "b272df73-a965-ac37-4172-be4e99483637",
            altText: "熊手を持つ農夫と、その隣に立つ女性"
        ),
        artistName: "Grant Wood",
        dateDisplay: "1930",
        departmentTitle: "Arts of the Americas",
        summary: nil
    )

    /// 縦長画像。グリッドのアスペクト比処理の確認に使う。
    public static let previewPortrait = Artwork(
        id: 20684,
        title: "The Old Guitarist",
        image: .preview(
            identifier: "f8fd76e9-c396-5678-36ed-6a348c904d27",
            altText: "青い色調で描かれた、ギターを抱える痩せた老人",
            pixelWidth: 1554,
            pixelHeight: 2396
        ),
        artistName: "Pablo Picasso",
        dateDisplay: "1903–4",
        departmentTitle: "Painting and Sculpture of Europe",
        summary: "青の時代の代表作。"
    )

    /// altText が欠落しているケース。VoiceOver のフォールバック確認に使う。
    public static let previewNoAltText = Artwork(
        id: 28560,
        title: "The Bedroom",
        image: .preview(
            identifier: "6644829f-f292-c5c4-a73c-0356a6fdbf0d",
            altText: nil
        ),
        artistName: "Vincent van Gogh",
        dateDisplay: "1889",
        departmentTitle: "Painting and Sculpture of Europe",
        summary: "アルルの寝室を描いた3点のうちの1点。"
    )

    /// 一覧表示用の6件。
    public static let previews: [Artwork] = [
        .preview,
        .previewLongTitle,
        .previewMissingMetadata,
        .previewNoSummary,
        .previewPortrait,
        .previewNoAltText
    ]
}
