//
//  ConsentManager.swift
//  kawaii_taiju_kanri
//
//  かわいい日記（kawaiidiary）の ConsentManager.swift と同じもの
//

import AppTrackingTransparency
import Foundation
import GoogleMobileAds
import UIKit
import UserMessagingPlatform

extension Notification.Name {
    /// 広告 SDK の初期化が終わったとき。読み込みはこれを待ってから始める。
    static let adMobDidInitialize = Notification.Name("kawaii-taiju-kanri.adMobDidInitialize")
}

/// 広告の同意取得と SDK の初期化。
///
/// 起動してウィンドウができたところで 1 回だけ呼ぶ。順番は
/// 1. UMP の同意情報を更新
/// 2. 必要なら同意フォームを出す（地域の規制に応じて自動で決まる）
/// 3. ATT の許可を尋ねる
/// 4. 広告を出せる状態なら SDK を初期化する
@MainActor
final class ConsentManager {

    static let shared = ConsentManager()

    private var didStartConsentFlow = false
    private var didStartMobileAds = false
    /// SDK の初期化が終わったか（バナーを作り直したとき、すぐ読み込んでよいかの判断に使う）
    private(set) var isStarted = false

    private init() {}

    func startAdsIfPossible() {
        guard !didStartConsentFlow else { return }
        didStartConsentFlow = true

        // コールバックはメインスレッドとは限らないので、メインに戻してから続ける（1つしかないので shared で呼ぶ）
        ConsentInformation.shared.requestConsentInfoUpdate(with: RequestParameters()) { error in
            Task { @MainActor in
                if let error {
                    // 同意情報が取れなくても、取得済みの状態で出せるかを判断する
                    AdLog.error("同意情報の更新に失敗", error)
                    ConsentManager.shared.requestTrackingThenStart()
                    return
                }
                do {
                    try await ConsentForm.loadAndPresentIfRequired(from: UIApplication.shared.topViewController())
                } catch {
                    AdLog.error("同意フォームの表示に失敗", error)
                }
                ConsentManager.shared.requestTrackingThenStart()
            }
        }
    }

    /// ATT の許可を尋ねてから初期化する。
    /// ダイアログはアプリが前面にあるときしか出ないので、この順番で呼ぶ。
    private func requestTrackingThenStart() {
        ATTrackingManager.requestTrackingAuthorization { _ in
            Task { @MainActor in ConsentManager.shared.startMobileAdsIfNeeded() }
        }
    }

    private func startMobileAdsIfNeeded() {
        guard ConsentInformation.shared.canRequestAds else {
            AdLog.info("同意が得られていないので、広告 SDK は初期化しない")
            return
        }
        guard !didStartMobileAds else { return }
        didStartMobileAds = true

        MobileAds.shared.start { _ in
            Task { @MainActor in
                ConsentManager.shared.isStarted = true
                NotificationCenter.default.post(name: .adMobDidInitialize, object: nil)
            }
        }
    }
}

extension UIApplication {
    /// いちばん前に出ている画面。広告の表示元にする。
    func topViewController() -> UIViewController? {
        let keyWindow = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }

        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
