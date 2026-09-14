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
    
    /// 詳細画面の生成口。実体は合成ルートが注入する。
    /// この画面は `ScreenArtworkDetail` を import せず、
    /// 「詳細画面を作る何か」を protocol 越しにしか知らない。
    private let detailScreenBuilder: any ArtworkDetailScreenBuilding

    public init(
        repository: any ArtworkRepository,
        query: ArtworkQuery = .init(),
        detailScreenBuilder: any ArtworkDetailScreenBuilding
    ) {
        _viewModel = State(
            initialValue: ArtworkListViewModel(repository: repository, query: query)
        )
        self.detailScreenBuilder = detailScreenBuilder
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GalleryColor.background)
            .navigationTitle(ArtworkListStrings.navigationTitle)
            // 経路の値は Artwork.ID（= Int）。今回 push する値が1種類なので成立する。
            // 経路が増えるなら専用の Route 型を切る必要がある。
            .navigationDestination(for: Artwork.ID.self) { artworkID in
                detailScreenBuilder.build(artworkID: artworkID)
            }
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
                    NavigationLink(value: artwork.id) {
                        ArtworkGridCell(artwork: artwork)
                    }
                    // 既定のスタイルだとセル内の文字が全てアクセントカラーになる。
                    .buttonStyle(.plain)
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
            repository: StubArtworkRepository(behavior: .success(.preview)),
            detailScreenBuilder: StubArtworkDetailScreenBuilder()
        )
    }
}

#Preview("一覧 / 文字拡大 AX3") {
    NavigationStack {
        ArtworkListScreen(
            repository: StubArtworkRepository(behavior: .success(.preview)),
            detailScreenBuilder: StubArtworkDetailScreenBuilder()
        )
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("空") {
    NavigationStack {
        ArtworkListScreen(
            repository: StubArtworkRepository(behavior: .success(.empty)),
            detailScreenBuilder: StubArtworkDetailScreenBuilder()
        )
    }
}

#Preview("エラー") {
    NavigationStack {
        ArtworkListScreen(
            repository: StubArtworkRepository(behavior: .failure(.offline)),
            detailScreenBuilder: StubArtworkDetailScreenBuilder()
        )
    }
}

#Preview("ローディング") {
    NavigationStack {
        ArtworkListScreen(
            repository: StubArtworkRepository(behavior: .pending),
            detailScreenBuilder: StubArtworkDetailScreenBuilder()
        )
    }
}
