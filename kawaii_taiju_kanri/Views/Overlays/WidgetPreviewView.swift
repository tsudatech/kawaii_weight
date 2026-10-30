//
//  WidgetPreviewView.swift
//  kawaii_taiju_kanri
//
//  ホーム画面ウィジェットの見た目と、置きかたの案内（.springboard）
//

import SwiftUI

struct WidgetPreviewView: View {
    @EnvironmentObject private var store: WeightStore
    /// 下へスワイプしているときのずれ
    @State private var swipe: CGFloat = 0

    private let gridGap: CGFloat = 14
    private let rowGap: CGFloat = 18

    var body: some View {
        let ts = store.todayState
        VStack(spacing: 0) {
            GeometryReader { geo in
                let col = (geo.size.width - gridGap * 3) / 4
                // CSS grid（4列）の自動配置と同じ並び：
                // 1段目 小ウィジェット(2列)・カレンダー・写真 ／ 2段目 カメラ・天気・（小）の名前 ／ 3段目 空
                // 4段目 中ウィジェット(4列) ／ 5段目 （中）の名前 ／ 6段目 アイコン4つ
                VStack(alignment: .leading, spacing: rowGap) {
                    HStack(alignment: .top, spacing: gridGap) {
                        smallWidget(mood: ts.mood)
                            .frame(width: col * 2 + gridGap, height: col * 2 + gridGap)
                        appIcon(L("カレンダー"), col)
                        appIcon(L("写真"), col)
                    }
                    HStack(alignment: .top, spacing: gridGap) {
                        appIcon(L("カメラ"), col)
                        appIcon(L("天気"), col)
                        label(L("体重きろく（小）"))
                            .frame(width: col * 2 + gridGap)
                            .offset(y: -12)
                    }
                    Color.clear.frame(height: 0)
                    mediumWidget(mood: ts.mood, line: ts.line ?? ts.mood.lines[0])
                        .frame(height: geo.size.width / 2.15)
                    label(L("体重きろく（中）"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, -12)
                    HStack(alignment: .top, spacing: gridGap) {
                        appIcon(L("メモ"), col)
                        appIcon(L("時計"), col)
                        VStack(spacing: 5) {
                            Image("sm_good").resizable().scaledToFit()
                                .padding(2)
                                .frame(width: min(58, col), height: min(58, col))
                                .background(RoundedRectangle(cornerRadius: 15).fill(LinearGradient(colors: [Palette.faceBG, Palette.cheek], startPoint: UnitPoint(x: 0.35, y: 0), endPoint: UnitPoint(x: 0.65, y: 1))))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(color: Palette.ink.opacity(0.4), radius: 5, y: 4)
                            label(L("体重きろく"))
                        }
                        .frame(width: col)
                        appIcon(L("ミュージック"), col)
                    }
                }
            }
            // .sbNote
            HStack(spacing: 10) {
                Text(L("ホーム画面の何もないところを長押し →「編集」→「ウィジェットを追加」から「体重きろく」をえらんでね"))
                    .font(.ui(12))
                    .lineHeight(1.6, size: 12)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(L("アプリにもどる")) { store.showWidgetPreview = false }
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
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 30)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(
            LinearGradient(stops: [
                .init(color: Color(hex: 0xF8C9C0), location: 0),
                .init(color: Color(hex: 0xFBE3D2), location: 0.45),
                .init(color: Color(hex: 0xCFE7E4), location: 1),
            ], startPoint: UnitPoint(x: 0.4, y: 0), endPoint: UnitPoint(x: 0.6, y: 1))
            .ignoresSafeArea()
        )
        .offset(y: swipe)
        // 下へスワイプで閉じる
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .global)
                .onChanged { swipe = max(0, $0.translation.height) }
                .onEnded { v in
                    if v.translation.height > 140 || v.predictedEndTranslation.height > 360 {
                        store.showWidgetPreview = false
                    } else {
                        withAnimation(.slide) { swipe = 0 }
                    }
                }
        )
    }

    private func label(_ s: String) -> some View {
        Text(s).font(.ui(10)).foregroundStyle(.white).lineLimit(1)
            .shadow(color: Palette.ink.opacity(0.3), radius: 1, y: 1)
    }

    /// .ico
    private func appIcon(_ name: String, _ col: CGFloat) -> some View {
        VStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 15).fill(.white.opacity(0.55)).frame(width: min(58, col), height: min(58, col))
            label(name)
        }
        .frame(width: col)
    }

    private func widgetCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: 22).fill(Color(hex: 0xFFFAF6).opacity(0.95)).shadow(color: Palette.ink.opacity(0.35), radius: 9, y: 6))
            .foregroundStyle(Palette.ink)
    }

    /// .wdg.s
    private func smallWidget(mood: Mood) -> some View {
        let j = store.isTodayRecorded ? store.judge(.today) : nil
        return widgetCard {
            VStack(alignment: .leading, spacing: 0) {
                Image(mood.smallAsset).resizable().scaledToFit().frame(width: 58, height: 58)
                Spacer(minLength: 0)
                Text(store.isTodayRecorded ? L("きょう") : L("さいしん")).font(.ui(10)).foregroundStyle(Palette.inkSoft)
                Text("\(Text(store.latestWeight.map { Fmt.kg($0) } ?? "—").font(.num(26)))\(Text("kg").font(.num(12)))")
                    .numLineHeight(1, size: 26)
                Text(num: j?.diff.map { "\(Fmt.signed($0))kg" } ?? (store.isTodayRecorded ? "—" : L("まだはかってないよ")), size: 12, weight: .bold)
                    .foregroundStyle(deltaColor(j?.diff))
            }
        }
    }

    /// .wdg.m
    private func mediumWidget(mood: Mood, line: String) -> some View {
        let name = store.characterName.isEmpty ? L("キャラ") : store.characterName
        let pts = store.points(lastDays: 7)
        return widgetCard {
            HStack(spacing: 10) {
                Image(mood.largeAsset).resizable().scaledToFit().frame(width: 96, height: 96)
                VStack(alignment: .leading, spacing: 0) {
                    Text(LF("%1$@「%2$@」", name, String(line.prefix(16)))).font(.ui(10)).foregroundStyle(Palette.inkSoft).lineLimit(1)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Text(store.latestWeight.map { Fmt.kg($0) } ?? "—").font(.num(26)))\(Text("kg").font(.num(12)))")
                        Text(num: "🔥" + LF("%d日", store.streak), size: 12, weight: .bold)
                    }
                    .numLineHeight(1, size: 26)
                    Sparkline(values: pts.isEmpty ? [0, 0] : pts.map(\.weight))
                        .stroke(Palette.rose, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .frame(height: 26)
                        .padding(.vertical, 5)
                        .padding(.top, 4)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}
