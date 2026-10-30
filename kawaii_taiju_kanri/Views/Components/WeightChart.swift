//
//  WeightChart.swift
//  kawaii_taiju_kanri
//
//  体重の推移グラフ。デモの SVG（viewBox 320×H）と同じ座標で描き、横幅に合わせて拡大する
//

import SwiftUI

/// グラフに描くもの（座標は viewBox のまま）
private struct ChartDrawing {
    struct Label {
        var text: String
        var at: CGPoint
        /// 文字の基準：-1 左寄せ / 0 中央 / 1 右寄せ（text-anchor）
        var anchor: Int
        var size: CGFloat = 11
        var weight: Font.Weight = .semibold
        var color: Color = Palette.inkSoft
        var ui = false
    }

    var H: CGFloat
    var grid: [CGFloat] = []
    var labels: [Label] = []
    var goalY: CGFloat?
    var line: [CGPoint] = []
    var lineWidth: CGFloat = 3
    var areaBottom: CGFloat = 0
    var average: [CGPoint] = []
    var dots: [(CGPoint, CGFloat, Bool)] = []
    var gridFrom: CGFloat = 0
    var gridTo: CGFloat = 320
    var marker: (x: CGFloat, top: CGFloat, bottom: CGFloat, point: CGPoint)?
    var empty = false
    /// 記録はあるが、この期間にないだけ
    var hasAnyEntry = false
}

/// ホーム（14日）・グラフ（7/30/90日）の推移グラフ（drawChart）
struct WeightChart: View {
    let range: Int
    let height: CGFloat
    var showAverage = false

    @EnvironmentObject private var store: WeightStore

    var body: some View {
        ChartCanvas(drawing: drawing)
    }

    private var drawing: ChartDrawing {
        let today = Date.today
        let todayLabel = L("きょう")
        let W: CGFloat = 320, L: CGFloat = 34, R: CGFloat = 10, T: CGFloat = 16, B: CGFloat = 26, H = height
        var d = ChartDrawing(H: H)
        let pts: [(i: Int, w: Double, date: Date)] = (0..<range).reversed().compactMap { ago in
            let date = today.adding(days: -ago)
            return store.entries[date].map { (range - 1 - ago, $0.weight, date) }
        }
        guard !pts.isEmpty else {
            d.empty = true
            d.hasAnyEntry = !store.entries.isEmpty
            return d
        }
        let goal = store.settings.goal
        let ws = pts.map(\.w) + [goal]
        let lo = floor((ws.min() ?? 0) - 0.3), hi = ceil((ws.max() ?? 0) + 0.3)
        let x = { (i: Int) in L + (W - L - R) * CGFloat(i) / CGFloat(range - 1) }
        let y = { (w: Double) in T + (H - T - B) * CGFloat(1 - (w - lo) / (hi - lo)) }
        let step = hi - lo > 6 ? 2.0 : 1.0
        d.gridFrom = L
        d.gridTo = W - R
        for v in stride(from: lo, through: hi, by: step) {
            d.grid.append(y(v))
            d.labels.append(.init(text: "\(Int(v))", at: CGPoint(x: L - 6, y: y(v) + 4), anchor: 1))
        }
        let mid = Int((Double(range - 1) / 2).rounded())
        for (i, ago) in [(0, range - 1), (mid, range - 1 - mid), (range - 1, 0)] {
            let date = today.adding(days: -ago)
            d.labels.append(.init(
                text: ago == 0 ? todayLabel : Fmt.slash(date),
                at: CGPoint(x: x(i), y: H - 6),
                anchor: i == 0 ? -1 : i == range - 1 ? 1 : 0
            ))
        }
        d.goalY = y(goal)
        d.labels.append(.init(text: LF("もくひょう %@", Fmt.kg(goal)), at: CGPoint(x: W - R, y: y(goal) - 6), anchor: 1, color: Palette.mintInk))
        d.line = pts.map { CGPoint(x: x($0.i), y: y($0.w)) }
        d.areaBottom = H - B
        d.lineWidth = range > 40 ? 2.4 : 3
        if showAverage {
            // ホームの「7日平均」や表情の判定と同じく、その日より前の7日の平均（前の記録がない日は線を引かない）
            d.average = pts.compactMap { p in
                store.average7(before: p.date).map { CGPoint(x: x(p.i), y: y($0)) }
            }
        }
        for (j, p) in pts.enumerated() {
            let end = j == pts.count - 1
            let r: CGFloat = end ? 6 : range > 20 ? 0 : 2.8
            if r > 0 { d.dots.append((CGPoint(x: x(p.i), y: y(p.w)), r, end)) }
        }
        if let e = pts.last {
            d.labels.append(.init(text: Fmt.kg(e.w), at: CGPoint(x: min(x(e.i), W - R - 4), y: y(e.w) - 12), anchor: 1, size: 13, weight: .bold, color: Palette.ink))
        }
        return d
    }
}

/// 日の詳細の「前後1週間」（drawWeek）
struct WeekChart: View {
    let center: Date

    @EnvironmentObject private var store: WeightStore

    var body: some View {
        ChartCanvas(drawing: drawing)
    }

    private var drawing: ChartDrawing {
        let centerLabel = L("この日")
        let W: CGFloat = 320, H: CGFloat = 150, L: CGFloat = 30, R: CGFloat = 12, T: CGFloat = 18, B: CGFloat = 24
        var d = ChartDrawing(H: H)
        let pts: [(o: Int, w: Double)] = (-7...7).compactMap { o in
            store.entries[center.adding(days: o)].map { (o, $0.weight) }
        }
        guard let me = pts.first(where: { $0.o == 0 }) else { return d }
        let ws = pts.map(\.w)
        let lo = floor((ws.min() ?? 0) - 0.2), hi = ceil((ws.max() ?? 0) + 0.2)
        let x = { (o: Int) in L + (W - L - R) * CGFloat(o + 7) / 14 }
        let y = { (v: Double) in T + (H - T - B) * CGFloat(1 - (v - lo) / (hi - lo)) }
        d.gridFrom = L
        d.gridTo = W - R
        for v in stride(from: lo, through: hi, by: hi - lo > 4 ? 2 : 1) {
            d.grid.append(y(v))
            d.labels.append(.init(text: "\(Int(v))", at: CGPoint(x: L - 6, y: y(v) + 4), anchor: 1))
        }
        d.labels.append(.init(text: Fmt.slash(center.adding(days: -7)), at: CGPoint(x: x(-7), y: H - 6), anchor: -1))
        d.labels.append(.init(text: Fmt.slash(center.adding(days: 7)), at: CGPoint(x: x(7), y: H - 6), anchor: 1))
        if pts.count > 1 {
            d.line = pts.map { CGPoint(x: x($0.o), y: y($0.w)) }
            d.areaBottom = H - B
            d.lineWidth = 2.6
        }
        for p in pts where p.o != 0 {
            d.dots.append((CGPoint(x: x(p.o), y: y(p.w)), 2.6, false))
        }
        d.marker = (x(0), T - 6, H - B, CGPoint(x: x(0), y: y(me.w)))
        d.labels.append(.init(text: centerLabel, at: CGPoint(x: x(0), y: H - 6), anchor: 0, weight: .bold, color: Palette.ink))
        return d
    }
}

/// viewBox 320×H の座標で描いて、横幅いっぱいに拡大する
private struct ChartCanvas: View {
    let drawing: ChartDrawing

    var body: some View {
        let d = drawing
        Canvas { ctx, size in
            let s = size.width / 320
            ctx.scaleBy(x: s, y: s)
            if d.empty {
                drawEmpty(&ctx, d)
                return
            }
            for gy in d.grid {
                ctx.stroke(Path { p in p.move(to: CGPoint(x: d.gridFrom, y: gy)); p.addLine(to: CGPoint(x: d.gridTo, y: gy)) }, with: .color(Palette.grid), lineWidth: 1)
            }
            if let gy = d.goalY {
                ctx.stroke(Path { p in p.move(to: CGPoint(x: d.gridFrom, y: gy)); p.addLine(to: CGPoint(x: d.gridTo, y: gy)) },
                           with: .color(Palette.mint), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
            }
            if let first = d.line.first, let last = d.line.last {
                var area = polyline(d.line)
                area.addLine(to: CGPoint(x: last.x, y: d.areaBottom))
                area.addLine(to: CGPoint(x: first.x, y: d.areaBottom))
                area.closeSubpath()
                let top = d.line.map(\.y).min() ?? 0
                ctx.fill(area, with: .linearGradient(
                    Gradient(colors: [Palette.cheek.opacity(0.9), Palette.cheek.opacity(0)]),
                    startPoint: CGPoint(x: 0, y: top), endPoint: CGPoint(x: 0, y: d.areaBottom)))
            }
            if !d.average.isEmpty {
                ctx.stroke(polyline(d.average), with: .color(Palette.ink.opacity(0.45)), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
            }
            if !d.line.isEmpty {
                ctx.stroke(polyline(d.line), with: .color(Palette.rose), style: StrokeStyle(lineWidth: d.lineWidth, lineCap: .round, lineJoin: .round))
            }
            for (c, r, filled) in d.dots {
                let circle = Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
                ctx.fill(circle, with: .color(filled ? Palette.rose : .white))
                ctx.stroke(circle, with: .color(Palette.rose), lineWidth: 2)
            }
            if let m = d.marker {
                ctx.stroke(Path { p in p.move(to: CGPoint(x: m.x, y: m.top)); p.addLine(to: CGPoint(x: m.x, y: m.bottom)) },
                           with: .color(Palette.ink), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                let circle = Path(ellipseIn: CGRect(x: m.point.x - 6.5, y: m.point.y - 6.5, width: 13, height: 13))
                ctx.fill(circle, with: .color(Palette.rose))
                ctx.stroke(circle, with: .color(.white), lineWidth: 2.5)
            }
            for l in d.labels { draw(&ctx, l) }
        }
        .aspectRatio(320 / d.H, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }

    private func polyline(_ pts: [CGPoint]) -> Path {
        Path { p in
            guard let f = pts.first else { return }
            p.move(to: f)
            for q in pts.dropFirst() { p.addLine(to: q) }
        }
    }

    /// SVG の text と同じく、y を文字のベースラインにして置く
    private func draw(_ ctx: inout GraphicsContext, _ l: ChartDrawing.Label) {
        let text = l.ui ? Text(l.text).font(.ui(l.size, l.weight)) : Text(num: l.text, size: l.size, weight: l.weight)
        let resolved = ctx.resolve(text.foregroundStyle(l.color))
        let size = resolved.measure(in: CGSize(width: 1000, height: 1000))
        let ascent = resolved.firstBaseline(in: CGSize(width: 1000, height: 1000))
        let x = l.anchor < 0 ? l.at.x : l.anchor > 0 ? l.at.x - size.width : l.at.x - size.width / 2
        ctx.draw(resolved, in: CGRect(x: x, y: l.at.y - ascent, width: size.width, height: size.height))
    }

    private func drawEmpty(_ ctx: inout GraphicsContext, _ d: ChartDrawing) {
        let box = Path(roundedRect: CGRect(x: 8, y: 10, width: 304, height: d.H - 20), cornerRadius: 16)
        ctx.fill(box, with: .color(Color(hex: 0xFBF5F0)))
        ctx.stroke(box, with: .color(Palette.line), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
        let (title, sub) = d.hasAnyEntry
            ? (L("この期間の記録はないよ"), L("期間をのばすと、前の記録が見られるよ"))
            : (L("きろくがたまると、ここにグラフが出るよ"), L("まずは1日目をきろくしてみよう"))
        draw(&ctx, .init(text: title, at: CGPoint(x: 160, y: d.H / 2 - 4), anchor: 0, size: 13, weight: .bold, ui: true))
        draw(&ctx, .init(text: sub, at: CGPoint(x: 160, y: d.H / 2 + 16), anchor: 0, size: 11, weight: .bold, color: Color(hex: 0xB5A193), ui: true))
    }
}
