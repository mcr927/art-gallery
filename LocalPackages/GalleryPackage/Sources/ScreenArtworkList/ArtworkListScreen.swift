import DesignSystem
import Interfaces
import Models
import SwiftUI
import TestSupport

/// 作品一覧画面。
///
/// このモジュールが外部に公開するのはこの `init` ひとつだけで、
/// ViewModel もセルも internal に閉じている。
/// 依存は `ArtworkRepository`（protocol）で受け取り、実体は合成ルートが注入する。
/// この画面は `APIClient` を import しないため、通信の実装を差し替えても再コンパイルされない。
///
/// `NavigationStack` は持たない。遷移の器はアプリターゲットの責務とし、
/// ここでは `navigationTitle` の指定までを行う。
public struct ArtworkListScreen: View {

    @State private var viewModel: ArtworkListViewModel

    /// グリッド1列の最小幅。
    ///
    /// `@ScaledMetric` を通すことで、文字サイズの拡大に応じて最小幅も広がり、
    /// 結果として列数が自然に減る。
    /// `horizontalSizeClass` による分岐を書かずに、
    /// 画面幅と Dynamic Type の両方へ追従させるための選択。
    @ScaledMetric(relativeTo: .headline) private var cellMinWidth: CGFloat = 160

    public init(repository: any ArtworkRepository, query: ArtworkQuery = .init()) {
        _viewModel = State(
            initialValue: ArtworkListViewModel(repository: repository, query: query)
        )
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GalleryColor.background)
            .navigationTitle(ArtworkListStrings.navigationTitle)
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .tint(GalleryColor.brandPrimary)
                .accessibilityLabel(ArtworkListStrings.loading)

        case .loaded(let page):
            grid(items: page.items)

        case .empty:
            GalleryMessageView(
                title: ArtworkListStrings.emptyTitle,
                message: ArtworkListStrings.emptyMessage,
                systemImage: "photo.on.rectangle.angled"
            )

        case .failed(let error):
            GalleryMessageView(
                title: ArtworkListStrings.errorTitle,
                message: ArtworkListStrings.errorMessage(for: error),
                systemImage: "exclamationmark.triangle",
                action: .init(title: ArtworkListStrings.retry) {
                    Task { await viewModel.load() }
                }
            )
        }
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: cellMinWidth), spacing: GallerySpacing.m)]
    }

    private func grid(items: [Artwork]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: GallerySpacing.m) {
                ForEach(items) { artwork in
                    ArtworkGridCell(artwork: artwork)
                }
            }
            .padding(GallerySpacing.m)
        }
        .refreshable { await viewModel.reload() }
    }
}

#Preview("一覧") {
    NavigationStack {
        ArtworkListScreen(
            repository: StubArtworkRepository(behavior: .success(.preview))
        )
    }
}

#Preview("一覧 / 文字拡大 AX3") {
    NavigationStack {
        ArtworkListScreen(
            repository: StubArtworkRepository(behavior: .success(.preview))
        )
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("空") {
    NavigationStack {
        ArtworkListScreen(
            repository: StubArtworkRepository(behavior: .success(.empty))
        )
    }
}

#Preview("エラー") {
    NavigationStack {
        ArtworkListScreen(
            repository: StubArtworkRepository(behavior: .failure(.offline))
        )
    }
}

#Preview("ローディング") {
    NavigationStack {
        ArtworkListScreen(
            repository: StubArtworkRepository(behavior: .pending)
        )
    }
}
