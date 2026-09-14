import DesignSystem
import Interfaces
import Models
import SwiftUI
import TestSupport

/// 作品詳細画面。
///
/// 一覧と同じく、公開するのは `init` ひとつだけ。
/// 一覧からは `ArtworkDetailScreenBuilding` 越しに生成されるため、
/// この型は一覧モジュールから直接参照されない。
public struct ArtworkDetailScreen: View {

    @State private var viewModel: ArtworkDetailViewModel

    public init(repository: any ArtworkRepository, artworkID: Artwork.ID) {
        _viewModel = State(
            initialValue: ArtworkDetailViewModel(repository: repository, artworkID: artworkID)
        )
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GalleryColor.background)
            // 本文に大きな作品名を置くため、ナビゲーションバーにはタイトルを出さない。
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .tint(GalleryColor.brandPrimary)
                .accessibilityLabel(ArtworkDetailStrings.loading)

        case .loaded(let artwork):
            detail(artwork)

        case .failed(.server(statusCode: 404)):
            // 404 は再試行しても回復しないため、リトライ導線を出さない。
            GalleryMessageView(
                title: ArtworkDetailStrings.notFoundTitle,
                message: ArtworkDetailStrings.notFoundMessage,
                systemImage: "questionmark.square.dashed"
            )

        case .failed(let error):
            GalleryMessageView(
                title: ArtworkDetailStrings.errorTitle,
                message: ArtworkDetailStrings.errorMessage(for: error),
                systemImage: "exclamationmark.triangle",
                action: .init(title: ArtworkDetailStrings.retry) {
                    Task { await viewModel.load() }
                }
            )
        }
    }

    private func detail(_ artwork: Artwork) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: GallerySpacing.l) {
                // 画像だけは画面幅いっぱいに置く。
                ArtworkHeroImage(image: artwork.image)

                VStack(alignment: .leading, spacing: GallerySpacing.l) {
                    VStack(alignment: .leading, spacing: GallerySpacing.s) {
                        Text(artwork.title)
                            .font(GalleryTypography.screenTitle)
                            .foregroundStyle(GalleryColor.label)

                        if let attribution = ArtworkDetailStrings.attribution(
                            artistName: artwork.artistName,
                            dateDisplay: artwork.dateDisplay
                        ) {
                            Text(attribution)
                                .font(GalleryTypography.cardSubtitle)
                                .foregroundStyle(GalleryColor.secondaryLabel)
                        }
                    }

                    if let summary = artwork.summary?.strippingHTMLTags, !summary.isEmpty {
                        Text(summary)
                            .font(GalleryTypography.body)
                            .foregroundStyle(GalleryColor.label)
                    }

                    if let department = artwork.departmentTitle {
                        Text(department)
                            .font(GalleryTypography.caption)
                            .foregroundStyle(GalleryColor.secondaryLabel)
                    }
                }
                .padding(.horizontal, GallerySpacing.m)
            }
            .padding(.bottom, GallerySpacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview("標準") {
    NavigationStack {
        ArtworkDetailScreen(
            repository: StubArtworkRepository(behavior: .success(.preview)),
            artworkID: Artwork.preview.id
        )
    }
}

#Preview("メタデータ欠落") {
    NavigationStack {
        ArtworkDetailScreen(
            repository: StubArtworkRepository(behavior: .success(.preview)),
            artworkID: Artwork.previewMissingMetadata.id
        )
    }
}

#Preview("縦長画像") {
    NavigationStack {
        ArtworkDetailScreen(
            repository: StubArtworkRepository(behavior: .success(.preview)),
            artworkID: Artwork.previewPortrait.id
        )
    }
}

#Preview("見つからない") {
    NavigationStack {
        ArtworkDetailScreen(
            repository: StubArtworkRepository(behavior: .success(.preview)),
            artworkID: 999_999
        )
    }
}

#Preview("エラー") {
    NavigationStack {
        ArtworkDetailScreen(
            repository: StubArtworkRepository(behavior: .failure(.offline)),
            artworkID: Artwork.preview.id
        )
    }
}

#Preview("ローディング") {
    NavigationStack {
        ArtworkDetailScreen(
            repository: StubArtworkRepository(behavior: .pending),
            artworkID: Artwork.preview.id
        )
    }
}
