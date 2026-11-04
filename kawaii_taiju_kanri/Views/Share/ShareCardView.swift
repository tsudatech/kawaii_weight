//
//  ShareCardView.swift
//  kawaii_taiju_kanri
//
//  シェア用の体重カード（1080×1350）。座標はデモの canvas と同じ。
//  体重の数字は「のせる」を選んだときだけ入る。
//

import SwiftUI

enum ShareCardKind: Hashable {
    case day, week
}

/// カードに描くもの（ImageRenderer で描くので、WeightStore に頼らない形にしておく）
struct ShareCardData {
    struct DayFaceItem {
        let date: Date
        let mood: Mood?
        let weight: Double?
    }

    var kind: ShareCardKind
    var showNumbers: Bool
    var colors: [Color]
    var date: Date
    // この日
    var mood: Mood = .good
    var line = ""
    var streak = 0
    var weight: Double?
    var diff: Double?
    var diffLabel = ""
    var recordCount = 0
    var guessHit = false
    var guessLevel: Int?
    // 1週間
    var days: [DayFaceItem] = []
    var guessHits: Int?

    static let palettes: [[Color]] = [
        [Color(hex: 0xFBE3DF), Color(hex: 0xF6CFC8)],
        [Color(hex: 0xE3F3EF), Color(hex: 0xC7E6DE)],
        [Color(hex: 0xFFF3D9), Color(hex: 0xF6DFAE)],
        [Color(hex: 0xE9EEF7), Color(hex: 0xCED9EC)],
    ]
}

extension WeightStore {
    func shareCardData(date: Date, kind: ShareCardKind, showNumbers: Bool, palette: Int) -> ShareCardData {
        var d = ShareCardData(kind: kind, showNumbers: showNumbers, colors: ShareCardData.palettes[palette], date: date)
        d.streak = streak(at: date)
        switch kind {
        case .day:
            let face = dayFace(date)
            let mood = face?.mood ?? .good
            d.mood = mood
            d.line = (date == .today ? todayState.line : face?.line) ?? mood.lines[0]
            d.weight = entries[date]?.weight
            d.diff = judge(date)?.diff
            d.diffLabel = settings.judge == .trend ? L("7日平均から") : L("まえの日から")
            d.recordCount = sortedDates.filter { $0 <= date }.count
            if settings.game {
                d.guessHit = guessResult(date)?.hit == true
                d.guessLevel = guessStats.level
            }
        case .week:
            let days = (0..<7).reversed().map { date.adding(days: -$0) }
            d.days = days.map { ShareCardData.DayFaceItem(date: $0, mood: entries[$0] == nil ? nil : mood(for: $0), weight: entries[$0]?.weight) }
            if settings.game {
                d.guessHits = days.filter { guessResult($0)?.hit == true }.count
            }
        }
        return d
    }

    /// その日までの連続記録
    private func streak(at date: Date) -> Int {
        var s = 0
        var d = date
        while entries[d] != nil {
            s += 1
            d = d.adding(days: -1)
        }
        return s
    }
}

struct ShareCardView: View {
    let data: ShareCardData

    private let ink = Palette.ink, soft = Palette.inkSoft

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: data.colors, startPoint: .top, endPoint: .bottom)
            RoundedRectangle(cornerRadius: 64).fill(Palette.paper)
                .overlay(RoundedRectangle(cornerRadius: 64).strokeBorder(ink.opacity(0.12), lineWidth: 6))
                .place(60, 60, 960, 1230)
            if data.kind == .day { dayCard } else { weekCard }
            Text(LF("%1$@ ・ #%2$@", L("たいかん！"), L("たいかん")))
                .font(.ui(28))
                .foregroundStyle(Color(hex: 0xB5A193))
                .frame(maxWidth: .infinity)
                .place(60, 1232, 960, 44)
        }
        .frame(width: 1080, height: 1350)
    }

    // MARK: - この日

    private var dayCard: some View {
        // ふきだしが2行になっても、下の統計がフッターにかからない配置（デモから縦を少しつめた）
        let lines = BalancedText.balanced(data.line).split(separator: "\n").count
        let oneLine = data.line.count <= 18
        let bubbleH: CGFloat = oneLine ? 104 : (lines > 1 ? 152 : 104)
        let bubbleY: CGFloat = 866
        let statY = bubbleY + bubbleH + 30
        let col = deltaColor(data.diff)
        return ZStack(alignment: .topLeading) {
            Text(Fmt.dayTitle(data.date)).font(.ui(46, .black)).foregroundStyle(ink).lineLimit(1).place(120, 110, 620, 70, .leading)
            Text("🔥 " + LF("%d日れんぞく", data.streak)).font(.ui(30)).foregroundStyle(soft).lineLimit(1).place(620, 118, 340, 60, .trailing)
            RoundedRectangle(cornerRadius: 52)
                .fill(LinearGradient(colors: [Palette.heroTop, Palette.heroBottom], startPoint: .top, endPoint: .bottom))
                .overlay(RoundedRectangle(cornerRadius: 52).strokeBorder(Palette.heroBorder, lineWidth: 4))
                .place(120, 196, 840, 640)
            Image(data.mood.largeAsset).resizable().scaledToFit().place(280, 214, 520, 520)
            Text(data.mood.label).font(.ui(40, .black)).foregroundStyle(ink).frame(maxWidth: .infinity).place(120, 748, 840, 64)
            if data.guessHit {
                VStack(spacing: 0) {
                    Text(L("よそう")).font(.ui(30, .black))
                    Text(L("あたり！")).font(.ui(38, .black))
                }
                .foregroundStyle(.white)
                .frame(width: 184, height: 184)
                .background(Circle().fill(Palette.rose))
                .overlay(Circle().strokeBorder(.white, lineWidth: 8))
                .rotationEffect(.radians(-0.18))
                .place(768, 238, 184, 184)
            }
            // ふきだし
            RoundedRectangle(cornerRadius: 40).fill(.white)
                .overlay(RoundedRectangle(cornerRadius: 40).strokeBorder(ink, lineWidth: 5))
                .place(120, bubbleY, 840, bubbleH)
            BubbleTail().fill(.white).place(505, bubbleY - 37, 70, 42)
            BubbleTail().stroke(ink, style: StrokeStyle(lineWidth: 5, lineJoin: .round)).place(505, bubbleY - 37, 70, 39)
            Text(lines > 1 && !oneLine ? BalancedText.balanced(data.line) : data.line)
                .font(.ui(40, .black))
                .foregroundStyle(ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .place(150, bubbleY + 6, 780, bubbleH - 12)
            // 統計
            if data.showNumbers {
                stat(L("この日の体重"), data.weight.map { "\(Fmt.kg($0))kg" } ?? "—", num: true).place(120, statY, 266, 150)
                stat(data.diffLabel, data.diff.map { "\(Fmt.signed($0))kg" } ?? "—", num: true, color: col).place(407, statY, 266, 150)
            } else {
                stat(L("ながれ"), flowWord(data.diff), color: col).place(120, statY, 266, 150)
                stat(L("きろく"), LF("%d回め", data.recordCount)).place(407, statY, 266, 150)
            }
            if let lv = data.guessLevel {
                stat(L("よそう"), "Lv.\(lv)", num: true).place(694, statY, 266, 150)
            } else {
                stat(L("れんぞく"), LF("%d日", data.streak)).place(694, statY, 266, 150)
            }
        }
    }

    private func flowWord(_ d: Double?) -> String {
        guard let d else { return L("はじめて") }
        return d <= -0.1 ? L("いい流れ") : d <= 0.1 ? L("いつもどおり") : L("ふえ気味")
    }

    // MARK: - 1週間

    private var weekCard: some View {
        let pts = data.days.enumerated().compactMap { i, d in d.weight.map { (i: i, w: $0) } }
        let recorded = pts.count
        let graphY: CGFloat = data.showNumbers ? 500 : 470
        let graphH: CGFloat = 490
        let statY = graphY + graphH + 30
        let change = pts.count > 1 ? ((pts[pts.count - 1].w - pts[0].w) * 10).rounded() / 10 : nil
        let big: Mood = recorded >= 6 ? .doya : recorded >= 3 ? .good : .cheer
        return ZStack(alignment: .topLeading) {
            Text(L("この1週間")).font(.ui(52, .black)).foregroundStyle(ink).place(120, 106, 700, 76, .leading)
            Text("\(Fmt.slash(data.days.first?.date ?? data.date)) 〜 \(Fmt.slash(data.date))").font(.ui(30)).foregroundStyle(soft).place(120, 180, 700, 48, .leading)
            ForEach(Array(data.days.enumerated()), id: \.offset) { i, d in
                let x = 120 + CGFloat(i) * 120
                VStack(spacing: 8) {
                    Text(Fmt.weekday(d.date))
                        .font(.ui(28))
                        .foregroundStyle(Calendar.app.component(.weekday, from: d.date) == 1 ? Palette.up : soft)
                    if let m = d.mood {
                        Image(m.smallAsset).resizable().scaledToFit()
                            .frame(width: 100, height: 100)
                            .background(Circle().fill(Palette.faceBG).frame(width: 108, height: 108))
                    } else {
                        Circle().strokeBorder(Color(hex: 0xE3D5C9), style: StrokeStyle(lineWidth: 4, dash: [10, 10]))
                            .frame(width: 100, height: 100)
                    }
                    if data.showNumbers, let w = d.weight {
                        Text(Fmt.kg(w)).font(.num(30, .bold)).foregroundStyle(ink)
                    }
                }
                .place(x, 258, 120, 220)
            }
            RoundedRectangle(cornerRadius: 44).fill(Palette.faceBG).place(120, graphY, 840, graphH)
            if pts.count > 1 {
                WeekLine(points: pts.map { ($0.i, $0.w) })
                    .place(120, graphY, 840, graphH)
            } else {
                Text(L("きろくが2日分たまると線が出るよ"))
                    .font(.ui(30)).foregroundStyle(Color(hex: 0xB5A193))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .place(120, graphY, 840, graphH)
            }
            stat(L("きろく"), LF("%d / 7日", recorded)).place(120, statY, 270, 150)
            if data.showNumbers {
                stat(L("この週の変化"), change.map { "\(Fmt.signed($0))kg" } ?? "—", num: true, color: deltaColor(change)).place(410, statY, 270, 150)
            } else if let hits = data.guessHits {
                stat(L("よそう"), LF("%d回あたり", hits)).place(410, statY, 270, 150)
            } else {
                stat(L("れんぞく"), LF("%d日", data.streak)).place(410, statY, 270, 150)
            }
            Image(big.largeAsset).resizable().scaledToFit().place(690, statY - 110, 270, 270)
        }
    }

    // MARK: - 部品

    /// shStat
    private func stat(_ label: String, _ value: String, num: Bool = false, color: Color = Palette.ink) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.ui(27)).foregroundStyle(soft).lineLimit(1).minimumScaleFactor(0.6)
            Group {
                if num {
                    Text(num: value, size: 52, weight: .heavy)
                } else {
                    Text(value).font(.ui(40, .black))
                }
            }
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 36).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: 36).strokeBorder(Palette.line, lineWidth: 4))
    }
}

/// カードの座標（左上）に置く
private extension View {
    func place(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ alignment: Alignment = .center) -> some View {
        frame(width: w, height: h, alignment: alignment).offset(x: x, y: y)
    }
}

/// ふきだしの上のしっぽ
private struct BubbleTail: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        return p
    }
}

/// 目盛りのない線（7日ぶん）
private struct WeekLine: View {
    let points: [(i: Int, w: Double)]

    var body: some View {
        Canvas { ctx, size in
            let ws = points.map(\.w)
            let lo = (ws.min() ?? 0) - 0.2, hi = (ws.max() ?? 0) + 0.2
            let at = { (p: (i: Int, w: Double)) in CGPoint(x: 60 + CGFloat(p.i) * 120, y: 70 + (size.height - 140) * CGFloat(1 - (p.w - lo) / (hi - lo))) }
            var line = Path()
            for (n, p) in points.enumerated() {
                if n == 0 { line.move(to: at(p)) } else { line.addLine(to: at(p)) }
            }
            ctx.stroke(line, with: .color(Palette.rose), style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
            for p in points {
                let c = at(p)
                let dot = Path(ellipseIn: CGRect(x: c.x - 12, y: c.y - 12, width: 24, height: 24))
                ctx.fill(dot, with: .color(.white))
                ctx.stroke(dot, with: .color(Palette.rose), lineWidth: 6)
            }
        }
    }
}

// MARK: - カードをシェアするシート（#shareSheet）

struct ShareSheet: View {
    let date: Date

    @EnvironmentObject private var store: WeightStore
    /// 種類といろは、開きなおしても残す（デモと同じ）。数字は毎回「のせない」から
    @AppStorage("share.kindIsWeek") private var isWeek = false
    @AppStorage("share.palette") private var palette = 0
    @State private var showNumbers = false
    @State private var image: UIImage?
    @State private var drag: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            ScrollView {
                content
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
            .fixedSize(horizontal: false, vertical: true)
            .background(UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30).fill(Palette.paper).ignoresSafeArea(edges: .bottom))
            .offset(y: drag)
        }
        .onAppear(perform: render)
        .onChange(of: isWeek) { _, _ in render() }
        .onChange(of: palette) { _, _ in render() }
        .onChange(of: showNumbers) { _, _ in render() }
    }

    private var content: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Capsule().fill(Color(hex: 0xDCCBBE)).frame(width: 40, height: 5)
                HStack {
                    Color.clear.frame(width: 32, height: 32)
                    Spacer(minLength: 0)
                    Text(L("カードをシェア")).font(.ui(17, .black)).foregroundStyle(Palette.ink)
                    Spacer(minLength: 0)
                    Button { store.sharingDate = nil } label: {
                        Text("×").font(.ui(14, .black)).foregroundStyle(Palette.ink)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(hex: 0xF3ECE6)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L("とじる"))
                }
            }
            .contentShape(Rectangle())
            .gesture(pullDown)

            preview.padding(.top, 6)

            VStack(spacing: 10) {
                HStack {
                    Text(L("カード"))
                    Spacer()
                    PillSegment(options: [(false, L("この日")), (true, L("1週間"))], selection: $isWeek)
                }
                HStack {
                    Text(L("体重の数字をのせる"))
                    Spacer()
                    CSSSwitch(isOn: $showNumbers, label: L("体重の数字をのせる"))
                }
                HStack {
                    Text(L("いろ"))
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(ShareCardData.palettes.indices, id: \.self) { swatch($0) }
                    }
                }
            }
            .font(.ui(13, .black))
            .foregroundStyle(Palette.ink)
            .padding(.top, 14)

            if let image {
                ShareLink(item: Image(uiImage: image), preview: SharePreview(L("体重カード"), image: Image(uiImage: image))) {
                    Text(L("シェアする"))
                }
                .buttonStyle(.primary)
                .padding(.top, 16)
            }
            Text(L("体重の数字は、のせるを選んだときだけカードに入ります"))
                .font(.ui(11))
                .foregroundStyle(Palette.inkSoft)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
        }
        .padding(.top, 10).padding(.horizontal, 18).padding(.bottom, 34)
    }

    @ViewBuilder
    private var preview: some View {
        Group {
            if let image {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                Palette.blush
            }
        }
        .aspectRatio(4 / 5, contentMode: .fit)
        .frame(height: 330)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Palette.ink.opacity(0.3), radius: 13, y: 10)
        .accessibilityLabel(L("シェア用のカード"))
    }

    private func swatch(_ i: Int) -> some View {
        Button { palette = i } label: {
            Circle()
                .fill(LinearGradient(colors: ShareCardData.palettes[i], startPoint: .top, endPoint: .bottom))
                .frame(width: 30, height: 30)
                .overlay(Circle().strokeBorder(.white, lineWidth: 3))
                .background(Circle().strokeBorder(palette == i ? Palette.ink : Palette.line, lineWidth: 2).padding(-2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(LF("いろ %d", i + 1))
        .accessibilityAddTraits(palette == i ? .isSelected : [])
    }

    private var pullDown: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged { drag = max(0, $0.translation.height) }
            .onEnded { v in
                if v.translation.height > 120 || v.predictedEndTranslation.height > 300 {
                    store.sharingDate = nil
                } else {
                    withAnimation(.slide) { drag = 0 }
                }
            }
    }

    private func render() {
        let data = store.shareCardData(date: date, kind: isWeek ? .week : .day, showNumbers: showNumbers, palette: min(palette, ShareCardData.palettes.count - 1))
        let renderer = ImageRenderer(content: ShareCardView(data: data))
        renderer.scale = 1
        image = renderer.uiImage
    }
}
