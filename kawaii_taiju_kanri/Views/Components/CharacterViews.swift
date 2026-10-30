//
//  CharacterViews.swift
//  kawaii_taiju_kanri
//
//  キャラ画像・ふきだし
//

import SwiftUI

/// キャラ画像。「ふわふわ動く」がオンなら息をするようにゆれ、タップや表情の変化でぴょんと跳ねる
struct CharacterView: View {
    let asset: String
    var size: CGFloat
    /// 変わったら跳ねる（shake なら左右にゆれる）
    var bounceKey: AnyHashable?
    var shake = false
    /// ずっと呼吸のアニメーションをするか（.char のみ。小さな顔はしない）
    var breathe = true
    var onTap: (() -> Void)?

    @EnvironmentObject private var store: WeightStore
    /// 跳ねた・ゆれた時刻。動きは時刻から毎コマ計算する（ぽこりんのスプラッシュと同じ作り）。
    /// SwiftUI のアニメーションや keyframeAnimator だと、表情の絵の差しかえやふきだしの並べ直しと重なって、
    /// かくついたり絵が一瞬消えたりするため
    @State private var popAt: Date?
    @State private var shakeAt: Date?

    private static let popDuration = 0.55
    private static let shakeDuration = 0.5

    var body: some View {
        TimelineView(.animation(paused: popAt == nil && shakeAt == nil)) { context in
            let squash = Self.squash(since: popAt, now: context.date)
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .modifier(Breathe(active: breathe && store.settings.move))
                .scaleEffect(x: squash.width, y: squash.height, anchor: UnitPoint(x: 0.5, y: 0.9))
                .rotationEffect(.degrees(Self.tilt(since: shakeAt, now: context.date)), anchor: UnitPoint(x: 0.5, y: 0.9))
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .onTapGesture {
            guard let onTap else { return }
            pop()
            onTap()
        }
        .onChange(of: bounceKey) { _, _ in
            if shake { wobble() } else { pop() }
        }
        .accessibilityAddTraits(onTap == nil ? [] : .isButton)
    }

    private func pop() {
        let start = Date()
        popAt = start
        // 動き終わったら TimelineView を止める（あとから跳ねなおしていたら、そちらにまかせる）
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.popDuration) {
            if popAt == start { popAt = nil }
        }
    }

    private func wobble() {
        let start = Date()
        shakeAt = start
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.shakeDuration) {
            if shakeAt == start { shakeAt = nil }
        }
    }

    /// @keyframes pop（.55s）：なめらかに縦につぶれてから、少し行きすぎて元にもどる
    private static func squash(since start: Date?, now: Date) -> CGSize {
        guard let start else { return CGSize(width: 1, height: 1) }
        let t = min(1, max(0, now.timeIntervalSince(start) / popDuration))
        let peak = CGSize(width: 0.88, height: 1.1)
        let k: Double
        if t < 0.18 {
            k = ease(t / 0.18)                    // 1 → つぶれた形
        } else {
            k = 1 - backOut((t - 0.18) / 0.82)    // つぶれた形 → 少し行きすぎて 1
        }
        return CGSize(width: 1 + (peak.width - 1) * k, height: 1 + (peak.height - 1) * k)
    }

    /// @keyframes shake（.5s）：左右に3回、だんだん小さくゆれる
    private static func tilt(since start: Date?, now: Date) -> Double {
        guard let start else { return 0 }
        let t = min(1, max(0, now.timeIntervalSince(start) / shakeDuration))
        return -5 * sin(t * 3 * 2 * .pi) * (1 - t)
    }

    /// なめらかに減速して止まる
    private static func ease(_ x: Double) -> Double { 1 - pow(1 - x, 3) }

    /// 少し行きすぎて戻る（ぽこりん・つなぽんの backOut と同じ）
    private static func backOut(_ x: Double) -> Double {
        let c1 = 1.70158, c3 = c1 + 1
        return x <= 0 ? 0 : x >= 1 ? 1 : 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2)
    }
}

/// @keyframes breathe：3.2秒で scale(1,1) ↔ scale(1.02,.98)
private struct Breathe: ViewModifier {
    let active: Bool
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(x: on && active ? 1.02 : 1, y: on && active ? 0.98 : 1, anchor: UnitPoint(x: 0.5, y: 0.9))
            .animation(active ? .easeInOut(duration: 1.6).repeatForever(autoreverses: true) : .default, value: on)
            .onAppear { on = true }
    }
}

/// ふきだしの形（しっぽ付き）
struct BubbleShape: InsettableShape {
    enum Tail { case none, left, bottom }
    var tail: Tail
    var radius: CGFloat = 22
    var inset: CGFloat = 0

    func inset(by amount: CGFloat) -> BubbleShape {
        var s = self
        s.inset += amount
        return s
    }

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: inset, dy: inset)
        let rad = min(radius - inset, r.height / 2)
        var p = Path()
        p.move(to: CGPoint(x: r.minX + rad, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - rad, y: r.minY))
        p.addArc(center: CGPoint(x: r.maxX - rad, y: r.minY + rad), radius: rad, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY - rad))
        p.addArc(center: CGPoint(x: r.maxX - rad, y: r.maxY - rad), radius: rad, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        if tail == .bottom {
            // 18px の正方形を45度回して縦に0.8倍した角（.bubble::after）
            p.addLine(to: CGPoint(x: r.midX + 10.2, y: r.maxY))
            p.addLine(to: CGPoint(x: r.midX, y: r.maxY + 12.2 - inset))
            p.addLine(to: CGPoint(x: r.midX - 10.2, y: r.maxY))
        }
        p.addLine(to: CGPoint(x: r.minX + rad, y: r.maxY))
        p.addArc(center: CGPoint(x: r.minX + rad, y: r.maxY - rad), radius: rad, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        if tail == .left {
            // 幅12・高さ18の三角（#hero .bubble::before）
            p.addLine(to: CGPoint(x: r.minX, y: r.midY + 9 - inset))
            p.addLine(to: CGPoint(x: r.minX - 12 + inset * 1.5, y: r.midY))
            p.addLine(to: CGPoint(x: r.minX, y: r.midY - 9 + inset))
        }
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + rad))
        p.addArc(center: CGPoint(x: r.minX + rad, y: r.minY + rad), radius: rad, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.closeSubpath()
        return p
    }
}

/// ふきだし（.bubble.fix）。2行分の高さで固定し、収まらないときだけ文字を小さくする
struct SpeechBubble: View {
    let text: String
    var tail: BubbleShape.Tail = .bottom
    var fontSize: CGFloat = 15
    var radius: CGFloat = 22
    var paddingH: CGFloat = 14
    var paddingV: CGFloat = 10
    var centered = true
    /// 2行分の高さで固定する（.fix）。false なら文字の分だけ
    var fixed = true
    /// 横幅いっぱいに広げる。false なら文字の幅に合わせる（inline-flex）
    var fillWidth = true

    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let lineH = fontSize * 1.5
        BalancedText(text: text, fontSize: fontSize)
            .multilineTextAlignment(centered ? .center : .leading)
            .frame(maxWidth: fillWidth ? .infinity : nil, alignment: centered ? .center : .leading)
            .frame(height: fixed ? lineH * 2 : nil)
            // 枠線 2px の内側に padding（box-sizing: border-box）
            .padding(.horizontal, paddingH + 2)
            .padding(.vertical, paddingV + 2)
            .frame(minHeight: 48)
            .background(BubbleShape(tail: tail, radius: radius).fill(Palette.card))
            .overlay(BubbleShape(tail: tail, radius: radius).strokeBorder(Palette.ink, lineWidth: 2))
    }
}

/// text-wrap: balance のように、2行になるときは行の長さをそろえて折り返す
struct BalancedText: View {
    let text: String
    let fontSize: CGFloat

    var body: some View {
        ViewThatFits(in: .horizontal) {
            line(text).fixedSize()
            line(Self.balanced(text))
        }
    }

    private func line(_ s: String) -> some View {
        Text(s)
            .font(.ui(fontSize))
            .foregroundStyle(Palette.ink)
            .lineHeight(1.5, size: fontSize)
            .lineLimit(2)
            .minimumScaleFactor(11 / fontSize)
    }

    /// まん中あたりの区切り（、。！？…〜 の後ろ）で改行する
    static func balanced(_ s: String) -> String {
        let chars = Array(s)
        guard chars.count > 4 else { return s }
        let mid = chars.count / 2
        let breaks = Set("、。！？!?…〜ー」 ")
        let candidates = (1..<chars.count).filter { breaks.contains(chars[$0 - 1]) && !breaks.contains(chars[$0]) }
        let at = candidates.min { abs($0 - mid) < abs($1 - mid) }.flatMap { abs($0 - mid) <= chars.count / 4 ? $0 : nil } ?? mid
        return String(chars[..<at]) + "\n" + String(chars[at...])
    }
}
