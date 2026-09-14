import Interfaces

/// ModernGallery のテナント設定。
///
/// 色と文言はアセット／ローカライズのインジェクションで解決する方針のため、
/// この型が持つのはパラメータで渡す必要があるものだけ。
struct ModernGalleryTenant: TenantConfiguration {
    let departmentTitle = "Contemporary Art"
    let showsCurationBanner = false
}
