//
//  TagsView.swift
//  kawaii_taiju_kanri
//
//  せっていから開く「タグ」画面。「きょうのこと」に出すタグを、足す・消す・ならべかえる。
//  見た目と開きかたはバックアップ画面にそろえている。
//
//  タグは日本語のまま記録に保存するキー（DayTag）。はじめのタグは表示するときだけ訳し、
//  自分で足したタグは書いたとおりに出す。名前の変更は、これまでの記録とずれるので置いていない。
//

import SwiftUI

struct TagsView: View {
    @EnvironmentObject private var store: WeightStore
    @ObservedObject private var ads = AdService.shared
    @State private var newTag = ""
    @FocusState private var adding: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SubpageNav(title: L("タグ")) { close() }
                SettingsGroup(title: L("タグを足す")) {
                    addRow
                }
                .padding(.top, 4)
                SettingsGroup(
                    title: L("きょうのことのタグ"),
                    footer: L("上にあるタグほど、ホームで先に見えるよ。消しても、これまでの記録に付いたタグはそのまま残るよ")
                ) {
                    ForEach(Array(store.settings.tags.enumerated()), id: \.element) { i, t in
                        tagRow(t, first: i == 0)
                    }
                }
                .padding(.top, 18)
                if !missingDefaults.isEmpty {
                    SettingsGroup(title: L("はじめのタグ"), footer: L("「飲み会」などのタグを付けた日は、キャラがやさしく受け止めてくれるよ")) {
                        SettingsButtonRow(icon: "↩️", iconBG: Color(hex: 0xF3EEE9), label: L("はじめのタグをもどす"),
                                          note: missingDefaults.map { L($0) }.joined(separator: L("、"))) {
                            withAnimation(.cssEase(0.25)) {
                                if let error = store.restoreDefaultTags() { store.showToast(error) }
                            }
                        }
                    }
                    .padding(.top, 18)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 110 + ads.bannerHeight)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(Palette.paper)
        .overlay(alignment: .top) {
            Color.clear.frame(height: 0).background(Palette.paper.ignoresSafeArea(edges: .top))
        }
        .edgeSwipeBack { close() }
    }

    private func close() {
        adding = false
        store.showTags = false
    }

    /// 一覧から消した「はじめのタグ」
    private var missingDefaults: [String] {
        DayTag.all.filter { !store.settings.tags.contains($0) }
    }

    // MARK: - 行

    private var addRow: some View {
        HStack(spacing: 10) {
            TextField("", text: $newTag, prompt: Text(L("例：おやつ")).foregroundStyle(Palette.inkFaint))
                .focused($adding)
                .submitLabel(.done)
                .onSubmit(add)
                .font(.ui(15, .medium))
                .foregroundStyle(Palette.ink)
                .padding(.vertical, 10).padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Palette.paper))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Palette.line, lineWidth: 2))
            Button(L("たす"), action: add)
                .font(.ui(14, .black))
                .foregroundStyle(.white)
                .padding(.vertical, 10).padding(.horizontal, 16)
                .background(Capsule().fill(Palette.ink))
                .buttonStyle(.plain)
                .opacity(newTag.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
    }

    private func tagRow(_ t: String, first: Bool) -> some View {
        SettingsRow(label: L(t), note: DayTag.all.contains(t) ? nil : L("じぶんで足したタグ")) {
            HStack(spacing: 8) {
                RoundStepButton.mini("↑") {
                    withAnimation(.cssEase(0.25)) { store.moveTagUp(t) }
                }
                .disabled(first)
                .opacity(first ? 0.3 : 1)
                .accessibilityLabel(LF("「%@」を上へ", L(t)))
                RoundStepButton.mini("×") {
                    guard store.settings.tags.count > 1 else {
                        store.showToast(L("タグは1つは残してね"))
                        return
                    }
                    withAnimation(.cssEase(0.25)) { store.removeTag(t) }
                }
                .accessibilityLabel(LF("「%@」を消す", L(t)))
            }
        }
    }

    private func add() {
        if let error = store.addTag(newTag) {
            store.showToast(error)
            return
        }
        newTag = ""
    }
}
