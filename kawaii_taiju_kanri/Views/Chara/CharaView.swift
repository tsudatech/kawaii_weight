//
//  CharaView.swift
//  kawaii_taiju_kanri
//
//  キャラ（おへや・なかよし度・ごほうび・ひょうじょうずかん）
//

import SwiftUI

struct CharaView: View {
    @EnvironmentObject private var store: WeightStore
    @State private var talkIndex = 0
    @State private var bounce = 0
    @State private var nameDraft = ""
    @FocusState private var nameFocused: Bool

    var body: some View {
        ScreenScroll {
            ScreenHeader(caption: L("いっしょにがんばる相棒"), title: L("キャラ")) {
                Pill(prefix: L("きろく:回数の前"), value: "\(store.entries.count)", suffix: LF("%d回:単位", store.entries.count))
            }
            room.coachTarget("chara.room")
            levelCard.coachTarget("chara.level").padding(.top, 14)
            badgeCard.padding(.top, 14)
            dexCard.padding(.top, 14)
        }
        .onAppear { nameDraft = store.characterName }
    }

    // MARK: - おへや（.room）

    private var room: some View {
        let state = store.todayState
        let mood = store.roomMood ?? state.mood
        let custom = store.roomMood == nil ? state.line : nil
        var line = mood.line(custom: custom, index: talkIndex)
        if !store.characterName.isEmpty && talkIndex == 0 { line = LF("%1$@だよ。%2$@", store.characterName, line) }
        return VStack(spacing: 0) {
            if store.settings.talk {
                SpeechBubble(text: line, tail: .bottom)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 4)
            }
            CharacterView(asset: mood.largeAsset, size: 200, bounceKey: bounce) { talkIndex += 1 }
                .accessibilityLabel(LF("%@：タップでしゃべる", mood.label))
                .padding(.top, store.settings.talk ? 0 : 4)
            nameField.padding(.top, 6)
        }
        .padding(.top, 18).padding(.horizontal, 18).padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .heroBackground()
        .onChange(of: store.roomMood) { _, _ in talkIndex = 0 }
    }

    /// .nameRow input（幅160・20px・900）
    private var nameField: some View {
        TextField("", text: $nameDraft)
            .focused($nameFocused)
            .submitLabel(.done)
            .font(.ui(20, .black))
            .multilineTextAlignment(.center)
            .foregroundStyle(Palette.ink)
            .background(alignment: .center) {
                if nameDraft.isEmpty {
                    Text(L("なまえをつけてね"))
                        .font(.ui(20, .black))
                        .foregroundStyle(Color(hex: 0xC7A99A))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .allowsHitTesting(false)
                }
            }
            .padding(.vertical, 6).padding(.horizontal, 12)
            .frame(width: 160)
            .background(Capsule().fill(Palette.card))
            .overlay(Capsule().strokeBorder(nameFocused ? Palette.ink : Palette.heroBorder, lineWidth: 2))
            .onChange(of: nameDraft) { _, v in if v.count > 10 { nameDraft = String(v.prefix(10)) } }
            .onSubmit(commitName)
            .onChange(of: nameFocused) { _, f in if !f { commitName() } }
            .accessibilityLabel(L("キャラの名前"))
    }

    private func commitName() {
        let v = nameDraft.trimmingCharacters(in: .whitespaces)
        nameDraft = v
        guard v != store.characterName else { return }
        store.characterName = v
        talkIndex = 0
        bounce += 1
        store.showToast(v.isEmpty ? L("なまえを消しました") : LF("「%@」になったよ", v))
    }

    // MARK: - なかよし度

    private var levelCard: some View {
        let lv = store.level
        return VStack(alignment: .leading, spacing: 0) {
            CardTitle(L("なかよし度"), note: LF("あと%1$d回でLv.%2$d", 15 - lv.inLevel, lv.lv + 1))
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Lv.\(lv.lv)").font(.num(30)).foregroundStyle(Palette.rose).numLineHeight(1, size: 30)
                Text(lv.title).font(.ui(14)).foregroundStyle(Palette.ink)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Palette.seg)
                    StripeFill()
                        .frame(width: geo.size.width * Double(lv.inLevel) / 15)
                        .clipShape(Capsule())
                        .animation(.easeInOut(duration: 0.6), value: lv.inLevel)
                }
            }
            .frame(height: 14)
            .clipShape(Capsule())
            .padding(.top, 10)
            Hint(L("毎日きろくすると、なかよし度が上がるよ"))
        }
        .card()
    }

    // MARK: - ごほうび

    private var badgeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardTitle(L("ごほうび"), note: "\(store.earnedBadges.count) / \(Badge.all.count)")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6, alignment: .top), count: 4), spacing: 10) {
                ForEach(Badge.all) { b in
                    let on = store.earnedBadges.contains(b.id)
                    Button { store.celebrating = b } label: { BadgeView(badge: b, earned: on) }
                        .buttonStyle(.plain)
                        .disabled(!on)
                }
            }
            Hint(L("もらったメダルをタップすると、お祝いをもう一度見られるよ"))
        }
        .card()
    }

    // MARK: - ひょうじょうずかん

    private var dexCard: some View {
        let counts = store.moodCounts
        let current = store.roomMood ?? store.todayState.mood
        return VStack(alignment: .leading, spacing: 0) {
            CardTitle(L("ひょうじょうずかん"), note: LF("%dしゅるい", Mood.allCases.count))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(Mood.allCases) { m in
                    Button {
                        store.roomMood = m
                        talkIndex = 0
                        bounce += 1
                    } label: {
                        VStack(spacing: 2) {
                            Image(m.smallAsset).resizable().scaledToFit().frame(width: 54, height: 54)
                            Text(m.label).font(.ui(11)).foregroundStyle(Palette.ink)
                            Text(counts[m].map { LF("%d回", $0) } ?? "—").font(.num(11, .semibold)).foregroundStyle(Palette.inkSoft)
                                .numLineHeight(1, size: 11)
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 18).fill(Palette.soft))
                        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(current == m ? Palette.ink : .clear, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(current == m ? .isSelected : [])
                }
            }
            Hint(L("タップすると、おへやのキャラがその顔になるよ。数字はその顔になった日の回数"))
        }
        .card()
    }
}

/// なかよし度のしましま（repeating-linear-gradient(-45deg, rose 0 8px, #EC9F99 8px 16px)）
private struct StripeFill: View {
    var body: some View {
        Canvas { ctx, size in
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Palette.rose))
            // -45deg の帯：16px ごとに 8px 幅の淡い帯（帯に垂直な方向で測る）
            let period: CGFloat = 16 * 2.0.squareRoot()
            var x: CGFloat = -size.height
            while x < size.width + size.height {
                var p = Path()
                p.move(to: CGPoint(x: x + period / 2, y: 0))
                p.addLine(to: CGPoint(x: x + period, y: 0))
                p.addLine(to: CGPoint(x: x + period - size.height, y: size.height))
                p.addLine(to: CGPoint(x: x + period / 2 - size.height, y: size.height))
                p.closeSubpath()
                ctx.fill(p, with: .color(Color(hex: 0xEC9F99)))
                x += period
            }
        }
    }
}

/// .badge
struct BadgeView: View {
    let badge: Badge
    let earned: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if earned {
                    Circle()
                        .fill(RadialGradient(colors: [Color(hex: 0xFFF3D6), Palette.gold], center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 58 * 0.78))
                        .overlay(Circle().strokeBorder(Color(hex: 0xE5B464), lineWidth: 3))
                        .background(Circle().fill(Color(hex: 0xD9A250)).offset(y: 3))
                    VStack(spacing: 0) {
                        Text(badge.big).font(.num(16)).numLineHeight(1, size: 16)
                        if !badge.unit.isEmpty { Text(badge.unit).font(.ui(10)).lineHeight(1, size: 10) }
                    }
                    .foregroundStyle(Palette.ink)
                } else {
                    Circle().fill(Color(hex: 0xF5EEE8))
                        .overlay(Circle().strokeBorder(Color(hex: 0xE2D6CB), style: StrokeStyle(lineWidth: 2.5, dash: [5, 3])))
                    Text("？").font(.ui(16, .black)).foregroundStyle(Color(hex: 0xCDBDAF))
                }
            }
            .frame(width: 58, height: 58)
            Text(badge.name)
                .font(.ui(10))
                .multilineTextAlignment(.center)
                .lineHeight(1.3, size: 10)
                .foregroundStyle(earned ? Palette.ink : Color(hex: 0xBFAE9F))
        }
        .frame(maxWidth: .infinity)
    }
}
