//
//  BackupView.swift
//  kawaii_taiju_kanri
//
//  せっていから開く「バックアップ」画面。
//  構成はぽこりんの BackupScene にならう：オン・オフの行（状態の1行つき） → 今すぐバックアップ → 説明 → 使えないときの注意。
//  見た目は、このアプリのせってい・日の詳細にそろえている。
//

import SwiftUI

struct BackupView: View {
    @EnvironmentObject private var store: WeightStore
    @ObservedObject private var ads = AdService.shared
    @ObservedObject var backup: ICloudBackup
    /// 左端から右へスワイプしているときのずれ
    @State private var swipe: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                nav
                SettingsGroup(title: L("iCloud")) {
                    SettingsRow(icon: "☁️", iconBG: Color(hex: 0xE6F4F5), label: L("iCloudにバックアップ"), note: statusText, danger: false) {
                        CSSSwitch(isOn: Binding(get: { backup.isEnabled }, set: { backup.setEnabled($0) }), label: L("iCloudにバックアップ"))
                    }
                    if backup.isEnabled {
                        SettingsButtonRow(icon: "🔄", iconBG: Color(hex: 0xE7F5F0), label: L("今すぐバックアップ")) {
                            backup.syncNow()
                        }
                        .disabled(backup.status == .syncing)
                        .opacity(backup.status == .syncing ? 0.5 : 1)
                    }
                }
                .padding(.top, 4)
                Text(L("体重の記録（体脂肪・タグ・メモ・きぶん）と、ごほうび・キャラの名前をiCloudに預けます。同じApple IDの端末どうしで内容が合わさるので、機種変更やアプリを入れ直したときは、ここでもう一度オンにすると続きから使えます。せってい（身長・もくひょう・通知など）は、この端末だけに残ります。"))
                    .font(.ui(12))
                    .foregroundStyle(Palette.inkSoft)
                    .lineHeight(1.6, size: 12)
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                if !backup.isAvailable { unavailableNote.padding(.top, 18) }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 110 + ads.bannerHeight)
        }
        .scrollIndicators(.hidden)
        .background(Palette.paper)
        .overlay(alignment: .top) {
            Color.clear.frame(height: 0).background(Palette.paper.ignoresSafeArea(edges: .top))
        }
        .overlay(alignment: .leading) { edgeSwipeArea }
        .offset(x: swipe)
        .shadow(color: Palette.ink.opacity(swipe > 0 ? 0.12 : 0), radius: 10, x: -4)
    }

    /// ‹ せってい ・ バックアップ（日の詳細の .dNav と同じ）
    private var nav: some View {
        HStack(spacing: 8) {
            Button(L("‹ せってい")) { store.showBackup = false }
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(L("バックアップ")).font(.ui(16, .black)).foregroundStyle(Palette.ink)
            Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
        }
        .font(.ui(15, .black))
        .foregroundStyle(Palette.rose)
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .padding(.top, 6).padding(.bottom, 10)
    }

    /// 状態を1行で伝える。うまくいかなかった理由もここに出す
    private var statusText: String {
        switch backup.status {
        case .syncing:
            return L("バックアップ中…")
        case .failure(let message):
            return L(message)
        case .idle, .success:
            if !backup.isEnabled { return L("オンにすると、記録を自動で預けます") }
            if let at = backup.lastSyncedAt { return LF("最終バックアップ: %@", Self.dateText(at)) }
            return L("バックアップを待っています")
        }
    }

    /// 日時は、アプリの表示言語に合わせた書き方にする
    private static func dateText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: LanguageOverride.isJapanese ? "ja_JP" : "en_US")
        f.setLocalizedDateFormatFromTemplate("yMMMdHm")
        return f.string(from: date)
    }

    /// iCloud にサインインしていないとき
    private var unavailableNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("!").font(.num(20)).foregroundStyle(Color(hex: 0xE0A02A))
            Text(L("この端末ではiCloudが使えません。iPhoneの設定からiCloudにサインインしてください。"))
                .font(.ui(13))
                .foregroundStyle(Palette.ink)
                .lineHeight(1.6, size: 13)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 14).padding(.horizontal, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: 0xFFF3D9)))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Palette.gold, lineWidth: 2))
    }

    /// 左端から右へ引っぱるともどる（日の詳細と同じ）
    private var edgeSwipeArea: some View {
        GeometryReader { geo in
            Color.clear
                .frame(width: 20)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10, coordinateSpace: .global)
                        .onChanged { v in swipe = max(0, v.translation.width) }
                        .onEnded { v in
                            if v.translation.width > geo.size.width * 0.35 || v.predictedEndTranslation.width > geo.size.width * 0.6 {
                                store.showBackup = false
                            } else {
                                withAnimation(.slide) { swipe = 0 }
                            }
                        }
                )
        }
        .frame(width: 20)
        .ignoresSafeArea()
    }
}
