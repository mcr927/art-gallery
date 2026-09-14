import Models

/// 一覧画面の表示文言。
///
/// テナントごとの差し替え（`String(localized:bundle: .main)` と
/// アプリターゲット側の Localizable）は今回は行わず、
/// 差し替え対象をこの1ファイルに集約するところまでに留めている。
enum ArtworkListStrings {

    static let navigationTitle = "作品一覧"

    static let loading = "読み込み中"

    static let emptyTitle = "作品がありません"
    static let emptyMessage = "この部門で表示できる作品が見つかりませんでした。"

    static let errorTitle = "作品を読み込めませんでした"
    static let retry = "再試行"

    /// エラーの種類ごとに、利用者が次に取れる行動が変わる文言を返す。
    static func errorMessage(for error: ArtworkRepositoryError) -> String {
        switch error {
        case .offline:
            "通信状況を確認して、もう一度お試しください。"
        case .server(let statusCode):
            "サーバーが応答しませんでした。（\(statusCode)）"
        case .decoding:
            "データの形式が想定と異なります。時間をおいても解消しない場合があります。"
        case .cancelled, .unknown:
            "しばらく時間をおいて、もう一度お試しください。"
        }
    }
}
