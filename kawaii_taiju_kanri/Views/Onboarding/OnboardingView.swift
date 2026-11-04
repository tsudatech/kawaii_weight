//
//  OnboardingView.swift
//  kawaii_taiju_kanri
//
//  はじめての起動（あいさつ → 身長・目標 → 通知 → じゅんび完了）
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: WeightStore
    @State private var step = 0

    private struct Step {
        let face: String
        let bubble: String
        var title: String?
        let text: String
        var kind: Kind = .plain
        let button: String
        var skip: String?
        enum Kind { case plain, body, notify }
    }

    private let steps: [Step] = [
        Step(face: "lg_happy", bubble: L("はじめまして！"), title: L("まいにちの体重を\nいっしょにきろくしよう"), text: L("朝いちばんに体重計にのって、ここにきろくしてね。増えた日も減った日も、ちゃんとそばにいるよ。"), button: L("はじめる")),
        Step(face: "lg_hmm", bubble: L("からだのことを教えてね"), text: L("もくひょうまでの進み具合と、BMIの計算につかうよ。あとから変えられるよ。"), kind: .body, button: L("つぎへ")),
        Step(face: "lg_sleepy", bubble: L("毎日、声をかけてもいい？"), text: L("はかり忘れないように、決まった時間におしらせするよ。"), kind: .notify, button: L("おしらせをうけとる"), skip: L("いまはいい")),
        Step(face: "lg_cheer", bubble: L("じゅんびできた！"), title: L("さっそく、はかってみよう"), text: L("さいしょの体重が、ゴールまでのスタート地点になるよ。"), button: L("きょうの体重をきろくする")),
    ]

    var body: some View {
        let s = steps[step]
        VStack(spacing: 0) {
            topBar
            VStack(spacing: 12) {
                SpeechBubble(text: s.bubble, tail: .bottom, fixed: false, fillWidth: false)
                    .frame(maxWidth: 290)
                CharacterView(asset: s.face, size: 190, bounceKey: step, breathe: false)
                    .padding(.top, 8)
                if let title = s.title {
                    Text(title)
                        .font(.ui(24, .black))
                        .multilineTextAlignment(.center)
                        .lineHeight(1.4, size: 24)
                        .foregroundStyle(Palette.ink)
                        .padding(.top, 6)
                }
                Text(s.text)
                    .font(.ui(14))
                    .multilineTextAlignment(.center)
                    .lineHeight(1.75, size: 14)
                    .foregroundStyle(Palette.inkSoft)
                    .frame(maxWidth: 300)
                switch s.kind {
                case .body: bodyFields
                case .notify: notifyFields
                case .plain: EmptyView()
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 18)
            .frame(maxHeight: .infinity)
            .id(step)
            .transition(.asymmetric(insertion: .opacity.combined(with: .offset(y: 6)), removal: .identity))
            VStack(spacing: 10) {
                Button(step == steps.count - 1 && store.isTodayRecorded ? L("はじめる") : s.button) { next(skipped: false) }
                    .buttonStyle(.primary)
                // 「いまはいい」がないステップも場所だけ確保して、メインボタンの位置をそろえる
                Button(skipLabel(s)) { next(skipped: true) }
                    .font(.ui(13))
                    .foregroundStyle(Palette.inkSoft)
                    .buttonStyle(.plain)
                    .padding(.vertical, 6).padding(.horizontal, 10)
                    .opacity(s.skip == nil ? 0 : 1)
                    .disabled(s.skip == nil)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 40)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(
            LinearGradient(stops: [.init(color: Palette.heroTop, location: 0), .init(color: Palette.paper, location: 0.55)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .animation(.cssEase(0.35), value: step)
    }

    /// .onbTop
    private var topBar: some View {
        HStack {
            Button(L("‹ もどる")) { step -= 1 }
                .font(.ui(14, .black))
                .foregroundStyle(Palette.inkSoft)
                .buttonStyle(.plain)
                .padding(.vertical, 4)
                .opacity(step == 0 ? 0 : 1)
                .disabled(step == 0)
                .frame(width: 72, alignment: .leading)
            Spacer()
            HStack(spacing: 6) {
                ForEach(steps.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == step ? Palette.rose : Color(hex: 0xE9DED4))
                        .frame(width: i == step ? 22 : 8, height: 8)
                }
            }
            .animation(.cssEase(0.3), value: step)
            Spacer()
            Color.clear.frame(width: 72, height: 1)
        }
        .frame(minHeight: 32)
    }

    /// .onbField（身長・もくひょう）
    private var bodyFields: some View {
        VStack(spacing: 0) {
            SettingsRow(label: L("身長")) {
                AdjustControl(value: "\(store.settings.height)", unit: "cm") { d in
                    store.settings.height = min(220, max(120, store.settings.height + d))
                }
            }
            .padding(.horizontal, -14)
            SettingsRow(label: L("もくひょう体重")) {
                AdjustControl(value: Fmt.kg(store.settings.goal), unit: "kg") { d in
                    store.settings.goal = min(150, max(30, store.settings.goal + Double(d) * 0.5))
                }
            }
            .padding(.horizontal, -14)
        }
        .onbField()
    }

    /// .onbField（おしらせの時間）
    private var notifyFields: some View {
        VStack(spacing: 12) {
            SettingsRow(label: L("おしらせの時間")) {
                TimeField(time: $store.settings.remindTime)
            }
            .padding(.horizontal, -14)
            .onbField()
            Text(L("このあと iPhone から通知の許可をたずねるよ"))
                .font(.ui(11))
                .foregroundStyle(Color(hex: 0xB5A193))
        }
    }

    /// 「いまはいい」。通知がもうオンなら「いまのままにする」（押しても切れないことが伝わるように）
    private func skipLabel(_ s: Step) -> String {
        if s.kind == .notify && store.settings.remind { return L("いまのままにする") }
        return s.skip ?? L("いまはいい")
    }

    private func next(skipped: Bool) {
        // 「いまはいい」は、いまの設定をそのまま（もう一度設定するときに、オンの通知を切ってしまわないように）
        if steps[step].kind == .notify && !skipped { store.setRemind(true) }
        if step < steps.count - 1 {
            step += 1
            return
        }
        store.onboarded = true
        store.selectedTab = .home
        store.showOnboarding = false
    }
}

private extension View {
    /// .onbField（白いカード・余白 6 14）
    func onbField() -> some View {
        padding(.vertical, 8).padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 22).fill(Palette.card))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(Palette.line, lineWidth: 2))
    }
}
