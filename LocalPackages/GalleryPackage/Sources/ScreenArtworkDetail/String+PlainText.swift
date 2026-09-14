import Foundation

extension String {

    /// HTMLタグと主要な文字実体参照を取り除く。
    ///
    /// `Artwork.summary` は API の `short_description` 由来で、
    /// ほとんどはプレーンテキストだが稀にタグを含む。
    /// Models 側で「表示側で整形する前提」と宣言している以上、
    /// 表示側に最小限の整形を置いておく。
    ///
    /// `NSAttributedString(data:options:.html)` を使えば正確に解釈できるが、
    /// WebKit を起動するため表示のたびに数十msかかる。
    /// 短い説明文1行のために払うコストとしては見合わないと判断した。
    var strippingHTMLTags: String {
        let withoutTags = replacing(/<[^>]+>/, with: "")

        return withoutTags
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            // &amp; は最後に処理する。先に戻すと "&amp;lt;" が "<" になってしまう。
            .replacingOccurrences(of: "&amp;", with: "&")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
