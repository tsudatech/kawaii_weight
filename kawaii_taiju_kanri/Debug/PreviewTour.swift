//
//  PreviewTour.swift
//  kawaii_taiju_kanri
//
//  App Store のプレビュー動画（紹介動画）を撮るための、自動の流れ（デバッグビルドの起動引数 `--preview-tour`）。
//  シミュレータで `xcrun simctl io recordVideo` しながら起動する。手順は AppStore/preview/README.md。
//
//  流れ：ホーム（体重を入れて「きろくする」→ もやもやがはれて紙ふぶき）→ ごほうびの日せんげん → 見ないモード
//       → シェアカード → グラフ（3か月）→ キャラ（はらしたもやもや）→ ロック画面 → Siri
//

import SwiftUI

#if DEBUG
enum PreviewTour {
    static var isOn: Bool { ProcessInfo.processInfo.arguments.contains("--preview-tour") }

    /// きょうの体重のカードを動かす（RecordCard が受ける）
    static let bump = Notification.Name("previewTour.bump")
    static let tag = Notification.Name("previewTour.tag")
    static let save = Notification.Name("previewTour.save")

    /// 起動してすぐ：見本の記録を入れて、案内やはじめの設定を出さない
    static func prepare(_ store: WeightStore) {
        guard isOn else { return }
        Onboarding.setAllSeen(true)
        store.loadSample()
        store.settings = AppSettings()
        store.characterName = LanguageOverride.isJapanese ? "もち" : "Mochi"
        store.onboarded = true
        store.showOnboarding = false
        store.selectedTab = .home
        setUpWatch(store)
    }

    /// 3日前の飲み会から増えていて、きょう −ボタンを8回押した体重でちょうど「もやもやがはれる」見本にする
    private static func setUpWatch(_ store: WeightStore) {
        let d3 = Date.today.adding(days: -3), d2 = Date.today.adding(days: -2), d1 = Date.today.adding(days: -1)
        guard let avg = store.average7(before: d3) else { return }
        let base = (avg * 10).rounded() / 10
        store.entries[d3]?.tags = ["飲み会"]
        store.entries[d3]?.weight = base + 1.3
        store.entries[d2]?.weight = base + 1.1
        store.entries[d1]?.weight = base + 0.9
    }

    static func run(_ store: WeightStore) async {
        guard isOn else { return }
        let post = { (name: Notification.Name, object: Any?) in NotificationCenter.default.post(name: name, object: object) }

        // ホーム：まだはかっていない（ねむい）→ 体重を入れて記録 → もやもやがはれて紙ふぶき
        await wait(2.0)
        for _ in 0..<8 {
            post(bump, -0.1)
            await wait(0.2)
        }
        await wait(0.4)
        post(tag, "運動した")
        await wait(0.7)
        post(save, nil)
        await wait(3.8)

        // ごほうびの日せんげん
        store.toggleTomorrowTreat()
        await wait(2.6)

        // 見ないモード
        store.settings.hideNumbers = true
        store.showToast(L("体重の数字をかくしました"))
        await wait(2.6)
        store.settings.hideNumbers = false

        // シェアカード
        store.sharingDate = .today
        await wait(2.8)
        store.sharingDate = nil
        await wait(0.5)

        // グラフ：1か月 → 3か月
        store.selectedTab = .graph
        await wait(1.3)
        store.graphRange = 90
        await wait(1.7)

        // キャラ：はらしたもやもや
        store.selectedTab = .chara
        await wait(2.6)

        // ロック画面・Siri
        store.showLockPreview = true
        await wait(2.4)
        store.showLockPreview = false
        store.showSiriPreview = true
    }

    private static func wait(_ seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }
}
#endif
