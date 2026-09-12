import Foundation

/// 作品一覧の取得条件。
///
/// テナント固有の絞り込みは Repository ではなくこの型に載せる。
/// これにより APIClient はテナントを知る必要がなくなり、
/// 2テナント間の差分は合成ルートでの `TenantConfiguration` の注入だけになる。
public struct ArtworkQuery: Hashable, Sendable {

    /// 所蔵部門での絞り込み。`TenantConfiguration.departmentTitle` 由来。
    /// nil の場合は絞り込まない（テストやプレビューでの利用を想定）。
    public var departmentTitle: String?

    /// 1始まり。API の `page` パラメータに対応する。
    public var page: Int

    /// 1ページあたりの件数。API 側の上限は 100。
    public var pageSize: Int

    /// パブリックドメイン作品のみに限定するか。
    /// 画像の利用条件を満たすため、既定で true とする。
    public var publicDomainOnly: Bool

    public init(
        departmentTitle: String? = nil,
        page: Int = 1,
        pageSize: Int = 24,
        publicDomainOnly: Bool = true
    ) {
        self.departmentTitle = departmentTitle
        self.page = page
        self.pageSize = pageSize
        self.publicDomainOnly = publicDomainOnly
    }

    /// 次ページを取得するための条件を返す。
    /// ページ番号の加算をこの型に閉じ込め、画面側で算術を行わせない。
    public func advanced(to page: Int) -> ArtworkQuery {
        var copy = self
        copy.page = page
        return copy
    }
}
