import DesignSystem
import Models
import SwiftUI
import TestSupport

/// グリッド1マス。表示のみを担い、タップの扱いは持たない。
///
/// 選択と遷移は #9 で `NavigationLink(value:)` にこのセルを包む形で外から与える。
/// セルが遷移を知らないことで、一覧モジュールは詳細画面の存在を知らずに済む。
struct ArtworkGridCell: View {

    let artwork: Artwork

    var body: some View {
        VStack(alignment: .leading, spacing: GallerySpacing.xs) {
            ArtworkThumbnail(image: artwork.image, size: .small)

            Text(artwork.title)
                .font(GalleryTypography.cardTitle)
                .foregroundStyle(GalleryColor.label)
                // reservesSpace により、タイトルが1行の作品でもセル高が揃う。
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)

            // 作家名が無い作品でも行の高さを確保し、グリッドの行間を一定に保つ。
            Text(artwork.artistName ?? "")
                .font(GalleryTypography.cardSubtitle)
                .foregroundStyle(GalleryColor.secondaryLabel)
                .lineLimit(1, reservesSpace: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // 画像・タイトル・作家名を1要素として読み上げる。
        // children: .combine ではなく .ignore にして、読み上げ順と内容を明示的に決める。
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    /// 作品名、作家名、画像の説明文の順に連結する。
    /// altText は美術館が用意した説明文（`thumbnail.alt_text`）で、無い作品もある。
    private var accessibilityLabel: String {
        [artwork.title, artwork.artistName, artwork.image.altText]
            .compactMap(\.self)
            .joined(separator: "、")
    }
}

#Preview("標準") {
    ArtworkGridCell(artwork: .preview)
        .frame(width: 180)
}

#Preview("長いタイトル") {
    ArtworkGridCell(artwork: .previewLongTitle)
        .frame(width: 180)
}

#Preview("メタデータ欠落") {
    ArtworkGridCell(artwork: .previewMissingMetadata)
        .frame(width: 180)
}

#Preview("縦長画像の切り抜き") {
    ArtworkGridCell(artwork: .previewPortrait)
        .frame(width: 180)
}

#Preview("文字拡大 AX3") {
    ArtworkGridCell(artwork: .previewLongTitle)
        .frame(width: 180)
        .environment(\.dynamicTypeSize, .accessibility3)
}
