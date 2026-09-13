import SwiftUI
import UIKit

/// アプリ全体で使う色。
///
/// テナントごとに差し替わるのは `brandPrimary` のみ。
/// それ以外はシステムのセマンティックカラーへ委譲し、
/// ダークモード・コントラスト設定への追従をOSに任せている。
public enum GalleryColor {

    // MARK: - テナント差し替え対象

    /// テナントのブランドカラー。
    ///
    /// `Bundle.main`（アプリターゲットのAsset）
    /// → `Bundle.module`（DesignSystemのデフォルト）
    /// → ハードコード値、の順に解決する。
    ///
    /// computed property にしているのは、解決結果をプロセス内で固定しないため。
    /// `static let` の場合、テストバンドルやプレビューのように
    /// `Bundle.main` がテナントAssetを持たない文脈で最初に触れると、
    /// その解決結果がプロセスの寿命の間ずっと残ってしまう。
    public static var brandPrimary: Color {
        Color(uiColor: resolve(.brandPrimary).color)
    }

    // MARK: - システムへの委譲

    public static var label: Color { .primary }
    public static var secondaryLabel: Color { .secondary }
    public static var background: Color { Color(uiColor: .systemBackground) }
    public static var separator: Color { Color(uiColor: .separator) }

    /// 画像の読み込み完了前に敷くプレースホルダ。
    public static var imagePlaceholder: Color { Color(uiColor: .secondarySystemFill) }
}

// MARK: - 解決ロジック

extension GalleryColor {

    /// Asset Catalogから引く色。テナントで差し替わりうるものだけをここに置く。
    enum Token: String, CaseIterable {
        case brandPrimary = "BrandPrimary"

        /// 3段目。どちらのバンドルにも見つからなかった場合に使う。
        var fallback: UIColor {
            switch self {
            case .brandPrimary:
                UIColor { @Sendable traits in
                    traits.userInterfaceStyle == .dark
                        ? UIColor(red: 0.682, green: 0.682, blue: 0.682, alpha: 1)
                        : UIColor(red: 0.545, green: 0.545, blue: 0.545, alpha: 1)
                }
            }
        }
    }

    /// 色がどの層から解決されたか。
    enum Source: Equatable {
        /// アプリターゲットのAsset（テナント固有）
        case app
        /// DesignSystemのAsset（Packageデフォルト）
        case package
        /// ハードコード値
        case fallback
    }

    static func resolve(_ token: Token) -> (color: UIColor, source: Source) {
        resolve(name: token.rawValue, fallback: token.fallback)
    }

    /// 名前指定版。存在しない色名に対する挙動をテストするために分けてある。
    static func resolve(
        name: String,
        fallback: @autoclosure () -> UIColor
    ) -> (color: UIColor, source: Source) {
        if let color = UIColor(named: name, in: .main, compatibleWith: nil) {
            return (color, .app)
        }
        if let color = UIColor(named: name, in: .module, compatibleWith: nil) {
            return (color, .package)
        }
        return (fallback(), .fallback)
    }
}

#Preview("BrandPrimary") {
    let resolved = GalleryColor.resolve(.brandPrimary)
    return VStack(spacing: 16) {
        RoundedRectangle(cornerRadius: 12)
            .fill(GalleryColor.brandPrimary)
            .frame(height: 120)
        Text(verbatim: "source: \(resolved.source)")
            .font(.footnote.monospaced())
            .foregroundStyle(GalleryColor.secondaryLabel)
    }
    .padding()
}
