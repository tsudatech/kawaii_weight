//
//  PreviewTour.swift
//  kawaii_taiju_kanri
//
//  App Store のプレビュー動画（紹介動画）を撮るための、自動の流れ（デバッグビルドの起動引数 `--preview-tour`）。
//  シミュレータで `xcrun simctl io recordVideo` しながら起動する。手順は AppStore/preview/README.md。
//
//  流れ：ホーム（体重を入れて、タグをえらんで「きろくする」→ キャラが反応）→ グラフ（3か月）→ 日の詳細
//       → キャラ（ずかんで顔を変える）→ ごほうびのお祝い → ウィジェット
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
    }

    static func run(_ store: WeightStore) async {
        guard isOn else { return }
        let post = { (name: Notification.Name, object: Any?) in NotificationCenter.default.post(name: name, object: object) }

        // ホーム：まだはかっていない（ねむい）→ 体重を入れて記録
        await wait(2.0)
        for _ in 0..<8 {
            post(bump, -0.1)
            await wait(0.22)
        }
        await wait(0.5)
        post(tag, "運動した")
        await wait(0.9)
        post(save, nil)
        await wait(4.2)

        // グラフ：1か月 → 3か月
        store.selectedTab = .graph
        await wait(2.0)
        store.graphRange = 90
        await wait(2.4)

        // 日の詳細（カレンダーから開いたことにする）
        if let day = store.sortedDates.dropLast(3).last {
            store.openDay(day, from: L("カレンダー"))
        }
        await wait(3.2)
        store.detailDate = nil
        await wait(0.8)

        // キャラ：ずかんで顔を変える
        store.selectedTab = .chara
        await wait(2.0)
        store.roomMood = .doya
        await wait(1.6)
        store.roomMood = .cheer
        await wait(1.6)

        // ごほうびのお祝い
        store.celebrating = Badge.all.first { $0.id == "down1" }
        await wait(3.6)
        store.celebrating = nil
        await wait(0.6)

        // ホーム画面ウィジェット
        store.showWidgetPreview = true
    }

    private static func wait(_ seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }
}
#endif
