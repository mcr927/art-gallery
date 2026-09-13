import SwiftUI

/// 画面全体を占めるメッセージ表示。空状態・エラー状態で共用する。
///
/// 中身は `ContentUnavailableView` に委譲している。
/// レイアウト、Dynamic Type、VoiceOverでの読み上げ順序は標準実装のほうが正しく、
/// 自前で組み直す理由がないため。
/// このラッパが担うのは、テナントのブランドカラーとリトライ導線を
/// 1箇所に閉じることだけ。
public struct GalleryMessageView: View {

    private let title: String
    private let message: String?
    private let systemImage: String
    private let action: Action?

    /// 任意のアクション。エラー状態では再試行、空状態では省略する想定。
    public struct Action {
        public let title: String
        public let handler: () -> Void

        public init(title: String, handler: @escaping () -> Void) {
            self.title = title
            self.handler = handler
        }
    }

    public init(
        title: String,
        message: String? = nil,
        systemImage: String,
        action: Action? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        ContentUnavailableView {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(GalleryColor.brandPrimary)
            }
        } description: {
            if let message {
                Text(message)
            }
        } actions: {
            if let action {
                Button(action.title, action: action.handler)
                    .buttonStyle(.borderedProminent)
                    .tint(GalleryColor.brandPrimary)
            }
        }
    }
}

#Preview("Error") {
    GalleryMessageView(
        title: "作品を読み込めませんでした",
        message: "通信状況を確認して、もう一度お試しください。",
        systemImage: "exclamationmark.triangle",
        action: .init(title: "再試行", handler: {})
    )
}

#Preview("Empty") {
    GalleryMessageView(
        title: "作品がありません",
        systemImage: "photo.on.rectangle.angled"
    )
}
