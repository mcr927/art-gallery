import Foundation

/// 作品画像。IIIF Image API 2.0 の URL 組み立て規約をこの型が担う。
///
/// ベースURL（`config.iiif_url`）はレスポンスごとに返る通信層の情報のため、
/// APIClient が注入する。どのサイズを要求するかは表示側の関心事なので、
/// computed property ではなく引数付きの method として公開している。
public struct ArtworkImage: Hashable, Sendable {

    /// 要求する画像の横幅。数値はいずれも AIC 側でキャッシュに乗りやすいサイズ。
    public enum Size: Int, Sendable, CaseIterable {
        case thumbnail = 200
        case small = 400
        case medium = 600
        case large = 843
    }

    /// `image_id`。IIIF の identifier に相当する。
    public let identifier: String

    /// `config.iiif_url`。末尾にスラッシュを含まない前提。
    public let baseURL: URL

    /// 美術館が用意した画像説明文。`thumbnail.alt_text` 由来。
    /// VoiceOver の読み上げにそのまま利用する。
    public let altText: String?

    /// 原本のピクセルサイズ。`thumbnail.width` / `height` 由来。
    public let pixelWidth: Int?
    public let pixelHeight: Int?

    public init(
        identifier: String,
        baseURL: URL,
        altText: String? = nil,
        pixelWidth: Int? = nil,
        pixelHeight: Int? = nil
    ) {
        self.identifier = identifier
        self.baseURL = baseURL
        self.altText = altText
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }

    /// IIIF Image API 2.0 の URL を組み立てる。
    /// 形式は `{base}/{identifier}/{region}/{size}/{rotation}/{quality}.{format}`。
    /// region は全体、rotation は 0、quality と format は既定値で固定している。
    public func url(_ size: Size) -> URL {
        baseURL
            .appending(path: identifier)
            .appending(path: "full")
            .appending(path: "\(size.rawValue),")
            .appending(path: "0")
            .appending(path: "default.jpg")
    }

    /// 横 / 縦。グリッドや詳細画面でレイアウトを確定させるために使う。
    /// 寸法が欠けている場合は nil。
    public var aspectRatio: Double? {
        guard let pixelWidth, let pixelHeight, pixelHeight > 0 else { return nil }
        return Double(pixelWidth) / Double(pixelHeight)
    }
}
