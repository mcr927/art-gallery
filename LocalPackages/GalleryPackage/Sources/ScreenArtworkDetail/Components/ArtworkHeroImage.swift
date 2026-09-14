import DesignSystem
import Models
import SwiftUI

/// 詳細画面の主画像。
///
/// 一覧では 1:1 に切り抜いたが、ここでは原本のアスペクト比を尊重する。
/// `ArtworkImage.aspectRatio` を使う唯一の場所。
/// 一覧は走査、詳細は鑑賞という役割の違いをレイアウトに反映させている。
struct ArtworkHeroImage: View {

    let image: ArtworkImage

    /// 寸法が欠けている作品は 4:3 で確保する。
    /// 読み込み前に高さを確定させ、表示後のレイアウト跳ねを防ぐ。
    private var ratio: Double { image.aspectRatio ?? 4.0 / 3.0 }

    var body: some View {
        Color.clear
            .aspectRatio(ratio, contentMode: .fit)
            .overlay {
                AsyncImage(
                    url: image.url(.large),
                    transaction: Transaction(animation: .easeOut(duration: 0.2))
                ) { phase in
                    switch phase {
                    case .success(let loaded):
                        loaded
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder(systemImage: "photo")
                    case .empty:
                        placeholder(systemImage: nil)
                    @unknown default:
                        placeholder(systemImage: nil)
                    }
                }
            }
            .clipped()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(image.altText ?? "")
            // 説明文が無い画像は読み上げから外す。無音の要素を挟まないため。
            .accessibilityHidden(image.altText == nil)
    }

    @ViewBuilder
    private func placeholder(systemImage: String?) -> some View {
        GalleryColor.imagePlaceholder
            .overlay {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.largeTitle)
                        .foregroundStyle(GalleryColor.secondaryLabel)
                }
            }
    }
}
