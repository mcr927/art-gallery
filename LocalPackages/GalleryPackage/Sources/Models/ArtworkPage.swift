import Foundation

/// 作品一覧の1ページ分。
///
/// API が返す `current_page` / `total_pages` をそのまま公開せず、
/// 「次があるか、あるなら何ページ目か」に畳んで渡す。
/// 一覧エンドポイントと検索エンドポイントでページング情報の形が異なるため、
/// その差異を APIClient 側に閉じ込める意図もある。
public struct ArtworkPage: Hashable, Sendable {

    /// このページに含まれる作品。
    /// 画像を持たない作品は APIClient のマッピング段階で除外されるため、
    /// API の応答件数より少なくなることがある。
    public let items: [Artwork]

    /// 次ページの番号。終端の場合は nil。
    public let nextPage: Int?

    public init(items: [Artwork], nextPage: Int?) {
        self.items = items
        self.nextPage = nextPage
    }
}
