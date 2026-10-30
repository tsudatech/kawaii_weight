//
//  GraphView.swift
//  kawaii_taiju_kanri
//
//  グラフ（推移・統計・BMI・カレンダー）
//

import SwiftUI

struct GraphView: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        ScreenScroll {
            ScreenHeader(caption: L("からだのうつりかわり"), title: L("グラフ"))
            chartCard.coachTarget("graph.chart")
            statsGrid
            BMICard().padding(.top, 14)
            CalendarCard().padding(.top, 14)
        }
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(title: L("体重")) {
                PillSegment(options: [(7, L("1週")), (30, L("1か月")), (90, L("3か月"))], selection: $store.graphRange)
            }
            WeightChart(range: store.graphRange, height: 200, showAverage: true)
            HStack(spacing: 14) {
                legend(label: L("体重")) { Capsule().fill(Palette.rose).frame(width: 16, height: 3) }
                legend(label: L("7日平均")) { Rectangle().fill(Palette.ink.opacity(0.45)).frame(width: 16, height: 2) }
                legend(label: L("もくひょう")) {
                    Line().stroke(Palette.mint, style: StrokeStyle(lineWidth: 2, dash: [4, 2])).frame(width: 16, height: 2)
                }
            }
            .padding(.top, 6)
        }
        .card()
    }

    private func legend<M: View>(label: String, @ViewBuilder mark: () -> M) -> some View {
        HStack(spacing: 4) {
            mark()
            Text(label).font(.ui(11)).foregroundStyle(Palette.inkSoft)
        }
    }

    @ViewBuilder
    private var statsGrid: some View {
        let ws = store.points(lastDays: store.graphRange).map(\.weight)
        if let first = ws.first, let last = ws.last, let lo = ws.min(), let hi = ws.max() {
            let ch = last - first
            let avg = ws.reduce(0, +) / Double(ws.count)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())], spacing: 10) {
                StatTile(label: L("へいきん"), value: Fmt.kg(avg), note: LF("%d日分のきろく", ws.count))
                StatTile(label: L("この期間の変化"), value: Fmt.signed(ch), valueColor: deltaColor(ch), note: ch < 0 ? L("いい流れ！") : L("ここから巻き返そ"))
                StatTile(label: L("いちばん軽い"), value: Fmt.kg(lo), note: ws.firstIndex(of: lo) == ws.count - 1 ? L("さいしんが最軽量！") : L("更新をめざそう"))
                StatTile(label: L("いちばん重い"), value: Fmt.kg(hi), note: LF("差は %@kg", Fmt.kg(hi - lo)))
            }
            .coachTarget("graph.stats")
            .padding(.top, 14)
        }
    }
}

/// .stat
struct StatTile: View {
    let label: String
    let value: String
    var valueColor: Color = Palette.ink
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label).font(.ui(11)).tracking(0.66).foregroundStyle(Palette.inkSoft)
            Text("\(Text(value).foregroundStyle(valueColor))\(Text("kg").font(.num(12, .bold)))")
                .font(.num(26, .bold))
                .foregroundStyle(Palette.ink)
                .numLineHeight(1.25, size: 26)
            Text(note).font(.ui(11)).foregroundStyle(Palette.inkSoft)
        }
        .padding(.vertical, 14).padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 22).fill(Palette.card))
        .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(Palette.line, lineWidth: 2))
    }
}

// MARK: - BMI

struct BMICard: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let latest = store.latestWeight
        let h = Double(store.settings.height) / 100
        let bmi = latest.map { $0 / (h * h) }
        let cat = category(bmi)
        VStack(alignment: .leading, spacing: 0) {
            CardTitle("BMI", note: LF("身長 %dcm で計算", store.settings.height))
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bmi.map { String(format: "%.1f", $0) } ?? "—")
                        .font(.num(40)).foregroundStyle(Palette.ink)
                        .numLineHeight(1, size: 40)
                    Text(bmi == nil ? L("体重をきろくすると計算するよ") : LF("%1$@（最新 %2$@kg）", cat.label, Fmt.kg(latest ?? 0)))
                        .font(.ui(12)).foregroundStyle(Palette.mintInk)
                }
                Spacer(minLength: 0)
                Image(cat.mood.smallAsset).resizable().scaledToFit().frame(width: 64, height: 64)
            }
            gauge(bmi: bmi).padding(.top, 14)
            HStack {
                Text(L("体脂肪率（さいしん）")).font(.ui(13)).foregroundStyle(Palette.ink)
                Spacer()
                if let fat = latestFat {
                    Text("\(Text(Fmt.kg(fat)).font(.num(17, .bold)))%").font(.ui(13)).foregroundStyle(Palette.ink)
                } else {
                    Text("—").font(.ui(13)).foregroundStyle(Palette.ink)
                }
            }
            .padding(.top, 10)
            .overlay(alignment: .top) {
                Line().stroke(Palette.line, style: StrokeStyle(lineWidth: 1.5, dash: [4.5, 3])).frame(height: 1.5)
            }
            .padding(.top, 10)
        }
        .card()
    }

    private var latestFat: Double? {
        store.sortedDates.reversed().lazy.compactMap { store.entries[$0]?.fat }.first
    }

    private func category(_ bmi: Double?) -> (label: String, mood: Mood) {
        guard let bmi else { return ("", .hmm) }
        if bmi < 18.5 { return (L("やせぎみ"), .tired) }
        if bmi < 25 { return (L("ふつう"), .good) }
        if bmi < 30 { return (L("ちょっと多め"), .trouble) }
        return (L("多め"), .crying)
    }

    /// .gauge（18.5 / 25 / 30 で区切った帯 ＋ 目印）
    private func gauge(bmi: Double?) -> some View {
        let segments: [(Double, Color)] = [(18.5, Palette.sky), (32.5, Palette.mint), (25, Palette.gold), (24, Palette.rose)]
        let pos: Double? = bmi.map { b in
            if b <= 18.5 { return b }
            if b <= 25 { return 18.5 + (b - 18.5) / 6.5 * 32.5 }
            if b <= 30 { return 51 + (b - 25) / 5 * 25 }
            return min(100, 76 + (b - 30) / 10 * 24)
        }
        return VStack(spacing: 6) {
            GeometryReader { geo in
                let w = geo.size.width
                HStack(spacing: 0) {
                    ForEach(segments.indices, id: \.self) { i in
                        Rectangle().fill(segments[i].1).frame(width: w * segments[i].0 / 100)
                    }
                }
                .frame(width: w, height: 12)
                .clipShape(Capsule())
                .overlay(alignment: .topLeading) {
                    if let pos {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Palette.ink)
                            .frame(width: 4, height: 24)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Palette.card).padding(-2))
                            .offset(x: w * pos / 100 - 2, y: -6)
                    }
                }
            }
            .frame(height: 12)
            GeometryReader { geo in
                ForEach([(18.5, "18.5"), (51.0, "25"), (76.0, "30")], id: \.0) { p, label in
                    Text(label).font(.num(11, .semibold)).foregroundStyle(Palette.inkSoft)
                        .fixedSize()
                        .position(x: geo.size.width * p / 100, y: 8)
                }
            }
            .frame(height: 16)
        }
    }
}

// MARK: - カレンダー

struct CalendarCard: View {
    @EnvironmentObject private var store: WeightStore

    private var month: Date {
        let c = Calendar.app
        let start = c.date(from: c.dateComponents([.year, .month], from: .today)) ?? .today
        return c.date(byAdding: .month, value: store.calendarOffset, to: start) ?? start
    }

    var body: some View {
        let c = Calendar.app
        let comps = c.dateComponents([.year, .month], from: month)
        let leading = c.component(.weekday, from: month) - 1
        let days = c.range(of: .day, in: .month, for: month)?.count ?? 30
        let weekdays = Fmt.weekdayInitials
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(title: L("カレンダー")) {
                HStack(spacing: 6) {
                    monthButton("‹", enabled: store.calendarOffset > -3) { store.calendarOffset -= 1 }
                        .accessibilityLabel(L("前の月"))
                    Text("\(String(comps.year ?? 0)).\(comps.month ?? 0)")
                        .font(.ui(15, .black))
                        .foregroundStyle(Palette.ink)
                        .frame(minWidth: 64)
                    monthButton("›", enabled: store.calendarOffset < 0) { store.calendarOffset += 1 }
                        .accessibilityLabel(L("次の月"))
                }
            }
            // LazyVGrid は使わない：まだ描いていない行の高さを見積もりで数えるため、
            // カードの高さが中身より短くなり、上下に文字がはみ出すことがあった
            let weeks = (leading + days + 6) / 7
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(weekdays.indices, id: \.self) { i in
                        Text(weekdays[i])
                            .font(.ui(11))
                            .foregroundStyle(i == 0 ? Palette.up : Palette.inkSoft)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 2)
                    }
                }
                ForEach(0..<weeks, id: \.self) { week in
                    HStack(alignment: .top, spacing: 4) {
                        ForEach(0..<7, id: \.self) { weekday in
                            let day = week * 7 + weekday - leading + 1
                            if (1...days).contains(day) {
                                CalendarCell(date: month.adding(days: day - 1), day: day)
                            } else {
                                Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
                            }
                        }
                    }
                }
            }
            Hint(L("日付をタップすると、その日のようすが見られるよ（記録がない日は入力できるよ）。赤い点はタグ付きの日"))
                .padding(.top, 4)
                .padding(.bottom, 4)
        }
        .card()
    }

    private func monthButton(_ s: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(s).font(.ui(15, .black)).foregroundStyle(Palette.ink)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Palette.blush))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.3)
    }
}

/// .cal .cell
struct CalendarCell: View {
    let date: Date
    let day: Int
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let entry = store.entries[date]
        // 記録のない日は、記録シートでさかのぼれる119日前までだけ押せる
        if date > .today || (entry == nil && date.days(to: .today) > 119) {
            cell(entry: entry)
        } else {
            Button { store.openDay(date, from: L("カレンダー")) } label: { cell(entry: entry) }
                .buttonStyle(.plain)
                .accessibilityLabel(entry.map { LF("%@ %@kg", Fmt.monthDay(date), Fmt.kg($0.weight)) } ?? LF("%@ 未記録", Fmt.monthDay(date)))
        }
    }

    private func cell(entry: WeightEntry?) -> some View {
        VStack(spacing: 1) {
            Text("\(day)").font(.num(11, .semibold))
                .foregroundStyle(entry != nil ? Palette.inkSoft : Color(hex: 0xC7B6A8))
                .numLineHeight(1.1, size: 11)
            if let entry {
                Image(store.mood(for: date).smallAsset).resizable().scaledToFit().frame(width: 28, height: 28)
                Text(Fmt.kg(entry.weight)).font(.num(10.5, .bold)).tracking(-0.21).foregroundStyle(Palette.ink)
                    .numLineHeight(1, size: 10.5)
            }
        }
        .padding(.top, 4).padding(.bottom, 5)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .top)
        .background(RoundedRectangle(cornerRadius: 12).fill(entry != nil ? Palette.faceBG : .clear))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(date == .today ? Palette.ink : .clear, lineWidth: 2))
        .overlay(alignment: .topTrailing) {
            if !(entry?.tags.isEmpty ?? true) {
                Circle().fill(Palette.rose).frame(width: 6, height: 6).padding(4)
            }
        }
        .contentShape(Rectangle())
    }
}
