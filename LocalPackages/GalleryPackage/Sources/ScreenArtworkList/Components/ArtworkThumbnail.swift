import DesignSystem
import Models
import SwiftUI

/// 作品画像。正方形に切り抜いて表示する。
///
/// 読み込みは `AsyncImage` に委ねている。デコード済みの画像キャッシュを持たないため
/// 長距離スクロールの往復では再デコードが走るが、
/// (1) IIIF でサーバ側リサイズした小さい画像を要求する
/// (2) 合成ルートで `URLCache` の容量を広げる
/// の2点で実用上の負荷を下げ、自前の画像キャッシュ層は持たない判断とした。
///
/// 一覧では原本のアスペクト比を尊重せず 1:1 に統一している。
/// 行ごとにセル高が変わると走査時の視線移動コストが上がるため。
/// `ArtworkImage.aspectRatio` は詳細画面で使う。
struct ArtworkThumbnail: View {

    let image: ArtworkImage
    let size: ArtworkImage.Size

    /// DesignSystem に角丸のトークンを置いていないため、ここで持つ。
    /// 使用箇所が増えたら DesignSystem へ引き上げる。
    private let cornerRadius: CGFloat = 8

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                AsyncImage(
                    url: image.url(size),
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
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                // 白地の作品が背景に溶けないよう、輪郭だけ与える。
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(GalleryColor.separator, lineWidth: 0.5)
            }
            // ラベルはセル側でまとめて組み立てるため、画像単体では読み上げない。
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func placeholder(systemImage: String?) -> some View {
        GalleryColor.imagePlaceholder
            .overlay {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundStyle(GalleryColor.secondaryLabel)
                }
            }
    }
}
