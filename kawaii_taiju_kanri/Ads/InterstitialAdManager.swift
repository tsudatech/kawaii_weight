//
//  InterstitialAdManager.swift
//  kawaii_taiju_kanri
//
//  かわいい日記（kawaiidiary）の InterstitialAdManager.swift と同じもの
//

import GoogleMobileAds
import Observation
import UIKit

/// 全画面広告の読み込みと表示。
///
/// 1 つだけ先に読み込んでおき、出したいところで `showIfReady()` を呼ぶ。
/// 閉じられたら次のぶんを読み直す。
@Observable
@MainActor
final class InterstitialAdManager: NSObject {

    /// すぐ出せる状態か。
    private(set) var isReady = false

    @ObservationIgnored private var ad: InterstitialAd?
    @ObservationIgnored private var observer: NSObjectProtocol?

    override init() {
        super.init()
        // SDK の初期化が終わってから読み込む。
        // 初期化前に読み込もうとしても失敗するだけなので待つ
        observer = NotificationCenter.default.addObserver(
            forName: .adMobDidInitialize, object: nil, queue: .main
        ) { [weak self] _ in
            // queue: .main で受けているので、そのままメインで読む
            MainActor.assumeIsolated { self?.load() }
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }

    func load() {
        // 読み込みの結果はメインスレッドで返ってくる
        InterstitialAd.load(with: AdMobConfig.interstitialAdUnitID, request: Request()) { [weak self] ad, error in
            MainActor.assumeIsolated {
                guard let self else { return }
                if let error {
                    AdLog.error("全画面広告の読み込みに失敗", error)
                    self.isReady = false
                    return
                }
                self.ad = ad
                self.ad?.fullScreenContentDelegate = self
                self.isReady = true
            }
        }
    }

    /// 用意できていれば出す。できていなければ何もしない。
    /// - Returns: 出したかどうか。
    @discardableResult
    func showIfReady() -> Bool {
        guard let ad, let presenter = UIApplication.shared.topViewController() else { return false }
        ad.present(from: presenter)
        return true
    }
}

extension InterstitialAdManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        reloadAfterUse()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        AdLog.error("全画面広告の表示に失敗", error)
        reloadAfterUse()
    }

    private func reloadAfterUse() {
        ad = nil
        isReady = false
        load()
    }
}
