//
//  DayDetailView.swift
//  kawaii_taiju_kanri
//
//  日の詳細（日記ページ）。カレンダー／りれきから右からすべりこむ
//

import SwiftUI

struct DayDetailView: View {
    let date: Date

    @EnvironmentObject private var store: WeightStore
    @ObservedObject private var ads = AdService.shared
    @State private var bounce = 0
    @State private var position = ScrollPosition(edge: .top)
    /// 左端から右へスワイプしているときのずれ
    @State private var swipe: CGFloat = 0

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    if let entry = store.entries[date], let face = store.dayFace(date) {
                        stage(entry: entry, face: face)
                        metrics(entry: entry).padding(.top, 12)
                        weekCard.padding(.top, 14)
                        memoCard(entry: entry).padding(.top, 14)
                        prevNext.padding(.top, 14)
                    }
                } header: {
                    nav
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 110 + ads.bannerHeight)
        }
        .scrollPosition($position)
        .scrollIndicators(.hidden)
        .background(Palette.paper)
        // ステータスバーの下に記事が透けないようにする
        .overlay(alignment: .top) {
            Color.clear.frame(height: 0).background(Palette.paper.ignoresSafeArea(edges: .top))
        }
        // 左端から右へスワイプでもどる
        .overlay(alignment: .leading) { edgeSwipeArea }
        .offset(x: swipe)
        .shadow(color: Palette.ink.opacity(swipe > 0 ? 0.12 : 0), radius: 10, x: -4)
    }

    /// 左端の細い帯。ここから右へ引っぱると、指について動き、離したときに半分ほど進んでいればもどる
    private var edgeSwipeArea: some View {
        GeometryReader { geo in
            Color.clear
                .frame(width: 20)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .global)
                        .onChanged { v in swipe = max(0, v.translation.width) }
                        .onEnded { v in
                            let width = geo.size.width
                            if v.translation.width > width * 0.35 || v.predictedEndTranslation.width > width * 0.6 {
                                store.detailDate = nil
                            } else {
                                withAnimation(.slide) { swipe = 0 }
                            }
                        }
                )
        }
        .frame(width: 20)
        .ignoresSafeArea()
    }

    /// .dNav（‹ もどる ・ 日付 ・ 編集）
    private var nav: some View {
        HStack(spacing: 8) {
            Button("‹ \(store.detailFrom)") { store.detailDate = nil }
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(Fmt.dayTitle(date)).font(.ui(16, .black)).foregroundStyle(Palette.ink)
            Button(L("編集")) { store.editing = SheetTarget(date: date) }
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.ui(15, .black))
        .foregroundStyle(Palette.rose)
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .padding(.top, 6).padding(.bottom, 10)
        .background(Palette.paper)
    }

    /// .dStage
    private func stage(entry: WeightEntry, face: DayFace) -> some View {
        VStack(spacing: 0) {
            if store.settings.talk {
                SpeechBubble(text: face.line ?? face.mood.lines[0], tail: .bottom, fontSize: 14, paddingV: 8, fillWidth: false)
                    .padding(.bottom, 6)
            }
            CharacterView(asset: face.mood.largeAsset, size: 160, bounceKey: bounce, breathe: false)
                .padding(.top, store.settings.talk ? 0 : 4)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(Fmt.kg(entry.weight)).font(.num(52)).numLineHeight(1, size: 52)
                Text("kg").font(.ui(16)).foregroundStyle(Palette.inkSoft)
            }
            .foregroundStyle(Palette.ink)
            .padding(.top, 4)
            Text([face.mood.label, entry.fat.map { LF("体脂肪 %@%%", Fmt.kg($0)) }].compactMap { $0 }.joined(separator: L(" ・ ")))
                .font(.ui(12))
                .foregroundStyle(Palette.inkSoft)
                .padding(.top, 4)
        }
        .padding(.top, 18).padding(.horizontal, 16).padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .heroBackground()
    }

    /// .dMetrics
    private func metrics(entry: WeightEntry) -> some View {
        let ds = store.sortedDates
        let i = ds.firstIndex(of: date) ?? 0
        let prev = i > 0 ? ds[i - 1] : nil
        let prevLabel = prev.map { $0.days(to: date) == 1 ? L("まえの日から") : L("まえの記録から") } ?? L("まえの記録から")
        let prevDiff = prev.flatMap { store.entries[$0] }.map { ((entry.weight - $0.weight) * 10).rounded() / 10 }
        let avgDiff = store.average7(before: date).map { ((entry.weight - $0) * 10).rounded() / 10 }
        let left = entry.weight - store.settings.goal
        return HStack(spacing: 8) {
            metric(prevLabel) { diffValue(prevDiff) }
            metric(L("7日平均から")) { diffValue(avgDiff) }
            metric(L("もくひょうまで")) {
                if left <= 0 {
                    Text(L("達成！")).font(.ui(15)).foregroundStyle(Palette.mintInk)
                } else {
                    Text("\(Text(Fmt.kg(left)).font(.num(19, .bold)))\(Text("kg").font(.num(11, .bold)))").foregroundStyle(Palette.ink)
                }
            }
        }
    }

    private func diffValue(_ v: Double?) -> Text {
        guard let v else { return Text("—").font(.num(19, .bold)).foregroundStyle(Palette.ink) }
        return Text("\(Text(Fmt.signed(v)).font(.num(19, .bold)))\(Text("kg").font(.num(11, .bold)))").foregroundStyle(deltaColor(v))
    }

    private func metric<V: View>(_ label: String, @ViewBuilder value: () -> V) -> some View {
        VStack(spacing: 0) {
            Text(label).font(.ui(10.5)).foregroundStyle(Palette.inkSoft)
            value().numLineHeight(1.3, size: 19)
        }
        .padding(.vertical, 10).padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18).fill(Palette.card))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Palette.line, lineWidth: 2))
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(L("前後1週間"), note: L("この日を●で表示"))
            WeekChart(center: date)
        }
        .card()
    }

    /// .dMemo
    private func memoCard(entry: WeightEntry) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(L("この日のこと"))
            if !entry.tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(entry.tags, id: \.self) { TagChip(title: L($0), on: true) }
                }
                .padding(.bottom, 6)
            }
            if let memo = entry.memo {
                Text(memo).font(.ui(14)).foregroundStyle(Palette.ink).lineHeight(1.6, size: 14)
            } else if entry.tags.isEmpty {
                Text(L("タグもメモもない日だよ。「編集」から書きこめるよ"))
                    .font(.ui(13)).foregroundStyle(Palette.inkSoft).lineHeight(1.6, size: 13)
            }
        }
        .card()
    }

    /// .dPN
    private var prevNext: some View {
        let ds = store.sortedDates
        let i = ds.firstIndex(of: date) ?? 0
        let prev = i > 0 ? ds[i - 1] : nil
        let next = i < ds.count - 1 ? ds[i + 1] : nil
        return HStack(spacing: 8) {
            neighbor(prev, forward: false)
            neighbor(next, forward: true)
        }
    }

    private func neighbor(_ d: Date?, forward: Bool) -> some View {
        Button {
            guard let d else { return }
            store.detailDate = d
            bounce += 1
            withAnimation(.easeInOut(duration: 0.35)) { position.scrollTo(edge: .top) }
        } label: {
            HStack(spacing: 6) {
                if let d, let e = store.entries[d] {
                    let face = Image(store.mood(for: d).smallAsset).resizable().scaledToFit().frame(width: 34, height: 34)
                    let txt = VStack(alignment: forward ? .trailing : .leading, spacing: 0) {
                        Text(Fmt.slash(d))
                        Text(Fmt.kg(e.weight)).font(.num(15, .bold))
                    }
                    if forward {
                        Spacer(minLength: 0)
                        txt
                        face
                        Text("›")
                    } else {
                        Text("‹")
                        face
                        txt
                        Spacer(minLength: 0)
                    }
                } else {
                    Text(forward ? L("これより後の記録はないよ") : L("これより前の記録はないよ"))
                        .frame(maxWidth: .infinity, alignment: forward ? .trailing : .leading)
                        .multilineTextAlignment(forward ? .trailing : .leading)
                }
            }
            .font(.ui(12))
            .foregroundStyle(Palette.ink)
            .padding(.vertical, 8).padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(RoundedRectangle(cornerRadius: 18).fill(Palette.card))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Palette.line, lineWidth: 2))
            .opacity(d == nil ? 0.35 : 1)
        }
        .buttonStyle(.plain)
        .disabled(d == nil)
    }
}
