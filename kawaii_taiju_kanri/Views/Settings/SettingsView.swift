//
//  SettingsView.swift
//  kawaii_taiju_kanri
//
//  せってい
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: WeightStore
    @State private var confirmReset = false

    var body: some View {
        ScreenScroll {
            ScreenHeader(caption: L("じぶん好みに"), title: L("せってい"))
            bodyGroup.coachTarget("settings.body").padding(.top, 4)
            judgeGroup.coachTarget("settings.judge").padding(.top, 18)
            recordGroup.padding(.top, 18)
            notifyGroup.padding(.top, 18)
            playGroup.padding(.top, 18)
            hideGroup.padding(.top, 18)
            iPhoneGroup.padding(.top, 18)
            charaGroup.padding(.top, 18)
            dataGroup.padding(.top, 18)
            #if DEBUG
            debugGroup.padding(.top, 18)
            #endif
            SettingsGroup(title: L("このアプリについて")) {
                SettingsRow(label: L("バージョン")) {
                    Text(appVersion).font(.num(14, .bold)).foregroundStyle(Palette.inkSoft)
                }
            }
            .padding(.top, 18)
            // .bye
            VStack(spacing: 4) {
                Image("sm_sleepy").resizable().scaledToFit().frame(width: 70, height: 70)
                Text(L("きょうもおつかれさま")).font(.ui(12)).foregroundStyle(Palette.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 26)
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    // MARK: - からだ

    private var bodyGroup: some View {
        SettingsGroup(title: L("からだ")) {
            SettingsRow(icon: "📏", iconBG: Color(hex: 0xE6F4F5), label: L("身長")) {
                AdjustControl(value: "\(store.settings.height)", unit: "cm") { d in
                    store.settings.height = min(220, max(120, store.settings.height + d))
                }
            }
            SettingsRow(icon: "🎯", iconBG: Color(hex: 0xE7F5F0), label: L("もくひょう体重")) {
                AdjustControl(value: Fmt.kg(store.settings.goal), unit: "kg") { d in
                    store.settings.goal = min(150, max(30, store.settings.goal + Double(d) * 0.5))
                }
            }
        }
    }

    // MARK: - キャラのはんてい

    private var judgeGroup: some View {
        SettingsGroup(
            title: L("キャラのはんてい"),
            footer: L("「7日平均」だと、日々の水分の上下で表情がころころ変わらないよ。きびしめモードでは 0.3kg 増えただけで「なきそう」になるよ")
        ) {
            SettingsRow(icon: "⚖️", iconBG: Palette.blush, label: L("くらべかた")) {
                PillSegment(
                    options: [(JudgeMode.trend, L("7日平均")), (JudgeMode.daily, L("前回"))],
                    selection: Binding(
                        get: { store.settings.judge },
                        set: { v in
                            store.settings.judge = v
                            store.showToast(v == .trend ? L("7日平均とくらべるよ（やさしめ）") : L("前回の記録とくらべるよ"))
                        }
                    )
                )
            }
            SettingsToggleRow(icon: "🍰", iconBG: Palette.blush, label: L("きびしめモード"), isOn: $store.settings.strict)
        }
    }

    // MARK: - きろく

    private var recordGroup: some View {
        SettingsGroup(title: L("きろく")) {
            SettingsButtonRow(icon: "🏷️", iconBG: Color(hex: 0xFDF0DC), label: L("タグ"),
                              note: LF("「きょうのこと」のタグ・%dこ", store.settings.tags.count)) {
                store.showTags = true
            }
        }
    }

    // MARK: - おしらせ

    private var notifyGroup: some View {
        SettingsGroup(title: L("おしらせ")) {
            SettingsToggleRow(
                icon: "⏰", iconBG: Color(hex: 0xFDF0DC), label: L("毎日はかってね通知"),
                isOn: Binding(get: { store.settings.remind }, set: { store.setRemind($0) })
            )
            SettingsRow(icon: "🕖", iconBG: Color(hex: 0xFDF0DC), label: L("通知の時間")) {
                TimeField(time: Binding(
                    get: { store.settings.remindTime },
                    set: { v in
                        store.settings.remindTime = v
                        store.showToast(LF("毎日 %@ にお知らせします", Fmt.time(v)))
                    }
                ), disabled: !store.settings.remind)
            }
            SettingsButtonRow(icon: "🔔", iconBG: Color(hex: 0xFDF0DC), label: L("通知をためす"), note: L("3びょう後に、キャラのセリフで届くよ")) {
                store.sendTestNotification()
            }
        }
    }

    // MARK: - あそび

    private var playGroup: some View {
        SettingsGroup(
            title: L("あそび"),
            footer: L("オンにすると、ホームの体重入力に「よそう」が出るよ。あたるとポイントがたまって、キャラタブに成績が出るよ")
        ) {
            SettingsToggleRow(
                icon: "🎯", iconBG: Color(hex: 0xFFF3D9), label: L("体重よそう"),
                note: L("はかる前に「ふえた・おなじ・へった」を当てるゲーム"),
                isOn: Binding(get: { store.settings.game }, set: { on in
                    store.settings.game = on
                    store.showToast(on ? L("体重よそうをオンにしました。ホームに出るよ") : L("体重よそうをオフにしました"))
                })
            )
        }
    }

    // MARK: - 見ないモード

    private var hideGroup: some View {
        SettingsGroup(
            title: L("見ないモード"),
            footer: L("数字を見たくない日に。体重はぼかして、キャラの表情とことばだけで伝えるよ。記録はいつもどおりできるよ")
        ) {
            SettingsToggleRow(
                icon: "👀", iconBG: Color(hex: 0xF3EEE9), label: L("体重の数字をかくす"),
                isOn: Binding(get: { store.settings.hideNumbers }, set: { on in
                    store.settings.hideNumbers = on
                    store.showToast(on ? L("体重の数字をかくしました") : L("数字を表示します"))
                })
            )
        }
    }

    // MARK: - iPhone とのれんけい

    private var iPhoneGroup: some View {
        SettingsGroup(title: L("iPhone とのれんけい")) {
            #if HEALTH_SYNC
            SettingsToggleRow(
                icon: "❤️", iconBG: Color(hex: 0xFDECEC), label: L("ヘルスケアと同期"),
                note: L("体重計アプリの記録を読みこみ、ここでの記録も書きこむよ"),
                isOn: Binding(get: { store.settings.health }, set: { store.setHealth($0) })
            )
            #endif
            PreviewRow(icon: "🧩", iconBG: Color(hex: 0xE6F4F5), label: L("ホーム画面ウィジェット"), note: L("きょうの表情と体重が見られるよ")) {
                store.showWidgetPreview = true
            }
            PreviewRow(icon: "🔒", iconBG: Color(hex: 0xE6F4F5), label: L("ロック画面ウィジェット"), note: L("ロック画面で見られて、1タップで体重入力へ")) {
                store.showLockPreview = true
            }
            PreviewRow(icon: "🎙️", iconBG: Color(hex: 0xEFEAF8), label: L("Siri・ショートカット"), note: LF("「Hey Siri、%@で体重をきろく」", L("たいかん！"))) {
                store.showSiriPreview = true
            }
        }
    }

    // MARK: - キャラ

    private var charaGroup: some View {
        SettingsGroup(title: L("キャラ")) {
            SettingsToggleRow(icon: "💬", iconBG: Palette.blush, label: L("ふきだしでしゃべる"), isOn: $store.settings.talk)
            SettingsToggleRow(icon: "✨", iconBG: Palette.blush, label: L("ふわふわ動く"), isOn: $store.settings.move)
        }
    }

    // MARK: - データ

    private var dataGroup: some View {
        SettingsGroup(title: L("データ")) {
            if store.entries.isEmpty {
                SettingsButtonRow(icon: "📤", iconBG: Color(hex: 0xF3EEE9), label: L("CSVで書き出す")) {
                    store.showToast(L("まだ記録がないよ"))
                }
            } else {
                ShareLink(item: store.csvExport, preview: SharePreview(L("体重の記録（CSV）"))) {
                    SettingsRow(icon: "📤", iconBG: Color(hex: 0xF3EEE9), label: L("CSVで書き出す")) { Chevron() }
                }
                .buttonStyle(.plain)
            }
            SettingsButtonRow(icon: "☁️", iconBG: Color(hex: 0xE6F4F5), label: L("バックアップ"),
                              note: store.backup.isEnabled ? L("iCloudに預けています") : L("iCloudに記録を預けられます")) {
                store.showBackup = true
            }
            SettingsButtonRow(icon: "👋", iconBG: Color(hex: 0xE7F5F0), label: L("はじめの設定をもう一度"), note: L("いまの記録はそのまま")) {
                store.showOnboarding = true
            }
            SettingsButtonRow(icon: "🗑️", iconBG: Color(hex: 0xFBE5E3), label: L("すべてのデータを消す"), danger: true) {
                confirmReset = true
            }
        }
        .confirmationDialog(L("すべてのデータを消しますか？"), isPresented: $confirmReset, titleVisibility: .visible) {
            Button(L("記録と設定をすべて消す"), role: .destructive) { store.resetAll() }
            Button(L("キャンセル"), role: .cancel) {}
        } message: {
            Text(store.backup.isEnabled
                 ? L("体重の記録・設定・キャラの名前・ごほうびが消えて、もとに戻せません。iCloudに預けた記録も消えます")
                 : L("体重の記録・設定・キャラの名前・ごほうびが消えて、もとに戻せません"))
        }
    }

    #if DEBUG
    // MARK: - デバッグ（開発中のビルドだけ）

    private var debugGroup: some View {
        SettingsGroup(title: L("デバッグ")) {
            // 案内を全部未読にもどして、ホームから見せる（ほかのタブの案内は、そのタブを開いたときに出る）
            PreviewRow(icon: "💡", iconBG: Color(hex: 0xFFF3D9), label: L("案内をもう一度見る"), note: L("各タブのはじめての案内を、未読にもどすよ")) {
                Onboarding.setAllSeen(false)
                store.selectedTab = .home
            }
            SettingsButtonRow(icon: "🔄", iconBG: Color(hex: 0xFBE5E3), label: L("サンプルデータを入れる"), note: L("約3か月分。いまの記録は置きかわり、iCloudバックアップはオフになるよ"), danger: true) {
                store.loadSample()
                store.showToast(L("サンプルデータを入れました"))
            }
            PreviewRow(icon: "🥺", iconBG: Palette.blush, label: L("ひさしぶりに開いたとき"), note: L("3日あくと、さみしがるよ")) {
                store.simulateAbsent = true
                store.selectedTab = .home
            }
            PreviewRow(icon: "🏅", iconBG: Color(hex: 0xFFF3D9), label: L("ごほうびのお祝い"), note: L("1kg減・目標達成・連続記録など")) {
                store.celebrating = Badge.all.first { $0.id == "down1" }
            }
        }
    }
    #endif
}

// MARK: - 行の部品

/// .group（見出し ＋ .list）
struct SettingsGroup<Content: View>: View {
    let title: String
    var footer: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.ui(12))
                .tracking(0.96)
                .foregroundStyle(Palette.inkSoft)
                .padding(.leading, 14)
                .padding(.bottom, 6)
            VStack(spacing: 0) {
                Group { content }
                    .overlay(alignment: .top) { Rectangle().fill(Palette.lineSoft).frame(height: 1.5) }
            }
            .padding(2)
            .background(Palette.card)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(Palette.line, lineWidth: 2))
            if let footer {
                Text(footer)
                    .font(.ui(12))
                    .foregroundStyle(Palette.inkSoft)
                    .lineHeight(1.6, size: 12)
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
            }
        }
    }
}

/// .row
struct SettingsRow<Accessory: View>: View {
    var icon: String?
    var iconBG: Color = .clear
    let label: String
    var note: String?
    var preview = false
    var danger = false
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Text(icon)
                    .font(.system(size: 16))
                    .frame(width: 30, height: 30)
                    .background(RoundedRectangle(cornerRadius: 10).fill(iconBG))
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Text(label).font(.ui(15)).foregroundStyle(danger ? Palette.up : Palette.ink)
                    if preview {
                        Text(L("プレビュー"))
                            .font(.ui(10))
                            .foregroundStyle(Color(hex: 0xA87A2A))
                            .padding(.horizontal, 6).padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color(hex: 0xFFF3D9)))
                    }
                }
                if let note { Text(note).font(.ui(11)).foregroundStyle(Palette.inkSoft) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            accessory
        }
        .padding(.vertical, 8).padding(.horizontal, 14)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }
}

/// .chev
struct Chevron: View {
    var body: some View {
        Text("›").font(.ui(15, .black)).foregroundStyle(Color(hex: 0xC7B6A8))
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconBG: Color
    let label: String
    var note: String?
    @Binding var isOn: Bool

    var body: some View {
        SettingsRow(icon: icon, iconBG: iconBG, label: label, note: note) {
            CSSSwitch(isOn: $isOn, label: label)
        }
    }
}

struct SettingsButtonRow: View {
    let icon: String
    let iconBG: Color
    let label: String
    var note: String?
    var danger = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsRow(icon: icon, iconBG: iconBG, label: label, note: note, danger: danger) {
                if !danger { Chevron() }
            }
        }
        .buttonStyle(.plain)
    }
}

/// 「プレビュー」タグ付きの行
struct PreviewRow: View {
    let icon: String
    let iconBG: Color
    let label: String
    let note: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsRow(icon: icon, iconBG: iconBG, label: label, note: note, preview: true) { Chevron() }
        }
        .buttonStyle(.plain)
    }
}

/// −  値  ＋（.mini と .val）
struct AdjustControl: View {
    let value: String
    let unit: String
    let onStep: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            RoundStepButton.mini("−") { onStep(-1) }
            Text("\(Text(value).font(.num(17, .bold)))\(Text(unit).font(.num(12, .bold)))")
                .foregroundStyle(Palette.ink)
                .frame(minWidth: 62)
            RoundStepButton.mini("+") { onStep(1) }
        }
    }
}
