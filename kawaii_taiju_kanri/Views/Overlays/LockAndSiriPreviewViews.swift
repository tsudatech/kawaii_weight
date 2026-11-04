//
//  LockAndSiriPreviewViews.swift
//  kawaii_taiju_kanri
//
//  ロック画面ウィジェットと Siri のみため（.ov.lock / .ov.siri）。置きかた・言いかたの案内も兼ねる
//

import SwiftUI

/// 下へスワイプで閉じる
private struct SwipeToClose: ViewModifier {
    let close: () -> Void
    @State private var swipe: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(y: swipe)
            .gesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .global)
                    .onChanged { swipe = max(0, $0.translation.height) }
                    .onEnded { v in
                        if v.translation.height > 140 || v.predictedEndTranslation.height > 360 {
                            close()
                        } else {
                            withAnimation(.slide) { swipe = 0 }
                        }
                    }
            )
    }
}

/// .sbNote
private struct PreviewNote: View {
    let text: String
    let close: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(text)
                .font(.ui(12))
                .lineHeight(1.6, size: 12)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(L("アプリにもどる"), action: close)
                .font(.ui(12, .black))
                .foregroundStyle(Palette.ink)
                .padding(.vertical, 6).padding(.horizontal, 12)
                .background(Capsule().fill(Palette.onInk))
                .buttonStyle(.plain)
                .fixedSize()
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
        .background(RoundedRectangle(cornerRadius: 18).fill(Palette.ink.opacity(0.78)))
    }
}

// MARK: - ロック画面

struct LockPreviewView: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let recorded = store.isTodayRecorded
        let pct = store.goalInfo().map { max(0, min(100, $0.pct)) } ?? 0
        VStack(spacing: 0) {
            Text(Fmt.dayTitle(.today)).font(.ui(17)).opacity(0.92)
            Text("🔥" + LF("%d日れんぞく", store.streak) + L(" ・ ") + (recorded ? L("きょうは記録ずみ") : L("まだはかってないよ")))
                .font(.ui(13)).opacity(0.9).padding(.bottom, 2)
            Text(verbatim: "9:41")
                .font(.system(size: 90, weight: .bold))
                .tracking(-2)
                .padding(.bottom, 14)
            HStack(spacing: 10) {
                circle {
                    Image(store.todayState.mood.smallAsset).resizable().scaledToFit()
                        .padding(3)
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(Palette.onInk))
                }
                average
                circle {
                    ZStack {
                        Circle().stroke(.white.opacity(0.3), lineWidth: 4).padding(6)
                        Circle().trim(from: 0, to: pct / 100)
                            .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .padding(6)
                        VStack(spacing: 0) {
                            Text("\(Text("\(Int(floor(pct)))").font(.num(17)))\(Text("%").font(.ui(8)))")
                                .numLineHeight(1, size: 17)
                            Text(L("もくひょう")).font(.ui(8)).opacity(0.85).lineLimit(1).minimumScaleFactor(0.7)
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
            .frame(height: 72)
            Spacer(minLength: 12)
            HStack {
                bottomButton { Text("🔦").font(.system(size: 20)) }
                Spacer()
                VStack(spacing: 4) {
                    bottomButton {
                        Image(Mood.good.smallAsset).resizable().scaledToFit()
                            .padding(2)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Palette.onInk))
                    }
                    Text(L("体重をきろく")).font(.ui(10))
                }
            }
            .padding(.horizontal, 26)
            PreviewNote(text: L("ロック画面を長押し →「カスタマイズ」でウィジェットを置けるよ。右下のボタンは、ロック画面のコントロールから置けて、押すと体重入力が開くよ")) {
                store.showLockPreview = false
            }
            .padding(.top, 18)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 22).padding(.top, 24).padding(.bottom, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(stops: [
                .init(color: Color(hex: 0x3B2B25), location: 0),
                .init(color: Color(hex: 0x6E4C40), location: 0.5),
                .init(color: Color(hex: 0xC9918A), location: 1),
            ], startPoint: UnitPoint(x: 0.4, y: 0), endPoint: UnitPoint(x: 0.6, y: 1))
            .ignoresSafeArea()
        )
        .modifier(SwipeToClose { store.showLockPreview = false })
    }

    /// .lkR
    private var average: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L("7日平均")).font(.ui(10)).opacity(0.85)
            Group {
                if store.settings.hideNumbers {
                    Text(verbatim: "••.•").font(.num(24))
                } else {
                    Text("\(Text(store.recentAverage.map { Fmt.kg($0) } ?? "—").font(.num(24)))\(Text("kg").font(.num(11)))")
                }
            }
            .numLineHeight(1.25, size: 24)
            Text(subline).font(.ui(10)).opacity(0.85).lineLimit(1).minimumScaleFactor(0.8)
        }
        .padding(.vertical, 8).padding(.horizontal, 12)
        .frame(maxWidth: 150, maxHeight: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.2)))
    }

    private var subline: String {
        guard let e = store.todayEntry else { return L("タップしてきろく") }
        return store.settings.hideNumbers ? L("きょうも記録したよ") : LF("きょう %@kg", Fmt.kg(e.weight))
    }

    private func circle<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        content()
            .frame(width: 72, height: 72)
            .background(Circle().fill(.white.opacity(0.2)))
    }

    private func bottomButton<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        content()
            .frame(width: 52, height: 52)
            .background(Circle().fill(Color(hex: 0x1E1410).opacity(0.45)))
    }
}

// MARK: - Siri

struct SiriPreviewView: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        let name = L("たいかん！")
        // 声で記録したときの見本（保存はしない）。いまの体重から少し減った日にする
        let v = ((store.lastWeightOrDefault - 0.3) * 10).rounded() / 10
        let d = store.average7(before: .today).map { ((v - $0) * 10).rounded() / 10 } ?? 0
        let mood: Mood = d < -0.1 ? .happy : d <= 0.1 ? .good : .trouble
        let hide = store.settings.hideNumbers
        VStack(spacing: 0) {
            Spacer(minLength: 12)
            VStack(spacing: 0) {
                Text(verbatim: "「Hey Siri」").font(.ui(12)).opacity(0.75)
                Text(LF("%@で体重をきろく", name)).font(.ui(21))
                    .lineHeight(1.45, size: 21)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.bottom, 16)
            HStack(spacing: 10) {
                Image(mood.largeAsset).resizable().scaledToFit().frame(width: 76, height: 76)
                VStack(alignment: .leading, spacing: 0) {
                    Text(name).font(.ui(10)).foregroundStyle(Palette.inkSoft)
                    Text(hide ? L("きろくしたよ！") : LF("%@kg をきろくしたよ！", Fmt.kg(v))).font(.ui(16, .black))
                    Text(Self.reply(diff: d, hide: hide))
                        .font(.ui(12)).foregroundStyle(Palette.inkSoft).lineHeight(1.5, size: 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(Palette.ink)
            .padding(.vertical, 12).padding(.horizontal, 14)
            .background(RoundedRectangle(cornerRadius: 26).fill(Color(hex: 0xFFFAF6).opacity(0.97)))
            VStack(alignment: .leading, spacing: 5) {
                Text(L("Siri に言えること")).font(.ui(12, .black)).foregroundStyle(Palette.inkSoft).padding(.bottom, 1)
                phrase(LF("「%@で体重をきろく」→ 何キロかを聞くよ", name))
                phrase(LF("「%@できょうの体重」", name))
                phrase(LF("「%@で7日平均」", name))
                HStack(spacing: 6) {
                    shortcut(L("体重をきろく"))
                    shortcut(L("7日平均をみる"))
                }
                .padding(.top, 3)
            }
            .padding(.vertical, 12).padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 22).fill(Color(hex: 0xFFFAF6).opacity(0.93)))
            .padding(.top, 10)
            Capsule()
                .fill(LinearGradient(colors: [Palette.cheek, Palette.rose, Palette.sky, Palette.gold, Palette.cheek], startPoint: .leading, endPoint: .trailing))
                .frame(height: 8)
                .blur(radius: 2)
                .padding(.horizontal, 20)
                .padding(.top, 14)
            PreviewNote(text: L("Siri とショートカットのみためだよ（見本なので保存はしないよ）")) {
                store.showSiriPreview = false
            }
            .padding(.top, 12)
        }
        .padding(.horizontal, 14).padding(.top, 24).padding(.bottom, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: 0x281C16).opacity(0.86).background(.ultraThinMaterial).ignoresSafeArea())
        .modifier(SwipeToClose { store.showSiriPreview = false })
    }

    /// 声で記録したあとの、ふたことめ（Siri の本番の返事と同じ）
    static func reply(diff: Double, hide: Bool) -> String {
        if hide { return diff <= 0.1 ? L("いい流れだよ。きょうもえらい！") : L("ちょっとふえ気味。気にしすぎないでね") }
        let tail = diff <= 0.1 ? L("きょうもえらい！") : L("気にしすぎないでね")
        return LF("7日平均から %1$@kg。%2$@", Fmt.signed(diff), tail)
    }

    private func phrase(_ s: String) -> some View {
        Text(s)
            .font(.ui(13))
            .foregroundStyle(Palette.ink)
            .padding(.vertical, 6).padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
    }

    private func shortcut(_ s: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(s).font(.ui(12, .black))
            Text(L("ショートカットのアクション")).font(.ui(10)).opacity(0.9)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 8).padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(LinearGradient(colors: [Palette.rose, Palette.gold], startPoint: .topLeading, endPoint: .bottomTrailing)))
    }
}
