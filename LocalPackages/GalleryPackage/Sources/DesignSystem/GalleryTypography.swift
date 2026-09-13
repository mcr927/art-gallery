import SwiftUI

/// アプリ全体で使うテキストスタイル。
///
/// 独自のポイントサイズは定義せず、システムのテキストスタイルに
/// 用途ベースの名前を与えるだけに留めている。
/// `.system(size:)` で固定サイズを切ると Dynamic Type に追従しなくなるため、
/// 「意味 → システムスタイル」の対応表としてだけ機能させる。
public enum GalleryTypography {

    /// 詳細画面の作品タイトル。画面内で最も強い階層。
    public static let screenTitle: Font = .largeTitle.weight(.bold)

    /// 一覧セルの作品タイトル。
    public static let cardTitle: Font = .headline

    /// 作家名・制作年など、タイトルに従属する情報。
    public static let cardSubtitle: Font = .subheadline

    /// 詳細画面の解説文。
    public static let body: Font = .body

    /// 媒体・寸法・所蔵元などのメタ情報。
    public static let caption: Font = .caption
}
