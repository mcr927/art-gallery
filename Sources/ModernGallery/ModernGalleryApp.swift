import APIClient
import DesignSystem
import Foundation
import Interfaces
import Models
import ScreenArtworkList
import SwiftUI

@main
struct ModernGalleryApp: App {

    private let repository: any ArtworkRepository
    private let tenant: any TenantConfiguration
    private let detailScreenBuilder: any ArtworkDetailScreenBuilding

    init() {
        URLCache.shared = URLCache(
            memoryCapacity: 64 * 1024 * 1024,
            diskCapacity: 256 * 1024 * 1024
        )

        let repository = ArtworkAPIClient()
        self.repository = repository
        self.tenant = ModernGalleryTenant()
        self.detailScreenBuilder = ArtworkDetailScreenBuilder(repository: repository)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ArtworkListScreen(
                    repository: repository,
                    query: ArtworkQuery(departmentTitle: tenant.departmentTitle),
                    detailScreenBuilder: detailScreenBuilder
                )
            }
            .tint(GalleryColor.brandPrimary)
        }
    }
}
