import Foundation
import Models

extension ArtworkPage {
    /// 6件・次ページありのページ。
    public static let preview = ArtworkPage(items: Artwork.previews, nextPage: 2)

    /// 6件・最終ページ。
    public static let previewLastPage = ArtworkPage(items: Artwork.previews, nextPage: nil)

    /// 空状態の確認用。
    public static let empty = ArtworkPage(items: [], nextPage: nil)
}
