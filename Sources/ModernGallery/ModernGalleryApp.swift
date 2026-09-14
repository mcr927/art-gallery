import APIClient
import DesignSystem
import Foundation
import Interfaces
import Models
import ScreenArtworkList
import SwiftUI

@main
struct ModernGalleryApp: App {

    /// 合成ルート。アプリ全体でここだけが `APIClient` の実体を知っている。
    private let repository: any ArtworkRepository
    private let tenant: any TenantConfiguration

    init() {
        // URLSession.shared は初回アクセス時に URLCache.shared を取り込むため、
        // 差し替えは Repository を作るより先に行う必要がある。
        // AsyncImage も URLSession.shared 経由で取得するので、
        // ここでの設定だけで画像のディスクキャッシュが効く。
        // 画像キャッシュの都合を画面モジュールへ持ち込まないための置き場所でもある。
        URLCache.shared = URLCache(
            memoryCapacity: 64 * 1024 * 1024,
            diskCapacity: 256 * 1024 * 1024
        )

        repository = ArtworkAPIClient()
        tenant = ModernGalleryTenant()
    }

    var body: some Scene {
        WindowGroup {
            // 遷移の器はアプリ側に置く。画面モジュールは NavigationStack を持たない。
            NavigationStack {
                ArtworkListScreen(
                    repository: repository,
                    // テナント設定を取得条件へ翻訳するのは合成ルートの責務。
                    // これにより画面も APIClient もテナントを知らずに済む。
                    query: ArtworkQuery(departmentTitle: tenant.departmentTitle)
                )
            }
            .tint(GalleryColor.brandPrimary)
        }
    }
}
