//
//  AdService.swift
//  kawaii_taiju_kanri
//
//  広告をいつ出すかを決める（かわいい日記の AdService と同じ考え方）。SDK の扱いは InterstitialAdManager に任せる。
//
//  ・バナーはタブバーの上に出す。広告が届くまで・届かないときは高さ0なので、
//    審査が通るまで（在庫がないあいだ）は何も出ず、場所も取らない
//  ・全画面広告は、体重を何回か記録したあと、つぎにタブを切りかえたときだけ。
//    記録した直後はキャラの反応やごほうびのお祝いを見せたいので、その場では出さない
//

import Combine
import Foundation

final class AdService: ObservableObject {
    static let shared = AdService()

    /// 全画面広告を出す間隔（記録の回数）
    static let savesPerInterstitial = 3

    /// いまのバナーの高さ。スクロールする画面は、この分だけ下の余白を足す（読み込めなければ 0）
    @Published var bannerHeight: CGFloat = 0

    /// 広告を出すか。紹介動画の自動の流れ（デバッグ）では、テスト広告が映らないよう出さない
    var isEnabled: Bool {
        #if DEBUG
        !PreviewTour.isOn
        #else
        true
        #endif
    }

    private let interstitial = InterstitialAdManager()
    private let defaults = UserDefaults.standard
    private let countKey = "ads.saveCount"

    /// 最後に出してから数えた記録の回数
    private var savesSinceLastAd: Int {
        didSet { defaults.set(savesSinceLastAd, forKey: countKey) }
    }

    private init() {
        savesSinceLastAd = defaults.integer(forKey: countKey)
    }

    /// 同意の確認（UMP・ATT）と SDK の初期化を始める。はじめの設定と案内が済んでから1回だけ
    func start() {
        guard isEnabled else { return }
        ConsentManager.shared.startAdsIfPossible()
    }

    /// 体重を記録・修正したとき
    func noteSaved() {
        savesSinceLastAd += 1
    }

    /// タブを切りかえたとき。たまっていて、ほかの演出が出ていなければ全画面広告を出す
    /// - Parameter isBusy: お祝い・シート・案内などを出しているところなら true（重ねると演出が潰れる）
    func showInterstitialIfDue(isBusy: Bool) {
        guard isEnabled, !isBusy, savesSinceLastAd >= Self.savesPerInterstitial else { return }
        // 用意できていないときは数えたまま持ち越す
        if interstitial.showIfReady() {
            savesSinceLastAd = 0
        }
    }
}
