//
//  ArtworkListViewModel.swift
//  GalleryPackage
//
//  Created by タカショー on 2026/09/14.
//


import Interfaces
import Models
import Observation

/// 一覧画面の状態を持つ。
///
/// `@MainActor` を書いていないのは、Package.swift で UI 系ターゲットに
/// `.defaultIsolation(MainActor.self)` を指定しているため。
/// ドメイン層（Models / Interfaces / APIClient）は既定の isolation を持たず、
/// UI 層だけが MainActor に隔離される構成になっている。
@Observable
final class ArtworkListViewModel {

    /// 画面が取りうる状態。
    ///
    /// 「読み込み中かつエラー」のような不正な組み合わせを型で排除するため、
    /// 個別のフラグではなく単一の enum にしている。
    /// `empty` を `loaded` から独立させているのは、空かどうかの判断を
    /// View 側の `items.isEmpty` に書かせないため。
    enum State: Equatable {
        case loading
        case loaded(ArtworkPage)
        case empty
        case failed(ArtworkRepositoryError)
    }

    private(set) var state: State = .loading

    private let repository: any ArtworkRepository
    private let query: ArtworkQuery

    /// 依存はイニシャライザで受け取る。
    /// テナントの概念はここには入れず、絞り込み条件は `ArtworkQuery` として渡される。
    init(repository: any ArtworkRepository, query: ArtworkQuery) {
        self.repository = repository
        self.query = query
    }

    /// 初回表示と再試行で使う。読み込み中の表示に切り替えてから取得する。
    func load() async {
        state = .loading
        await fetch()
    }

    /// 引っ張って更新。現在の表示を保ったまま内容だけ差し替えるため、
    /// `loading` には戻さない。標準のインジケータが進行を示す。
    func reload() async {
        await fetch()
    }

    private func fetch() async {
        do {
            let page = try await repository.artworks(query: query)
            // ページは保持したまま渡す。#8 を後から入れる際に
            // 次ページ番号の置き場を新設せずに済む。
            state = page.items.isEmpty ? .empty : .loaded(page)
        } catch {
            // 画面を離れたことによる中断はエラーとして扱わない。
            // `.task` は View の消滅時に自動でキャンセルされるため、
            // ここで状態を書き換えると遷移のたびにエラー画面が一瞬出る。
            guard error != .cancelled else { return }
            state = .failed(error)
        }
    }
}