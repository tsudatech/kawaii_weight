//
//  WeightIntents.swift
//  kawaii_taiju_kanri
//
//  Siri・ショートカットのアクション。言いかたは AppShortcuts.strings（{ja,en}.lproj）で訳す。
//

import AppIntents
import SwiftUI

/// 声で体重を記録する。ロックしたままでも動く
struct RecordWeightIntent: AppIntent {
    static let title: LocalizedStringResource = "体重をきろく"
    static let description = IntentDescription("きょうの体重を記録します")
    static let openAppWhenRun = false
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @Parameter(title: "体重", requestValueDialog: IntentDialog("いま何キロ？"))
    var weight: Double

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard (20...200).contains(weight) else {
            throw $weight.needsValueError(IntentDialog("20〜200キロのあいだで教えてね"))
        }
        let store = WeightStore.shared
        store.saveToday(weight: weight, tags: store.todayEntry?.tags ?? [])
        store.saveNow()
        let saved = store.todayEntry?.weight ?? weight
        let hide = store.settings.hideNumbers
        let title = hide ? L("きろくしたよ！") : LF("%@kg をきろくしたよ！", Fmt.kg(saved))
        let diff = store.average7(before: .today).map { ((saved - $0) * 10).rounded() / 10 }
        let sub = diff.map { SiriPreviewView.reply(diff: $0, hide: hide) } ?? L("はじめての記録だよ")
        return .result(
            dialog: IntentDialog(stringLiteral: title),
            view: WeightSnippet(mood: store.todayState.mood, title: title, sub: sub)
        )
    }
}

/// きょうの体重をたずねる
struct TodayWeightIntent: AppIntent {
    static let title: LocalizedStringResource = "きょうの体重をみる"
    static let description = IntentDescription("きょう記録した体重を教えます")
    static let openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = WeightStore.shared
        let text: String
        if let e = store.todayEntry {
            text = store.settings.hideNumbers ? L("きょうも記録したよ") : LF("きょう %@kg", Fmt.kg(e.weight))
        } else {
            text = L("まだはかってないよ")
        }
        return .result(dialog: IntentDialog(stringLiteral: text))
    }
}

/// 7日平均をたずねる
struct AverageWeightIntent: AppIntent {
    static let title: LocalizedStringResource = "7日平均をみる"
    static let description = IntentDescription("直近7日の平均体重を教えます")
    static let openAppWhenRun = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = WeightStore.shared
        let text: String
        if store.settings.hideNumbers {
            text = L("数字はかくしているよ")
        } else if let avg = store.recentAverage {
            text = LF("7日平均は %@kg だよ", Fmt.kg(avg))
        } else {
            text = L("この7日はくらべる記録がないよ")
        }
        return .result(dialog: IntentDialog(stringLiteral: text))
    }
}

struct WeightShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RecordWeightIntent(),
            phrases: [
                "\(.applicationName)で体重をきろく",
                "\(.applicationName)で体重を記録",
            ],
            shortTitle: "体重をきろく",
            systemImageName: "scalemass.fill"
        )
        AppShortcut(
            intent: TodayWeightIntent(),
            phrases: ["\(.applicationName)できょうの体重"],
            shortTitle: "きょうの体重をみる",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: AverageWeightIntent(),
            phrases: ["\(.applicationName)で7日平均"],
            shortTitle: "7日平均をみる",
            systemImageName: "chart.line.uptrend.xyaxis"
        )
    }
}

/// Siri の画面に出すカード（.siriCard）
private struct WeightSnippet: View {
    let mood: Mood
    let title: String
    let sub: String

    var body: some View {
        HStack(spacing: 10) {
            Image(mood.largeAsset).resizable().scaledToFit().frame(width: 76, height: 76)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.ui(16, .black))
                Text(sub).font(.ui(12)).foregroundStyle(Palette.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(Palette.ink)
        .padding(12)
    }
}
