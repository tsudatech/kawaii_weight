//
//  HomeView.swift
//  kawaii_taiju_kanri
//
//  ホーム（記録前：入力カードを上に／記録後：結果を大きく）
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: WeightStore
    @State private var position = ScrollPosition(edge: .top)
    @State private var memoEditing = false
    /// 「きょうのこと」の行の位置（スクロールの中身の上から）
    @State private var memoRowY: CGFloat = 0

    var body: some View {
        ScreenScroll(position: $position) {
            ScreenHeader(caption: Fmt.dayTitle(.today), title: L("きろく")) {
                Pill(prefix: "🔥", value: "\(store.streak)", suffix: LF("%d日:単位", store.streak))
                    .coachTarget("home.streak")
                    .accessibilityLabel(LF("連続記録日数 %d日", store.streak))
            }
            if store.simulateAbsent { absentBar.padding(.bottom, 10) }
            HomeHeroCard()
                .coachTarget("home.hero")
            if !store.isTodayRecorded {
                RecordCard(
                    onSaved: { withAnimation(.easeInOut(duration: 0.4)) { position.scrollTo(edge: .top) } },
                    onMemoRowY: { memoRowY = $0 },
                    onMemoFocus: { focused in
                        memoEditing = focused
                        if focused { scrollToMemo(after: 0.35) }
                    }
                )
                .coachTarget("home.record")
                .padding(.top, 14)
            }
            GoalCard().padding(.top, 14)
            recentChartCard.padding(.top, 14)
            HistoryCard().padding(.top, 14)
        }
        // キーボードが出たあとにも送る（出るのがおそいと、上の 0.35 秒後の時点ではまだ出ていない）
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
            if memoEditing { scrollToMemo(after: 0) }
        }
    }

    /// メモを書きはじめたら、「きょうのこと」の行が上から少しのところに来るまで送る。
    /// 上の体重の行・タグ・メモ欄・「きろくする」がキーボードの上にまとめて見える
    /// （iOS まかせだと、欄がキーボードのすぐ上にぎりぎり出るところで止まる）
    private func scrollToMemo(after delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.cssEase(0.3)) { position.scrollTo(y: max(0, memoRowY - Self.memoTopGap)) }
        }
    }

    /// 送ったとき、「きょうのこと」の行の上にあける高さ（体重の行まで見えて、時刻などの帯にかからない）
    private static let memoTopGap: CGFloat = 150

    /// .demoBar
    private var absentBar: some View {
        HStack(spacing: 8) {
            Text(L("デモ：3日ぶりにアプリを開いた状態を再現しています"))
                .font(.ui(12))
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(L("もどす")) { store.simulateAbsent = false }
                .font(.ui(12))
                .foregroundStyle(Palette.onInk)
                .padding(.vertical, 4).padding(.horizontal, 12)
                .background(Capsule().fill(Palette.ink))
                .buttonStyle(.plain)
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: 0xFFF3D9)))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Palette.gold, style: StrokeStyle(lineWidth: 2, dash: [6, 4])))
    }

    private var recentChartCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(L("さいきん2週間"), note: L("くわしくはグラフタブへ"))
            WeightChart(range: 14, height: 170)
        }
        .card()
    }
}

// MARK: - キャラとふきだし（#hero）

struct HomeHeroCard: View {
    @EnvironmentObject private var store: WeightStore
    @State private var talkIndex = 0

    var body: some View {
        let state = store.todayState
        let recorded = store.isTodayRecorded
        let talk = store.settings.talk
        let charSize: CGFloat = recorded ? 120 : 128
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                CharacterView(
                    asset: state.mood.largeAsset,
                    size: charSize,
                    bounceKey: store.homeBounce,
                    shake: state.mood.isSad,
                    onTap: { talkIndex += 1 }
                )
                .frame(maxWidth: !recorded && !talk ? .infinity : nil)
                .accessibilityLabel(LF("%@：タップでしゃべる", state.mood.label))
                if recorded || talk {
                    VStack(alignment: .leading, spacing: 8) {
                        if talk {
                            SpeechBubble(
                                text: state.mood.line(custom: state.line, index: talkIndex),
                                tail: .left, fontSize: 14, radius: 18, paddingH: 12, paddingV: 8, centered: false
                            )
                        }
                        if recorded { doneInfo }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            if recorded && !store.simulateAbsent {
                facePick
            } else if !recorded {
                heroStats.padding(.top, 2)
            }
        }
        .padding(.vertical, recorded ? 16 : 14).padding(.leading, 10).padding(.trailing, 16)
        .heroBackground()
        .onChange(of: state.mood) { _, _ in talkIndex = 0 }
        .onChange(of: store.homeBounce) { _, _ in talkIndex = 0 }
    }

    /// .doneInfo
    private var doneInfo: some View {
        let entry = store.todayEntry
        let j = store.judge(.today)
        // 前回の記録とくらべるときは、それがきのうかどうかで言い分ける（日の詳細と同じ）
        let prev = store.sortedDates.last { $0 < .today }
        let label = store.settings.judge == .trend ? L("7日平均から")
            : prev.map { $0.days(to: .today) == 1 } ?? true ? L("まえの日から") : L("まえの記録から")
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(entry.map { Fmt.kg($0.weight) } ?? "—").font(.num(42)).numLineHeight(1, size: 42)
                Text("kg").font(.ui(14)).foregroundStyle(Palette.inkSoft)
            }
            .foregroundStyle(Palette.ink)
            Group {
                if let diff = j?.diff {
                    Text("\(Text(num: label + " ", size: 15, weight: .bold))\(Text(num: "\(Fmt.signed(diff))kg", size: 15, weight: .bold).foregroundStyle(deltaColor(diff)))")
                } else if store.sortedDates.count <= 1 {
                    Text(num: L("はじめての記録だよ"), size: 15, weight: .bold)
                } else {
                    // 7日平均とくらべる設定で、前の7日に記録がないとき
                    Text(num: L("この7日はくらべる記録がないよ"), size: 15, weight: .bold)
                }
            }
            .foregroundStyle(Palette.ink)
            .padding(.top, 2)
            LinkButton(title: L("記録を修正"), underline: true) { store.editing = SheetTarget(date: .today) }
                .padding(.top, 4)
        }
        .padding(.leading, 4)
    }

    /// .facePick
    private var facePick: some View {
        let face = store.dayFace(.today)
        return VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(L("きょうのきぶん")).font(.ui(12, .black)).foregroundStyle(Palette.ink)
                Text(L("よこにスクロールしてえらべるよ")).font(.ui(10)).foregroundStyle(Color(hex: 0xB5A193))
            }
            FacePicker(selected: face?.mood, auto: face?.auto) { m in
                store.pickTodayFace(m)
                store.homeBounce += 1
            }
        }
        .padding(.top, 8).padding(.horizontal, 8).padding(.bottom, 6)
        .background(RoundedRectangle(cornerRadius: 20).fill(Palette.card).shadow(color: Palette.line, radius: 0, y: 2))
    }

    /// .heroStats
    private var heroStats: some View {
        let avg = store.average7(before: .today)
        let left = store.latestWeight.map { max(0, $0 - store.settings.goal) }
        return HStack(spacing: 6) {
            statTile(L("7日平均")) {
                if let avg { kgValue(Fmt.kg(avg)) } else { Text("—").font(.num(15, .bold)) }
            }
            statTile(L("もくひょう")) { kgValue(Fmt.kg(store.settings.goal)) }
            statTile(L("あと")) {
                if let left {
                    if left == 0 {
                        Text(L("達成！")).font(.ui(16)).foregroundStyle(Palette.mintInk)
                    } else {
                        kgValue(Fmt.kg(left))
                    }
                } else {
                    Text("—").font(.num(21, .bold))
                }
            }
        }
    }

    private func kgValue(_ v: String) -> Text {
        Text("\(Text(v).font(.num(21, .bold)))\(Text("kg").font(.num(11, .bold)))")
    }

    private func statTile<V: View>(_ label: String, @ViewBuilder value: () -> V) -> some View {
        VStack(spacing: 0) {
            Text(label).font(.ui(11)).tracking(0.44).foregroundStyle(Palette.inkSoft)
            value()
                .foregroundStyle(Palette.ink)
                .numLineHeight(1.3, size: 21)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8).padding(.horizontal, 6).padding(.bottom, 6)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.85)))
    }
}

// MARK: - きょうの体重（#recCard）

struct RecordCard: View {
    var onSaved: () -> Void
    /// 「きょうのこと」の行の位置（スクロールの中身の上から）。メモを書くときのスクロールに使う
    var onMemoRowY: (CGFloat) -> Void = { _ in }
    var onMemoFocus: (Bool) -> Void = { _ in }
    @EnvironmentObject private var store: WeightStore
    @FocusState private var memoFocused: Bool
    @State private var weight: Double = 58
    @State private var tags: [String] = []
    @State private var memo = ""


    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(L("きょうの体重"), note: L("まだ記録してないよ"))
            WeightStepper(value: $weight)
            HStack {
                Text(L("きょうのこと")).font(.ui(12)).foregroundStyle(Palette.inkSoft)
                Spacer()
                LinkButton(title: L("体脂肪・メモ ›")) { store.editing = SheetTarget(date: .today) }
            }
            .onGeometryChange(for: CGFloat.self) { $0.frame(in: .named(ScreenScroll<EmptyView>.contentSpace)).minY } action: { onMemoRowY($0) }
            .padding(.top, 14)
            .padding(.bottom, 8)
            TagPicker(selected: $tags, singleLine: true)
            Text(L("ひとことメモ")).font(.ui(12)).foregroundStyle(Palette.inkSoft)
                .padding(.top, 14)
                .padding(.bottom, 8)
            MemoField(text: $memo, focused: $memoFocused, reservedLines: 1)
                .onChange(of: memoFocused) { _, f in onMemoFocus(f) }
            Button(L("きろくする")) {
                store.saveToday(weight: weight, tags: tags, memo: memo)
                onSaved()
            }
            .buttonStyle(.primary)
            .padding(.top, 14)
        }
        .card()
        .onAppear { weight = store.lastWeightOrDefault }
        #if DEBUG
        // プレビュー動画の自動の流れ（Debug/PreviewTour.swift）から、ボタンを押したのと同じように動かす
        .onReceive(NotificationCenter.default.publisher(for: PreviewTour.bump)) { n in
            weight = ((weight + (n.object as? Double ?? 0)) * 10).rounded() / 10
        }
        .onReceive(NotificationCenter.default.publisher(for: PreviewTour.tag)) { n in
            if let t = n.object as? String, !tags.contains(t) { tags.append(t) }
        }
        .onReceive(NotificationCenter.default.publisher(for: PreviewTour.save)) { _ in
            store.saveToday(weight: weight, tags: tags)
            onSaved()
        }
        #endif
    }
}

// MARK: - もくひょうまで（.goalCard）

struct GoalCard: View {
    @EnvironmentObject private var store: WeightStore
    @State private var cheerIndex = 0
    @State private var bounce = 0

    var body: some View {
        let info = store.goalInfo()
        let pct = info?.pct ?? 0
        let shown = max(0, min(100, pct))
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(title: L("もくひょうまで")) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(Int(floor(max(0, pct))))").font(.num(20)).foregroundStyle(Palette.rose)
                    Text(" %").font(.ui(12)).foregroundStyle(Palette.inkSoft)
                }
            }
            // 見出しの margin-bottom 10 と .track の margin-top 30 は重なって 30 になる（CSS のマージンの相殺）
            track(shown: shown, pct: info == nil ? nil : pct)
                .padding(.top, 20)
                .padding(.leading, 8).padding(.trailing, 18)
            HStack {
                trackLabel(L("スタート") + " ", info.map { "\(Fmt.kg($0.start))kg" } ?? "—")
                Spacer()
                trackLabel(L("ゴール") + " ", "\(Fmt.kg(store.settings.goal))kg")
            }
            .padding(.top, 6).padding(.horizontal, 2)
            cheerButton(info: info)
        }
        .card()
    }

    private func trackLabel(_ label: String, _ value: String) -> Text {
        Text("\(Text(num: label, size: 11, weight: .semibold).foregroundStyle(Palette.inkSoft))\(Text(num: value, size: 11, weight: .bold).foregroundStyle(Palette.ink))")
    }

    /// .track（棒・目盛り・旗・走るキャラ）
    private func track(shown: Double, pct: Double?) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.seg)
                Capsule()
                    .fill(LinearGradient(colors: [Palette.cheek, Palette.rose], startPoint: .leading, endPoint: .trailing))
                    .frame(width: w * shown / 100)
            }
            .frame(width: w, height: 16)
            .overlay(alignment: .topLeading) {
                ForEach([25.0, 50, 75], id: \.self) { t in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(t <= shown ? 0.75 : 1))
                        .frame(width: 3, height: 8)
                        .offset(x: w * t / 100, y: 4)
                }
            }
            .overlay(alignment: .topLeading) {
                GoalFlag()
                    .frame(width: 26, height: 42)
                    .offset(x: w + 16 - 26, y: 16 - 4 - 42)
            }
            .overlay(alignment: .topLeading) {
                Image((pct ?? 0) < 0 ? "sm_hmm" : "sm_good")
                    .resizable().scaledToFit()
                    .frame(width: 46, height: 46)
                    .offset(x: w * shown / 100 - 23, y: 8 - 46 * 0.7)
            }
            .animation(.timingCurve(0.3, 1.2, 0.5, 1, duration: 0.8), value: shown)
        }
        .frame(height: 16)
    }

    private func cheerButton(info: GoalInfo?) -> some View {
        let content = cheerContent(info)
        return Button {
            cheerIndex += 1
            bounce += 1
        } label: {
            HStack(spacing: 12) {
                CharacterView(asset: content.face, size: 72, bounceKey: bounce, breathe: false)
                    .allowsHitTesting(false)
                VStack(alignment: .leading, spacing: 3) {
                    BalancedLines(text: content.message, font: .ui(15, .black), size: 15)
                    Text(content.sub).font(.ui(12)).foregroundStyle(Palette.inkSoft).lineHeight(1.5, size: 12)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10).padding(.leading, 8).padding(.trailing, 14)
            .background(RoundedRectangle(cornerRadius: 22).fill(Palette.soft))
            .contentShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .padding(.top, 14)
        .accessibilityLabel(L("おうえんメッセージ（タップで次のメッセージ）"))
        .onChange(of: content.band) { _, _ in cheerIndex = 0 }
    }

    private func cheerContent(_ info: GoalInfo?) -> (face: String, message: String, sub: String, band: Int) {
        guard let g = info else {
            return ("cheer", L("はじめての記録が、スタート地点になるよ"), LF("もくひょうは %@kg。いっしょにがんばろうね", Fmt.kg(store.settings.goal)), -1)
        }
        let bands = CheerBand.all
        let band = g.pct <= 0 ? 0 : (bands.indices.first { $0 > 0 && g.pct < bands[$0].upTo } ?? bands.count - 1)
        let c = bands[band]
        let toHalf = max(0, g.latest - (g.start - g.span / 2))
        let message = c.lines[cheerIndex % c.lines.count]
            .replacingOccurrences(of: "{p}", with: "\(Int(floor(g.pct)))")
            .replacingOccurrences(of: "{left}", with: Fmt.kg(g.left))
            .replacingOccurrences(of: "{toHalf}", with: Fmt.kg(toHalf))
        let sub: String
        if g.pct >= 100 {
            sub = LF("%1$@kg → %2$@kg、%3$@kg へったよ", Fmt.kg(g.start), Fmt.kg(g.latest), Fmt.kg(g.start - g.latest))
        } else if g.slope < -0.005 {
            let days = Int(ceil(g.left / -g.slope))
            if days > 365 {
                sub = LF("あと %@kg。ゆっくり確実にいこうね", Fmt.kg(g.left))
            } else {
                sub = LF("このペースだと %1$@ごろゴールできそう（週 %2$@kg ペース）", Fmt.monthDay(Date.today.adding(days: days)), Fmt.kg(-g.slope * 7))
            }
        } else {
            sub = LF("あと %@kg。ペースはゆっくりでOK、続けることが大事だよ", Fmt.kg(g.left))
        }
        return (c.face, message, sub, band)
    }
}

/// 2行になるときは行の長さをそろえる（text-wrap: balance）見出し
struct BalancedLines: View {
    let text: String
    let font: Font
    let size: CGFloat
    var lineHeight: CGFloat = 1.5

    var body: some View {
        ViewThatFits(in: .horizontal) {
            line(text).fixedSize()
            line(BalancedText.balanced(text))
        }
    }

    private func line(_ s: String) -> some View {
        Text(s).font(font).foregroundStyle(Palette.ink).lineHeight(lineHeight, size: size)
    }
}

/// ゴールの旗（.flagG の SVG）
struct GoalFlag: View {
    var body: some View {
        Canvas { ctx, size in
            ctx.scaleBy(x: size.width / 26, y: size.height / 42)
            ctx.fill(Path(roundedRect: CGRect(x: 3, y: 2, width: 2.5, height: 40), cornerRadius: 1.2), with: .color(Palette.ink))
            ctx.fill(Path { p in
                p.move(to: CGPoint(x: 5.5, y: 3)); p.addLine(to: CGPoint(x: 22.5, y: 3)); p.addLine(to: CGPoint(x: 18.5, y: 9))
                p.addLine(to: CGPoint(x: 22.5, y: 15)); p.addLine(to: CGPoint(x: 5.5, y: 15)); p.closeSubpath()
            }, with: .color(Palette.rose))
            ctx.fill(Path(ellipseIn: CGRect(x: 1.7, y: 0, width: 5, height: 5)), with: .color(Palette.gold))
        }
    }
}

// MARK: - りれき

struct HistoryCard: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let ds = store.sortedDates
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(title: L("りれき")) {
                LinkButton(title: L("＋ 過去の日を入力")) {
                    store.editing = SheetTarget(date: store.nearestMissingPastDate())
                }
            }
            if ds.isEmpty {
                Text(L("まだきろくがないよ。\n上のカードから、きょうの体重をきろくしてね"))
                    .font(.ui(13))
                    .foregroundStyle(Palette.inkSoft)
                    .lineHeight(1.7, size: 13)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14).padding(.horizontal, 4)
            } else {
                let recent = Array(ds.reversed().prefix(10))
                ForEach(Array(recent.enumerated()), id: \.element) { idx, d in
                    Button { store.openDay(d, from: L("りれき")) } label: { HistoryRow(date: d) }
                        .buttonStyle(.plain)
                        .overlay(alignment: .top) {
                            if idx > 0 {
                                Line().stroke(Palette.line, style: StrokeStyle(lineWidth: 1.5, dash: [4.5, 3]))
                                    .frame(height: 1.5)
                            }
                        }
                }
            }
            Hint(L("タップすると、その日のようすが見られるよ"))
        }
        .card()
    }
}

/// .hrow
struct HistoryRow: View {
    let date: Date
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let ds = store.sortedDates
        let entry = store.entries[date]
        let i = ds.firstIndex(of: date) ?? 0
        let diff: Double? = i > 0 ? (entry?.weight ?? 0) - (store.entries[ds[i - 1]]?.weight ?? 0) : nil
        let mood = store.mood(for: date)
        HStack(spacing: 12) {
            Image(mood.smallAsset).resizable().scaledToFit().frame(width: 34, height: 34)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 14).fill(Palette.faceBG))
            VStack(alignment: .leading, spacing: 0) {
                Text(Fmt.monthDay(date)).font(.ui(14)).foregroundStyle(Palette.ink)
                subline(entry: entry, mood: mood)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .trailing, spacing: 0) {
                Text(entry.map { Fmt.kg($0.weight) } ?? "—").font(.num(18, .bold)).foregroundStyle(Palette.ink)
                    .numLineHeight(1.1, size: 18)
                Text(diff.map { Fmt.signed($0) } ?? " ").font(.num(12, .bold)).foregroundStyle(deltaColor(diff))
                    .numLineHeight(1.1, size: 12)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    private func subline(entry: WeightEntry?, mood: Mood) -> some View {
        let tags = entry?.tags ?? []
        return HStack(spacing: 0) {
            ForEach(tags, id: \.self) { t in
                Text(L(t)).font(.ui(10)).foregroundStyle(Palette.ink)
                    .padding(.horizontal, 5)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Palette.blush))
                    .padding(.trailing, 3)
            }
            if let memo = entry?.memo {
                Text("📝\(memo)")
            } else if tags.isEmpty {
                Text(mood.label + (entry?.fat.map { " ・ \(Fmt.kg($0))%" } ?? ""))
            }
        }
        .font(.ui(11))
        .foregroundStyle(Palette.inkSoft)
        .lineLimit(1)
    }
}

/// 横線（点線の区切りに使う）
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return p
    }
}
