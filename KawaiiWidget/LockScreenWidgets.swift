//
//  LockScreenWidgets.swift
//  KawaiiWidget
//
//  ロック画面ウィジェット（表情・7日平均・もくひょう％）と、「体重をきろく」のコントロール
//

import AppIntents
import SwiftUI
import WidgetKit

private extension WidgetSnapshot {
    var hides: Bool { hideNumbers == true }
}

// MARK: - 表情

struct LockFaceWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KawaiiLockFace", provider: SnapshotProvider()) { entry in
            let mood = entry.snapshot?.moodAndLine(on: entry.date.startOfDay).mood ?? .cheer
            Image(mood.smallAsset)
                .resizable()
                .scaledToFit()
                .padding(5)
                .containerBackground(for: .widget) { AccessoryWidgetBackground() }
                .accessibilityLabel(mood.label)
        }
        .configurationDisplayName(L("キャラの表情"))
        .description(L("きょうのキャラの表情が見られるよ"))
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - 7日平均

struct LockAverageView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SnapshotEntry

    private var today: Date { entry.date.startOfDay }

    var body: some View {
        let s = entry.snapshot
        let recorded = s?.isRecorded(on: today) == true
        Group {
            if family == .accessoryInline {
                let streak = s?.streak(on: today) ?? 0
                Text("🔥" + LF("%d日れんぞく", streak) + L(" ・ ") + (recorded ? L("きょうは記録ずみ") : L("まだはかってないよ")))
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L("7日平均")).font(.ui(11))
                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text(s?.hides == true ? "••.•" : s?.average7.map { Fmt.kg($0) } ?? "—").font(.num(24))
                        Text("kg").font(.ui(11))
                    }
                    Text(subline(s, recorded: recorded)).font(.ui(11)).lineLimit(1).minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }

    private func subline(_ s: WidgetSnapshot?, recorded: Bool) -> String {
        guard recorded, let w = s?.latestWeight else { return L("タップしてきろく") }
        return s?.hides == true ? L("きょうも記録したよ") : LF("きょう %@kg", Fmt.kg(w))
    }
}

struct LockAverageWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KawaiiLockAverage", provider: SnapshotProvider()) { entry in
            LockAverageView(entry: entry)
        }
        .configurationDisplayName(L("7日平均"))
        .description(L("7日平均と、きょうの記録が見られるよ"))
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
    }
}

// MARK: - もくひょう％

struct LockGoalWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KawaiiLockGoal", provider: SnapshotProvider()) { entry in
            let pct = entry.snapshot?.goalPct ?? 0
            Gauge(value: pct, in: 0...100) {
                Text(L("もくひょう")).font(.ui(8))
            } currentValueLabel: {
                Text("\(Int(floor(pct)))").font(.num(17))
            }
            .gaugeStyle(.accessoryCircular)
            .containerBackground(for: .widget) { Color.clear }
        }
        .configurationDisplayName(L("もくひょう"))
        .description(L("もくひょうまでの進み具合が見られるよ"))
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - コントロール（ロック画面・コントロールセンターのボタン）

struct RecordControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "KawaiiRecordControl") {
            ControlWidgetButton(action: OpenRecordIntent()) {
                Label(L("体重をきろく"), systemImage: "scalemass.fill")
            }
        }
        .displayName("体重をきろく")
        .description("アプリを開いて、きょうの体重を入れます")
    }
}
