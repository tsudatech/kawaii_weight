//
//  CoachMarks.swift
//  kawaii_taiju_kanri
//
//  はじめて開いたときの案内（コーチマーク）。ぽこりんの Onboarding と同じ作り。
//  ・暗幕に穴を開けて、いま話している部品だけを見せる
//  ・どこを押しても次へ。右下の「スキップ」で最後まで飛ばす
//  ・一度見たら端末に覚えておき、二度と出さない（タブごとに別々に覚える）
//

import SwiftUI

// MARK: - どの案内を見たか

enum Onboarding {
    enum Kind: String, CaseIterable {
        case home, graph, chara, settings
    }

    private static func key(_ kind: Kind) -> String { "onboarding.seen.\(kind.rawValue).v1" }

    static func needs(_ kind: Kind) -> Bool {
        !UserDefaults.standard.bool(forKey: key(kind))
    }

    static func markSeen(_ kind: Kind) {
        UserDefaults.standard.set(true, forKey: key(kind))
    }

    /// 全部を見たことにする / 全部を未読にもどす
    static func setAllSeen(_ seen: Bool) {
        for kind in Kind.allCases { UserDefaults.standard.set(seen, forKey: key(kind)) }
    }
}

/// 案内の1ページ。target は `.coachTarget(_:)` で印をつけた部品
struct CoachPage: Equatable {
    let target: String
    let text: String
    /// 穴の角の丸み（nil なら高さの半分＝丸端）
    var radius: CGFloat? = 28
}

/// いま出している案内
struct CoachTour: Equatable {
    let kind: Onboarding.Kind
    let pages: [CoachPage]
}

// MARK: - 見せたい部品に印をつける

struct CoachTargetKey: PreferenceKey {
    static let defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

extension View {
    /// 案内で穴を開けて見せる部品の印
    func coachTarget(_ id: String) -> some View {
        anchorPreference(key: CoachTargetKey.self, value: .bounds) { [id: $0] }
    }
}

// MARK: - 穴を開けた暗幕と吹き出し

struct CoachMarkOverlay: View {
    let tour: CoachTour
    /// 部品の位置（この View と同じ座標）
    let rects: [String: CGRect]
    /// 吹き出しがはみ出さない下端（タブバーの上）
    let bandBottom: CGFloat
    let onFinish: () -> Void

    @State private var index = 0

    /// 画面に見えている部品だけで、ページを組み直したもの
    private var pages: [(page: CoachPage, rect: CGRect)] {
        tour.pages.compactMap { p in rects[p.target].map { (p, $0) } }
    }

    var body: some View {
        GeometryReader { geo in
            let list = pages
            if !list.isEmpty {
                let i = min(index, list.count - 1)
                let hole = list[i].rect.insetBy(dx: -8, dy: -8)
                let radius = list[i].page.radius.map { $0 + 8 } ?? hole.height / 2
                ZStack(alignment: .topLeading) {
                    // どこを押しても次へ（画面の外側まで広く取る）
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture { next(count: list.count) }
                    DimWithHole(hole: hole, radius: radius)
                        .fill(Color(hex: 0x2B1C12).opacity(0.62), style: FillStyle(eoFill: true))
                        .allowsHitTesting(false)
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(.white.opacity(0.9), lineWidth: 2)
                        .frame(width: hole.width, height: hole.height)
                        .offset(x: hole.minX, y: hole.minY)
                        .allowsHitTesting(false)
                    CoachBubble(text: list[i].page.text, index: i, count: list.count, hole: hole,
                                screen: geo.size, bandBottom: bandBottom) { next(count: list.count) }
                    // スキップは右下（右上にはタブの見出しやボタンがあって隠してしまうので）。
                    // 見せる部品が下のほう（タブバーなど）で、吹き出しと重なるときだけ右上に置く
                    let skipAtTop = hole.maxY > bandBottom - 60
                    Button(L("スキップ"), action: finish)
                        .font(.ui(14))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18).frame(height: 36)
                        .background(Capsule().fill(Palette.ink))
                        .overlay(Capsule().strokeBorder(.white.opacity(0.85), lineWidth: 1.5))
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: skipAtTop ? .topTrailing : .bottomTrailing)
                        .padding(.trailing, 16)
                        .padding(.top, skipAtTop ? 8 : 0)
                        .padding(.bottom, skipAtTop ? 0 : geo.size.height - bandBottom + 4)
                }
                .id(i)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.2), value: i)
            }
        }
        #if DEBUG
        // デバッグ起動 `--coach-page N`：N ページ目（0から）から見せる（見た目の確認用）
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
            if let i = args.firstIndex(of: "--coach-page"), i + 1 < args.count, let n = Int(args[i + 1]) { index = max(0, n) }
        }
        #endif
    }

    private func next(count: Int) {
        if index + 1 < count {
            withAnimation(.easeOut(duration: 0.2)) { index += 1 }
        } else {
            finish()
        }
    }

    private func finish() {
        onFinish()
    }
}

/// 画面より大きな四角から、穴をくり抜いた形（偶奇ルールで塗る）
private struct DimWithHole: Shape {
    let hole: CGRect
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path(rect.insetBy(dx: -1000, dy: -1000))
        p.addRoundedRect(in: hole, cornerSize: CGSize(width: radius, height: radius))
        return p
    }
}

/// 吹き出し（下に置けるなら下、だめなら上、どちらも無理なら穴の中の上寄り）
private struct CoachBubble: View {
    let text: String
    let index: Int
    let count: Int
    let hole: CGRect
    let screen: CGSize
    let bandBottom: CGFloat
    let onNext: () -> Void

    @State private var height: CGFloat = 120

    private let gap: CGFloat = 16
    private let caretH: CGFloat = 10

    var body: some View {
        let width = min(310, screen.width - 32)
        let placement = place(width: width)
        VStack(alignment: .leading, spacing: 12) {
            Text(text)
                .font(.ui(15))
                .foregroundStyle(Palette.ink)
                .lineHeight(1.5, size: 15)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 6) {
                ForEach(0..<count, id: \.self) { i in
                    Capsule()
                        .fill(i == index ? Palette.rose : Color(hex: 0xE9DED4))
                        .frame(width: i == index ? 16 : 6, height: 6)
                }
                Spacer(minLength: 8)
                Button(index == count - 1 ? L("はじめる") : L("つぎへ"), action: onNext)
                    .font(.ui(14))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(width: 96, height: 30)
                    .background(Capsule().fill(Palette.rose))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 2))
                    .buttonStyle(.plain)
            }
        }
        .padding(.top, 14).padding(.horizontal, 16).padding(.bottom, 12)
        .frame(width: width)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Palette.ink, lineWidth: 2))
        .overlay(alignment: .topLeading) { caret(placement: placement, width: width) }
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height = $0 }
        .offset(x: placement.left, y: placement.top)
        .onTapGesture(perform: onNext)
    }

    /// 吹き出しの左上と、三角の向き（true：上の穴を指す / false：下の穴を指す / nil：なし）
    private func place(width: CGFloat) -> (left: CGFloat, top: CGFloat, caretUp: Bool?) {
        var top: CGFloat
        var up: Bool?
        if hole.maxY + gap + caretH + height <= bandBottom {
            top = hole.maxY + gap + caretH
            up = true
        } else if hole.minY - gap - caretH - height >= 20 {
            top = hole.minY - gap - caretH - height
            up = false
        } else {
            top = hole.minY + 16
            up = nil
        }
        top = max(top, 20)
        let cx = min(max(hole.midX, 16 + width / 2), screen.width - 16 - width / 2)
        return (cx - width / 2, top, up)
    }

    @ViewBuilder
    private func caret(placement: (left: CGFloat, top: CGFloat, caretUp: Bool?), width: CGFloat) -> some View {
        if let up = placement.caretUp {
            let tipX = min(max(hole.midX - placement.left, 26), width - 26)
            Path { p in
                if up {
                    p.move(to: CGPoint(x: tipX, y: -caretH))
                    p.addLine(to: CGPoint(x: tipX + 10, y: 1))
                    p.addLine(to: CGPoint(x: tipX - 10, y: 1))
                } else {
                    p.move(to: CGPoint(x: tipX, y: height + caretH))
                    p.addLine(to: CGPoint(x: tipX + 10, y: height - 1))
                    p.addLine(to: CGPoint(x: tipX - 10, y: height - 1))
                }
                p.closeSubpath()
            }
            .fill(.white)
            .overlay {
                Path { p in
                    if up {
                        p.move(to: CGPoint(x: tipX - 10, y: 0))
                        p.addLine(to: CGPoint(x: tipX, y: -caretH))
                        p.addLine(to: CGPoint(x: tipX + 10, y: 0))
                    } else {
                        p.move(to: CGPoint(x: tipX - 10, y: height))
                        p.addLine(to: CGPoint(x: tipX, y: height + caretH))
                        p.addLine(to: CGPoint(x: tipX + 10, y: height))
                    }
                }
                .stroke(Palette.ink, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
            }
        }
    }
}
