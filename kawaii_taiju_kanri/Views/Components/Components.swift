//
//  Components.swift
//  kawaii_taiju_kanri
//
//  カード・ボタン・チップなど、各画面で使う共通の部品（寸法はデモの CSS どおり）
//

import SwiftUI

// MARK: - カード

/// .card（白・枠線2・角丸28・余白16）。CSS の border-box と同じく、余白は枠線の内側から数える
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    var radius: CGFloat = 28
    var fill: Color = Palette.card
    var border: Color = Palette.line

    func body(content: Content) -> some View {
        content
            .padding(padding + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: radius).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(border, lineWidth: 2))
    }
}

extension View {
    func card(padding: CGFloat = 16, radius: CGFloat = 28) -> some View {
        modifier(CardStyle(padding: padding, radius: radius))
    }

    /// .hero / .room / .dStage のピンクの背景
    func heroBackground(radius: CGFloat = 28) -> some View {
        background(RoundedRectangle(cornerRadius: radius).fill(LinearGradient(colors: [Palette.heroTop, Palette.heroBottom], startPoint: .top, endPoint: .bottom)))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(Palette.heroBorder, lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

/// 見ないモードのとき、体重の数字をぼかす（.phone.hideNum）
private struct HiddenNumber: ViewModifier {
    @EnvironmentObject private var store: WeightStore

    func body(content: Content) -> some View {
        let hide = store.settings.hideNumbers
        content
            .blur(radius: hide ? 7 : 0)
            .accessibilityHidden(hide)
    }
}

extension View {
    func hiddenNumber() -> some View { modifier(HiddenNumber()) }
}

/// .card h2（15px・900、右に小さな説明やボタン）
struct CardTitle<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title).font(.ui(15, .black)).foregroundStyle(Palette.ink)
            Spacer(minLength: 0)
            trailing
        }
        .padding(.bottom, 10)
    }
}

extension CardTitle where Trailing == EmptyView {
    init(_ title: String) {
        self.title = title
        self.trailing = EmptyView()
    }
}

extension CardTitle where Trailing == Text {
    init(_ title: String, note: String) {
        self.title = title
        self.trailing = Text(note).font(.ui(12)).foregroundStyle(Palette.inkSoft)
    }
}

/// .hint（12px・行の高さ1.6）
struct Hint: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.ui(12))
            .foregroundStyle(Palette.inkSoft)
            .lineHeight(1.6, size: 12)
            // 折り返したときに高さを少なく見積もられて、カードの外にはみ出さないように
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}

/// 各タブの見出し（.top）
struct ScreenHeader<Trailing: View>: View {
    let caption: String
    let title: String
    /// 見出しの右の小さなラベル（.hideBadge）
    var badge: String?
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(caption).font(.ui(13)).tracking(0.52).foregroundStyle(Palette.inkSoft)
                HStack(spacing: 6) {
                    Text(title).font(.ui(30, .black)).tracking(0.6).foregroundStyle(Palette.ink)
                    if let badge {
                        Text(badge)
                            .font(.ui(10, .black))
                            .foregroundStyle(Palette.onInk)
                            .padding(.vertical, 2).padding(.horizontal, 8)
                            .background(Capsule().fill(Palette.ink))
                    }
                }
            }
            Spacer()
            trailing
        }
        .padding(.horizontal, 4)
        .padding(.top, 6)
        .padding(.bottom, 12)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(caption: String, title: String) {
        self.caption = caption
        self.title = title
        self.trailing = EmptyView()
    }
}

/// 「🔥 12日」のような丸いラベル（.pill）
struct Pill: View {
    let prefix: String
    let value: String
    let suffix: String

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if !prefix.isEmpty { Text(prefix) }
            Text(value).font(.num(17)).foregroundStyle(Palette.rose).numLineHeight(1, size: 17)
            Text(suffix)
        }
        .font(.ui(13))
        .foregroundStyle(Palette.ink)
        .padding(.vertical, 7).padding(.leading, 10).padding(.trailing, 13)
        .background(Capsule().fill(Palette.card))
        .overlay(Capsule().strokeBorder(Palette.line, lineWidth: 2))
    }
}

/// タブの画面の縦スクロール（.scroll：左右18・上14・下はタブバーの分110）
struct ScreenScroll<Content: View>: View {
    /// 中身の位置を測るときの座標（スクロールの位置 y と同じ基準）
    static var contentSpace: String { "screenScroll.content" }

    var position: Binding<ScrollPosition>?
    var top: CGFloat = 14
    @ViewBuilder var content: Content

    @State private var own = ScrollPosition(edge: .top)
    @ObservedObject private var ads = AdService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { content }
                .padding(.horizontal, 18)
                .padding(.top, top)
                // タブバーの分と、その上のバナー広告の分
                .padding(.bottom, 110 + ads.bannerHeight)
                .coordinateSpace(name: Self.contentSpace)
        }
        .scrollPosition(position ?? $own)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(Palette.paper)
    }
}

// MARK: - ボタン

/// .save（濃い色の大きなボタン。影の分だけ押すと沈む）
struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = Palette.ink
    var shadow: Color = Palette.inkShadow

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .font(.ui(17, .black))
            .tracking(1.36)
            .foregroundStyle(Palette.onInk)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Capsule().fill(color))
            .background(Capsule().fill(shadow).offset(y: pressed ? 1 : 5))
            .offset(y: pressed ? 4 : 0)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
    static var primaryRose: PrimaryButtonStyle { PrimaryButtonStyle(color: Palette.rose, shadow: Palette.roseShadow) }
}

/// 押すと少し縮むボタン（.stepBtn:active など）
struct PressScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.9

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// .linkBtn（12px のバラ色の文字だけのボタン）
struct LinkButton: View {
    let title: String
    var underline = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title).font(.ui(12)).foregroundStyle(Palette.rose).underline(underline).lineLimit(1)
        }
        .buttonStyle(.plain)
    }
}

/// 丸い −／＋ ボタン（.stepBtn は 52px・30px、.mini は 32px・20px）
struct RoundStepButton: View {
    let symbol: String
    var size: CGFloat = 52
    var fontSize: CGFloat = 30
    var fill: Color = Palette.blush
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(symbol)
                .font(.num(fontSize, .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: size, height: size)
                .background(Circle().fill(fill))
                .contentShape(Circle())
        }
        .buttonStyle(PressScaleStyle())
        .buttonRepeatBehavior(.enabled)
    }
}

extension RoundStepButton {
    static func mini(_ symbol: String, action: @escaping () -> Void) -> RoundStepButton {
        RoundStepButton(symbol: symbol, size: 32, fontSize: 20, action: action)
    }
}

// MARK: - セグメント（.seg）

struct PillSegment<Value: Hashable>: View {
    let options: [(value: Value, label: String)]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options.indices, id: \.self) { i in
                let on = options[i].value == selection
                Button {
                    selection = options[i].value
                } label: {
                    Text(options[i].label)
                        .font(.ui(12))
                        .lineLimit(1)
                        .foregroundStyle(on ? Palette.ink : Palette.inkSoft)
                        .padding(.vertical, 4).padding(.horizontal, 10)
                        .background(Capsule().fill(on ? Palette.card : .clear).shadow(color: Palette.ink.opacity(on ? 0.15 : 0), radius: 1.5, y: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Capsule().fill(Palette.seg))
    }
}

// MARK: - タグ（.chip）

struct TagChip: View {
    let title: String
    let on: Bool
    var action: (() -> Void)?

    var body: some View {
        let label = Text(title)
            .font(.ui(12))
            .foregroundStyle(on ? Palette.ink : Palette.inkSoft)
            .padding(.vertical, 7).padding(.horizontal, 13)
            .background(Capsule().fill(on ? Palette.cheek : Palette.card))
            .overlay(Capsule().strokeBorder(on ? Palette.ink : Palette.line, lineWidth: 2))
            .animation(.easeOut(duration: 0.15), value: on)
        if let action {
            Button(action: action) { label }.buttonStyle(.plain)
        } else {
            label
        }
    }
}

/// ひとことメモの入力欄（記録シートとホームの「きょうの体重」で同じ見た目。60文字まで）
struct MemoField: View {
    @Binding var text: String
    /// 入力中かどうか（入力欄そのものに付ける。外側の View に .focused を付けても効かない）
    var focused: FocusState<Bool>.Binding
    /// あらかじめあけておく行数（ホームは1行。打てば2行まで伸びる）
    var reservedLines = 2

    var body: some View {
        TextField("", text: $text, prompt: Text(L("例：友だちと焼肉")).foregroundStyle(Palette.inkFaint), axis: .vertical)
            .focused(focused)
            .lineLimit(reservedLines...2)
            .font(.ui(14, .medium))
            .foregroundStyle(Palette.ink)
            .padding(.vertical, 12).padding(.horizontal, 14)
            .background(RoundedRectangle(cornerRadius: 14).fill(Palette.paper))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Palette.line, lineWidth: 2))
            // 打っているあいだは切らない（日本語の変換中に切ると、変換がこわれるため）。
            // 超えたら数を出して、入力欄からはなれたとき・保存するときに切る
            .overlay(alignment: .bottomTrailing) {
                if text.count > Self.limit {
                    Text("\(text.count)/\(Self.limit)")
                        .font(.num(11, .bold))
                        .foregroundStyle(Palette.up)
                        .padding(.trailing, 12).padding(.bottom, 6)
                }
            }
            .onChange(of: focused.wrappedValue) { _, f in
                if !f && text.count > Self.limit { text = Self.clip(text) }
            }
    }

    static let limit = WeightEntry.memoLimit
    static func clip(_ s: String) -> String { String(s.prefix(limit)) }
}

struct TagPicker: View {
    @EnvironmentObject private var store: WeightStore
    @Binding var selected: [String]
    /// 一覧から消したけれど、この日に付いていたタグ。外しても消さずに出しておく（つけなおせるように）
    @State private var kept: [String] = []
    /// 1行にして横にスクロールする（ホームで「きろくする」まで見えるように）。
    /// カードの左右の余白（bleed）まではみ出して、端で切れて見えるようにする
    var singleLine = false
    var bleed: CGFloat = 16

    var body: some View {
        Group {
            if singleLine {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) { chips }
                        .padding(.vertical, 2)
                }
                .contentMargins(.horizontal, bleed, for: .scrollContent)
                .padding(.horizontal, -bleed)
            } else {
                FlowLayout(spacing: 6) { chips }
            }
        }
        .onChange(of: selected, initial: true) { _, s in
            kept += s.filter { !store.settings.tags.contains($0) && !kept.contains($0) }
        }
    }

    /// せっていのタグ。一覧から消したタグも、この日に付いていれば出す（外せるように）
    private var tags: [String] {
        store.settings.tags + kept.filter { !store.settings.tags.contains($0) }
    }

    private var chips: some View {
        ForEach(tags, id: \.self) { t in
            TagChip(title: L(t), on: selected.contains(t)) {
                if let i = selected.firstIndex(of: t) { selected.remove(at: i) } else { selected.append(t) }
            }
        }
    }
}

/// 折り返して並べるレイアウト（flex-wrap）
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, maxX: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > width {
                x = 0
                y += rowH + spacing
                rowH = 0
            }
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            rowH = max(rowH, size.height)
        }
        return CGSize(width: maxX, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowH + spacing
                rowH = 0
            }
            s.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowH = max(rowH, size.height)
        }
    }
}

// MARK: - 体重の入力（.stepper）

struct WeightStepper: View {
    @Binding var value: Double
    var step = 0.1
    var range: ClosedRange<Double> = 20...200
    var unit = "kg"

    @EnvironmentObject private var store: WeightStore
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        let masked = store.settings.hideNumbers
        HStack(spacing: 8) {
            RoundStepButton(symbol: "−") { bump(-step) }
                .accessibilityLabel(LF("%1$@%2$@ 減らす", Fmt.kg(step), unit))
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                // 打った瞬間に値にも入れる。数字のキーボードには「完了」がないので、打ってすぐ保存ボタンを押すと、
                // 入力欄からはなれる前に保存されて前の値のままになるため（onChange だと1文字おくれる）
                TextField("", text: Binding(get: { text }, set: { t in
                    text = t
                    if let v = Self.parse(t) { value = clamp(v) }
                }))
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .multilineTextAlignment(.center)
                    .font(.num(52, .heavy))
                    // 見ないモードでは、数字のかわりに点を見せる（-webkit-text-security: disc）
                    .foregroundStyle(masked ? .clear : Palette.ink)
                    .overlay {
                        if masked {
                            Text(String(repeating: "•", count: text.count))
                                .font(.num(52, .heavy))
                                .foregroundStyle(Palette.ink)
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                    }
                    .frame(width: 170)
                    .numLineHeight(1.1, size: 52)
                    .accessibilityLabel(LF("体重 (%@)", unit))
                Text(unit).font(.ui(14)).foregroundStyle(Palette.inkSoft)
            }
            .frame(maxWidth: .infinity)
            RoundStepButton(symbol: "+") { bump(step) }
                .accessibilityLabel(LF("%1$@%2$@ 増やす", Fmt.kg(step), unit))
        }
        .onAppear { text = Fmt.kg(value) }
        .onChange(of: value) { _, v in if !focused { text = Fmt.kg(v) } }
        .onChange(of: focused) { _, f in if !f { commit() } }
    }

    private func bump(_ d: Double) {
        if focused { commit() }
        value = clamp(value + d)
        text = Fmt.kg(value)
    }

    /// 入力欄からはなれたら数字に直す（読めなければ 58）
    private func commit() {
        let v = Self.parse(text) ?? 58
        value = clamp(v)
        text = Fmt.kg(value)
    }

    private static func parse(_ t: String) -> Double? {
        Double(t.replacingOccurrences(of: ",", with: "."))
    }

    private func clamp(_ v: Double) -> Double {
        min(range.upperBound, max(range.lowerBound, (v * 10).rounded() / 10))
    }
}

// MARK: - きぶん（表情）をえらぶ横スクロール（.fpRow）

struct FacePicker: View {
    let selected: Mood?
    /// 体重から自動で決まった顔（先頭に置く）
    var auto: Mood?
    let onSelect: (Mood) -> Void

    private var order: [Mood] {
        guard let auto else { return Mood.allCases }
        return [auto] + Mood.allCases.filter { $0 != auto }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(order) { m in
                        let on = m == selected
                        Button { onSelect(m) } label: {
                            VStack(spacing: 1) {
                                Image(m.smallAsset).resizable().scaledToFit().frame(width: 36, height: 36)
                                Text(m.label).font(.ui(10)).foregroundStyle(on ? Palette.ink : Palette.inkSoft)
                            }
                            .padding(.vertical, 6)
                            .frame(width: 56)
                            .background(RoundedRectangle(cornerRadius: 14).fill(on ? Palette.cheek : .clear))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(on ? Palette.ink : .clear, lineWidth: 2))
                            .animation(.easeOut(duration: 0.15), value: on)
                        }
                        .buttonStyle(.plain)
                        .id(m)
                    }
                }
                .padding(.trailing, 18)
            }
            .mask(LinearGradient(stops: [.init(color: .black, location: 0.88), .init(color: .clear, location: 1)], startPoint: .leading, endPoint: .trailing))
            .onAppear {
                if let selected { proxy.scrollTo(selected, anchor: .center) }
            }
        }
    }
}

// MARK: - トースト（.toast）

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.ui(13))
            .foregroundStyle(Palette.onInk)
            .lineLimit(1)
            .fixedSize()
            .padding(.vertical, 8).padding(.horizontal, 16)
            .background(Capsule().fill(Palette.ink))
    }
}

// MARK: - スイッチ（.sw：51×31）

struct CSSSwitch: View {
    @Binding var isOn: Bool
    var label: String = ""

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Capsule()
                .fill(isOn ? Palette.rose : Color(hex: 0xE9DED4))
                .frame(width: 51, height: 31)
                .overlay(alignment: .leading) {
                    Circle()
                        .fill(.white)
                        .shadow(color: Palette.ink.opacity(0.25), radius: 2, y: 2)
                        .frame(width: 27, height: 27)
                        .offset(x: isOn ? 22 : 2)
                }
                .animation(.cssEase(0.2), value: isOn)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? L("オン") : L("オフ"))
        .accessibilityAddTraits(.isToggle)
    }
}

// MARK: - 時刻（input[type=time]）

/// 「07:30」の見た目のまま、タップすると iPhone の時刻えらびが出る
struct TimeField: View {
    @Binding var time: Date
    var disabled = false

    var body: some View {
        Text(Fmt.time(time))
            .font(.num(16, .bold))
            .foregroundStyle(Palette.ink)
            .padding(.vertical, 4).padding(.horizontal, 8)
            .background(RoundedRectangle(cornerRadius: 10).fill(Palette.blush))
            .overlay {
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorMultiply(.clear)
                    .opacity(0.02)
                    .allowsHitTesting(!disabled)
            }
            .opacity(disabled ? 0.4 : 1)
    }
}
