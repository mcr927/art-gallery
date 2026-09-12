/// テナントごとに差し替える設定。
/// 表示文言と色はアセット／ローカライズのインジェクションで解決するため、
/// この protocol には持たせない。
public protocol TenantConfiguration: Sendable {
    var departmentTitle: String { get }
    var showsCurationBanner: Bool { get }
}
