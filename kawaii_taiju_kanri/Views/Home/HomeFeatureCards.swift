//
//  HomeFeatureCards.swift
//  kawaii_taiju_kanri
//
//  ホームのカード：体重よそう・もどるまで見守り・ごほうびの日せんげん
//

import SwiftUI

// MARK: - 体重よそう（.guess）

/// 体重入力の上の3択。まえの記録があるときだけ
struct GuessBox: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        if let previous = store.sortedDates.last(where: { $0 < .today }) {
            let pending = store.todayPendingGuess
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L("よそう")).font(.ui(13, .black)).foregroundStyle(Palette.ink)
                    reference(previous)
                }
                .fixedSize()
                HStack(spacing: 5) {
                    ForEach(WeightGuess.allCases, id: \.self) { g in
                        button(g, selected: pending?.guess == g, botPick: pending?.bot == g)
                    }
                }
            }
            .padding(.vertical, 6).padding(.trailing, 6).padding(.leading, 12)
            .background(RoundedRectangle(cornerRadius: 18).fill(Palette.blush))
            .padding(.bottom, 10)
        }
    }

    private func reference(_ previous: Date) -> some View {
        let name = previous.days(to: .today) == 1 ? L("きのう") : Fmt.slash(previous)
        return HStack(spacing: 2) {
            Text(LF("%@より", name))
            if !store.settings.hideNumbers, let w = store.entries[previous]?.weight {
                Text(Fmt.kg(w)).font(.num(10, .bold))
            }
        }
        .font(.ui(10))
        .foregroundStyle(Palette.inkSoft)
    }

    private func button(_ g: WeightGuess, selected: Bool, botPick: Bool) -> some View {
        Button { store.tapGuess(g) } label: {
            HStack(spacing: 2) {
                Text(g.arrow).font(.num(15, .bold))
                Text(g.label).font(.ui(12, .black)).lineLimit(1).minimumScaleFactor(0.8)
            }
            .foregroundStyle(Palette.ink)
            .padding(.vertical, 6).padding(.horizontal, 2)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 14).fill(selected ? Palette.cheek : Palette.card))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(selected ? Palette.ink : Palette.line, lineWidth: 2))
            .overlay(alignment: .topTrailing) {
                if botPick {
                    Text(L("キャラ"))
                        .font(.ui(9, .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Palette.mintInk))
                        .offset(x: 4, y: -9)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// 記録後の結果（#guessRes）
struct GuessResultCard: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let stats = store.guessStats
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(L("体重よそう"), note: LF("よそう名人 Lv.%1$d・%2$dpt", stats.level, stats.points))
            if let g = store.guessResult(.today) {
                HStack(spacing: 10) {
                    stamp(g.hit ? L("あたり") : L("ざんねん"), hit: g.hit)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(LF("よそう「%1$@」→ ほんとは「%2$@」", g.guess.label, g.actual.label))
                            .font(.ui(14, .black)).foregroundStyle(Palette.ink).lineHeight(1.45, size: 14)
                        Text(LF("キャラは「%1$@」。%2$@", g.bot.label, versus(g)))
                            .font(.ui(11)).foregroundStyle(Palette.inkSoft).lineHeight(1.5, size: 11)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(Text(g.points > 0 ? "+\(g.points)" : "±0").font(.num(22)))\(Text("pt").font(.num(12)))")
                        .foregroundStyle(Palette.rose)
                }
            } else {
                HStack(spacing: 10) {
                    stamp("？", hit: false)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(L("あしたは、はかる前によそうしてみてね"))
                            .font(.ui(14, .black)).foregroundStyle(Palette.ink).lineHeight(1.45, size: 14)
                        Text(L("まえの記録より「ふえた・おなじ・へった」を当てるゲームだよ"))
                            .font(.ui(11)).foregroundStyle(Palette.inkSoft).lineHeight(1.5, size: 11)
                    }
                }
            }
            GuessFooter(stats: stats).padding(.top, 12)
        }
        .card()
    }

    private func versus(_ g: GuessResult) -> String {
        if g.hit { return g.botHit ? L("キャラもあたりで、ひきわけ") : L("キャラに勝ったよ！") }
        return g.botHit ? L("キャラの勝ち…") : L("どっちもはずれ")
    }

    /// .gStamp
    private func stamp(_ text: String, hit: Bool) -> some View {
        Text(text)
            .font(.ui(13, .black))
            .multilineTextAlignment(.center)
            .foregroundStyle(hit ? .white : Palette.inkSoft)
            .frame(width: 56, height: 56)
            .background(Circle().fill(hit ? Palette.rose : Palette.seg))
            .overlay(Circle().strokeBorder(.white, lineWidth: 3))
            .background(Circle().strokeBorder(hit ? Palette.rose : Palette.line, lineWidth: 2).padding(-2))
            .rotationEffect(.degrees(-8))
            .padding(2)
    }
}

/// .gFoot（こんげつの的中・れんぞく的中・キャラと）
struct GuessFooter: View {
    let stats: GuessStats

    var body: some View {
        HStack(spacing: 6) {
            cell(L("こんげつの的中"), stats.monthRate.map { "\($0)%" } ?? "—")
            cell(L("れんぞく的中"), LF("%d回", stats.run))
            cell(L("キャラと"), LF("%1$d勝%2$d敗", stats.wins, stats.losses))
        }
    }

    private func cell(_ label: String, _ value: String) -> some View {
        VStack(spacing: 0) {
            Text(label).font(.ui(10)).foregroundStyle(Palette.inkSoft).lineLimit(1).minimumScaleFactor(0.8)
            Text(num: value, size: 16, weight: .heavy).foregroundStyle(Palette.ink).lineLimit(1).minimumScaleFactor(0.8)
        }
        .padding(.vertical, 6).padding(.horizontal, 4)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 14).fill(Palette.paper))
    }
}

// MARK: - もどるまで見守り（#watchCard）

struct WatchCard: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let w = store.watches
        if let cleared = w.done.first(where: { $0.end == .today }) {
            content(
                since: "\(Fmt.slash(cleared.start))〜\(Fmt.slash(cleared.end ?? .today))",
                title: LF("%@のもやもや、はれた！", L(cleared.label)),
                sub: LF("%@でもとの体重にもどったよ。キャラタブに記録したよ", LF("%d日", cleared.days)),
                progress: 1, clear: true
            ) { SunMark() }
        } else if let a = w.active {
            let span = a.peak - a.base
            let progress = span > 0 ? max(0, min(1, (a.peak - a.current) / span)) : 0
            let left = max(0.1, ((a.current - a.base - 0.1) * 10).rounded() / 10)
            content(
                since: LF("%1$@から %2$d日目", Fmt.slash(a.start), a.start.days(to: .today) + 1),
                title: LF("%@のもやもや", L(a.label)),
                sub: store.settings.hideNumbers
                    ? L("もとの体重にもどったら はれるよ。いっしょに見守ってるね")
                    : LF("もとの %1$@kg にもどったら はれるよ（あと %2$@kg）", Fmt.kg(a.base), Fmt.kg(left)),
                progress: max(0.06, progress), clear: false
            ) {
                CloudMark().scaleEffect(1 - progress * 0.4, anchor: UnitPoint(x: 0.5, y: 0.6))
            }
        }
    }

    private func content<Mark: View>(since: String, title: String, sub: String, progress: Double, clear: Bool, @ViewBuilder mark: () -> Mark) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(L("もどるまで見守り"), note: since)
            HStack(spacing: 10) {
                mark().frame(width: 86, height: 60)
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).font(.ui(14, .black)).foregroundStyle(Palette.ink)
                    Text(sub).font(.ui(11)).foregroundStyle(Palette.inkSoft).lineHeight(1.55, size: 11)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: 0xE3EEF0))
                    Capsule()
                        .fill(LinearGradient(colors: clear ? [Palette.gold, Color(hex: 0xE9A94F)] : [Palette.sky, Palette.mintInk], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * progress)
                        .animation(.easeInOut(duration: 0.6), value: progress)
                }
            }
            .frame(height: 10)
            .padding(.top, 10)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 28).fill(LinearGradient(stops: [
            .init(color: Color(hex: clear ? 0xFFF6DC : 0xEAF5F7), location: 0),
            .init(color: .white, location: 0.8),
        ], startPoint: .top, endPoint: .bottom)))
        .overlay(RoundedRectangle(cornerRadius: 28).strokeBorder(Color(hex: clear ? 0xF6E3B5 : 0xD5EAEC), lineWidth: 2))
    }
}

/// デモの雲の絵（viewBox 100×64）
struct CloudMark: View {
    var body: some View {
        Canvas { ctx, size in
            ctx.scaleBy(x: size.width / 100, y: size.height / 64)
            var cloud = Path()
            var p = CGPoint(x: 22, y: 56)
            cloud.move(to: p)
            for (r, dx, dy) in [(15.0, 2.0, -30.0), (18, 33, -6), (16, 28, 9), (13, 3, 27)] {
                let to = CGPoint(x: p.x + dx, y: p.y + dy)
                addArc(&cloud, from: p, to: to, radius: r)
                p = to
            }
            cloud.closeSubpath()
            ctx.fill(cloud, with: .color(Color(hex: 0xDCE5E8)))
            ctx.stroke(cloud, with: .color(Palette.ink), style: StrokeStyle(lineWidth: 2.6, lineJoin: .round))
            var eyes = Path()
            for x in [40.0, 58.0] {
                eyes.move(to: CGPoint(x: x, y: 40))
                eyes.addQuadCurve(to: CGPoint(x: x + 8, y: 40), control: CGPoint(x: x + 4, y: 44))
            }
            ctx.stroke(eyes, with: .color(Palette.ink), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
        }
    }

    /// SVG の円弧（小さいほう・時計回り）
    private func addArc(_ path: inout Path, from a: CGPoint, to b: CGPoint, radius r: CGFloat) {
        let mid = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
        let dx = b.x - a.x, dy = b.y - a.y, d = (dx * dx + dy * dy).squareRoot()
        let h = max(0, r * r - d * d / 4).squareRoot()
        let center = CGPoint(x: mid.x - dy / d * h, y: mid.y + dx / d * h)
        path.addArc(center: center, radius: r,
                    startAngle: .radians(atan2(a.y - center.y, a.x - center.x)),
                    endAngle: .radians(atan2(b.y - center.y, b.x - center.x)),
                    clockwise: false)
    }
}

/// デモのお日さまの絵（viewBox 100×64）
struct SunMark: View {
    var body: some View {
        Canvas { ctx, size in
            ctx.scaleBy(x: size.width / 100, y: size.height / 64)
            var rays = Path()
            for (x1, y1, x2, y2) in [(50.0, 4.0, 50.0, 12.0), (50, 52, 50, 60), (24, 32, 16, 32), (84, 32, 76, 32),
                                     (31, 13, 36, 18), (64, 46, 69, 51), (69, 13, 64, 18), (36, 46, 31, 51)] {
                rays.move(to: CGPoint(x: x1, y: y1))
                rays.addLine(to: CGPoint(x: x2, y: y2))
            }
            ctx.stroke(rays, with: .color(Color(hex: 0xE9A94F)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            let sun = Path(ellipseIn: CGRect(x: 35, y: 17, width: 30, height: 30))
            ctx.fill(sun, with: .color(Palette.gold))
            ctx.stroke(sun, with: .color(Palette.ink), lineWidth: 2.6)
            var face = Path()
            for x in [44.0, 52.0] {
                face.move(to: CGPoint(x: x, y: 30))
                face.addQuadCurve(to: CGPoint(x: x + 4, y: 30), control: CGPoint(x: x + 2, y: 27))
            }
            face.move(to: CGPoint(x: 45, y: 37))
            face.addQuadCurve(to: CGPoint(x: 55, y: 37), control: CGPoint(x: 50, y: 41))
            ctx.stroke(face, with: .color(Palette.ink), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
        }
    }
}

// MARK: - ごほうびの日せんげん（#treatCard）

struct TreatCard: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let on = store.isTreat(Date.today.adding(days: 1))
        HStack(spacing: 10) {
            Text("🍰")
                .font(.system(size: 22))
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(hex: 0xFFF3D9)))
            VStack(alignment: .leading, spacing: 0) {
                Text(on ? L("あしたは ごほうびの日") : L("あしたは ごほうびの日？"))
                    .font(.ui(14, .black)).foregroundStyle(Palette.ink)
                Text(on ? L("ふえてもだいじょうぶ。もどるまで見守るよ") : L("食べる予定があれば、先に伝えておいてね"))
                    .font(.ui(11)).foregroundStyle(Palette.inkSoft).lineHeight(1.5, size: 11)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(on ? L("とりけす") : L("せんげんする")) { store.toggleTomorrowTreat() }
                .font(.ui(12, .black))
                .lineLimit(1)
                .foregroundStyle(on ? Palette.ink : Palette.onInk)
                .padding(.vertical, 7).padding(.horizontal, 12)
                .background(Capsule().fill(on ? Palette.card : Palette.ink))
                .overlay(Capsule().strokeBorder(on ? Palette.line : .clear, lineWidth: 2))
                .buttonStyle(.plain)
                .fixedSize()
        }
        .padding(.vertical, 12).padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 28).fill(on ? Color(hex: 0xFFF8EC) : Palette.card))
        .overlay(RoundedRectangle(cornerRadius: 28).strokeBorder(on ? Palette.gold : Palette.line, lineWidth: 2))
    }
}
