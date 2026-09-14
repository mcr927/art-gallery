import CoreGraphics

/// 余白の基準値。4ptグリッド。
///
/// 画面モジュール側でマジックナンバーを書かせないための最小限の語彙。
public enum GallerySpacing {
    /// 4pt。アイコンとラベルなど、密接した要素間。
    public static let xs: CGFloat = 4
    /// 8pt。タイトルとサブタイトルなど、同一グループ内。
    public static let s: CGFloat = 8
    /// 16pt。画面の標準マージン、グリッドの列間。
    public static let m: CGFloat = 16
    /// 24pt。セクション間。
    public static let l: CGFloat = 24
    /// 32pt。空状態のアイコンまわりなど、意図的に広く取る箇所。
    public static let xl: CGFloat = 32
}
