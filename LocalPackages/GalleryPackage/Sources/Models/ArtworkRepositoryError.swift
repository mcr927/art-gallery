import Foundation

/// Repository が投げ得るエラー。
///
/// 画面側でのエラー表示の出し分けに必要な粒度だけを定義する。
/// `URLError` や `DecodingError` をそのまま流さないことで、
/// 通信の実装詳細が画面モジュールに漏れることを防ぐ。
public enum ArtworkRepositoryError: Error, Hashable, Sendable {

    /// ネットワークに到達できない。再試行を促す表示が妥当なケース。
    case offline

    /// サーバーがエラーを返した。レート制限（429）もここに含まれる。
    case server(statusCode: Int)

    /// レスポンスの解釈に失敗した。再試行しても回復しないケース。
    case decoding

    /// 呼び出し側による中断。画面上はエラーとして扱わない。
    case cancelled

    /// 上記に分類できないもの。
    case unknown
}
