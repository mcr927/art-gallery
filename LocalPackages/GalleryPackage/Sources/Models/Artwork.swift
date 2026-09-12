import Foundation

/// 作品1件を表す値型。
/// このモジュールは Foundation 以外に依存しない。
public struct Artwork: Identifiable, Hashable, Sendable {

    public let id: Int

    /// 作品名。APIでは必ず返るため非オプショナル。
    public let title: String

    /// 作家名。`artist_title` 由来。無所属・作者不詳の作品では nil。
    public let artistName: String?

    /// 制作年の表示用文字列。`date_display` 由来。
    /// "1884–86" や "c. 1650" のような非構造データのため、日付型には落とさない。
    public let dateDisplay: String?

    /// 所蔵部門。`department_title` 由来。テナントの絞り込みキーと対応する。
    public let departmentTitle: String?

    /// 画像情報。画像を持たない作品は APIClient のマッピング段階で除外するため、
    /// このモジュールでは常に存在することを保証する。
    public let image: ArtworkImage

    /// 解説文。`description` 由来だが、`CustomStringConvertible` との混同を避けて改名している。
    /// HTMLタグを含む場合があるため、表示側で整形する前提。
    public let summary: String?

    public init(
        id: Int,
        title: String,
        image: ArtworkImage,
        artistName: String? = nil,
        dateDisplay: String? = nil,
        departmentTitle: String? = nil,
        summary: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.dateDisplay = dateDisplay
        self.departmentTitle = departmentTitle
        self.image = image
        self.summary = summary
    }
}
