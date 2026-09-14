import Models

/// 詳細画面の表示文言。一覧と同様、差し替え対象をこの1ファイルに集約する。
enum ArtworkDetailStrings {

    static let loading = "読み込み中"
    static let retry = "再試行"

    static let errorTitle = "作品を読み込めませんでした"
    static let notFoundTitle = "この作品は表示できません"
    static let notFoundMessage = "作品が削除されたか、公開されていない可能性があります。"

    /// 作家名と制作年を1行にまとめる。両方欠けている場合は行ごと省く。
    static func attribution(artistName: String?, dateDisplay: String?) -> String? {
        let parts = [artistName, dateDisplay].compactMap(\.self)
        return parts.isEmpty ? nil : parts.joined(separator: "・")
    }

    static func errorMessage(for error: ArtworkRepositoryError) -> String {
        switch error {
        case .offline:
            "通信状況を確認して、もう一度お試しください。"
        case .server(let statusCode):
            "サーバーが応答しませんでした。（\(statusCode)）"
        case .decoding:
            "データの形式が想定と異なります。"
        case .cancelled, .unknown:
            "しばらく時間をおいて、もう一度お試しください。"
        }
    }
}
