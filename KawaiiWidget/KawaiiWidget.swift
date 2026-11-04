//
//  KawaiiWidget.swift
//  KawaiiWidget
//
//  ホーム画面ウィジェット（小・中）。アプリが書き出した WidgetSnapshot を表示する。
//  ぼかしではなく点に置きかえて、見ないモードでは体重の数字そのものを描かない。
//

import SwiftUI
import WidgetKit

struct SnapshotEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct SnapshotProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnapshotEntry {
        SnapshotEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SnapshotEntry) -> Void) {
        let saved = WidgetSnapshot.load()
        completion(SnapshotEntry(date: .now, snapshot: context.isPreview && saved == nil ? .placeholder : saved))
    }

    /// いまと、つぎの 0:00（「きょう」が切りかわる）の2つ
    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapshotEntry>) -> Void) {
        let saved = WidgetSnapshot.load()
        let midnight = Date.today.adding(days: 1)
        let entries = [
            SnapshotEntry(date: .now, snapshot: saved),
            SnapshotEntry(date: midnight, snapshot: saved),
        ]
        completion(Timeline(entries: entries, policy: .after(midnight.adding(days: 1))))
    }
}

struct KawaiiWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SnapshotEntry

    private var today: Date { entry.date.startOfDay }

    var body: some View {
        Group {
            if let s = entry.snapshot {
                switch family {
                case .systemMedium: medium(s)
                default: small(s)
                }
            } else {
                empty
            }
        }
        .containerBackground(Palette.paper, for: .widget)
    }

    private var empty: some View {
        VStack(spacing: 6) {
            Image(Mood.cheer.smallAsset).resizable().scaledToFit().frame(width: 56, height: 56)
            Text(L("アプリをひらいて\nきろくしてね")).font(.ui(12)).multilineTextAlignment(.center).foregroundStyle(Palette.inkSoft)
        }
    }

    private func weightText(_ s: WidgetSnapshot) -> String {
        s.hideNumbers == true ? "••.•" : s.latestWeight.map { Fmt.kg($0) } ?? "—"
    }

    private func small(_ s: WidgetSnapshot) -> some View {
        let diff = s.diff(on: today)
        return VStack(alignment: .leading, spacing: 2) {
            Image(s.moodAndLine(on: today).mood.smallAsset).resizable().scaledToFit().frame(width: 52, height: 52)
            Text(s.isRecorded(on: today) ? L("きょう") : L("さいしん")).font(.ui(10)).foregroundStyle(Palette.inkSoft)
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(weightText(s)).font(.num(24))
                Text("kg").font(.ui(10))
            }
            .foregroundStyle(Palette.ink)
            Text(s.hideNumbers == true && diff != nil ? L("きょうも記録したよ") : diff.map { "\(Fmt.signed($0))kg" } ?? (s.isRecorded(on: today) ? "—" : L("まだはかってないよ")))
                .font(.ui(10))
                .foregroundStyle(s.hideNumbers == true ? Palette.inkSoft : deltaColor(diff))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func medium(_ s: WidgetSnapshot) -> some View {
        let ml = s.moodAndLine(on: today)
        let line = ml.line ?? ml.mood.lines[0]
        let name = s.characterName.isEmpty ? L("キャラ") : s.characterName
        return HStack(spacing: 12) {
            Image(ml.mood.largeAsset).resizable().scaledToFit().frame(width: 100, height: 100)
            VStack(alignment: .leading, spacing: 4) {
                Text(LF("%1$@「%2$@」", name, String(line.prefix(16)))).font(.ui(11)).foregroundStyle(Palette.inkSoft).lineLimit(1)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(weightText(s)).font(.num(28))
                    Text("kg").font(.ui(11))
                    Text("🔥" + LF("%d日", s.streak(on: today))).font(.ui(11)).foregroundStyle(Palette.inkSoft)
                }
                .foregroundStyle(Palette.ink)
                Sparkline(values: s.recentWeights)
                    .stroke(Palette.rose, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    .frame(height: 32)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct KawaiiWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSnapshot.widgetKind, provider: SnapshotProvider()) { entry in
            KawaiiWidgetView(entry: entry)
        }
        .configurationDisplayName(L("たいかん！"))
        .description(L("きょうの表情と体重が見られるよ"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    KawaiiWidget()
} timeline: {
    SnapshotEntry(date: .now, snapshot: .placeholder)
}
