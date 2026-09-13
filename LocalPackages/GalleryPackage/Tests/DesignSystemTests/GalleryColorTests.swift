import Testing
import UIKit
@testable import DesignSystem

@Suite("色の解決")
struct GalleryColorTests {

    /// テストバンドルの `Bundle.main` は xctest ランナーを指すため、
    /// アプリターゲットのAssetは見えない。
    /// この文脈では Package 側のデフォルトに落ちることを保証する。
    @Test("アプリのAssetが無い文脈ではPackageのデフォルトに落ちる")
    func resolvesToPackageDefault() {
        let resolved = GalleryColor.resolve(.brandPrimary)
        #expect(resolved.source == .package)
    }

    /// どちらのバンドルにも無い場合に、3段目まで到達すること。
    @Test("未定義の色名はハードコード値に落ちる")
    func resolvesToHardcodedFallback() {
        let sentinel = UIColor.magenta
        let resolved = GalleryColor.resolve(name: "NoSuchColor", fallback: sentinel)
        #expect(resolved.source == .fallback)
        #expect(resolved.color == sentinel)
    }

    /// Token に増えた色の解決漏れを防ぐ。
    /// 追加した色のAssetを置き忘れると `.fallback` になって気づけるようにしてある。
    @Test("すべてのTokenがAsset Catalogから解決できる", arguments: GalleryColor.Token.allCases)
    func everyTokenIsDefined(token: GalleryColor.Token) {
        #expect(GalleryColor.resolve(token).source != .fallback)
    }
}
