//
//  RootView.swift
//  kawaii_taiju_kanri
//
//  4つのタブ ＋ 日の詳細・記録シート・各種オーバーレイ（重なる順番はデモの z-index と同じ）
//

import SwiftUI

extension Animation {
    /// CSS の ease
    static func cssEase(_ duration: Double) -> Animation { .timingCurve(0.25, 0.1, 0.25, 1, duration: duration) }
    /// 日の詳細・記録シートの出入り（cubic-bezier(.2,.9,.3,1)）
    static let slide = Animation.timingCurve(0.2, 0.9, 0.3, 1, duration: 0.32)
}

struct RootView: View {
    @EnvironmentObject private var store: WeightStore
    @ObservedObject private var ads = AdService.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Palette.paper.ignoresSafeArea()
                // 入力欄の外をタップしたらキーボードを閉じる
                .background(KeyboardDismissOnTapOutside().allowsHitTesting(false))

            screen
                .id(store.selectedTab)
                .transition(.asymmetric(insertion: .opacity.combined(with: .offset(y: 6)), removal: .identity))

            // 日の詳細（タブバーより下）
            if let date = store.detailDate {
                DayDetailView(date: date)
                    .transition(.move(edge: .trailing))
                    .zIndex(3)
            }

            // せってい › バックアップ（日の詳細と同じく右からすべりこむ）
            if store.showBackup {
                BackupView(backup: store.backup)
                    .transition(.move(edge: .trailing))
                    .zIndex(3)
            }
            if store.showTags {
                TagsView()
                    .transition(.move(edge: .trailing))
                    .zIndex(3)
            }

            TabBar()
                .zIndex(4)

            // 記録シート
            if store.editing != nil {
                Color(hex: 0x2B1C12).opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { store.editing = nil }
                    .transition(.opacity.animation(.cssEase(0.25)))
                    .zIndex(10)
            }
            if let target = store.editing {
                RecordSheet(date: target.date)
                    .transition(.move(edge: .bottom))
                    .zIndex(11)
            }

            // シェアカード
            if store.sharingDate != nil {
                Color(hex: 0x2B1C12).opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { store.sharingDate = nil }
                    .transition(.opacity.animation(.cssEase(0.25)))
                    .zIndex(10)
            }
            if let date = store.sharingDate {
                ShareSheet(date: date)
                    .transition(.move(edge: .bottom))
                    .zIndex(11)
            }

            if store.showWidgetPreview {
                WidgetPreviewView()
                    .transition(.opacity.combined(with: .scale(scale: 1.06)))
                    .zIndex(12)
            }
            if store.showLockPreview {
                LockPreviewView()
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
                    .zIndex(12)
            }
            if store.showSiriPreview {
                SiriPreviewView()
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
                    .zIndex(12)
            }
            if store.showOnboarding {
                OnboardingView()
                    .transition(.opacity)
                    .zIndex(13)
            }
            if let badge = store.celebrating {
                RewardOverlay(badge: badge)
                    .id(badge.id)
                    .transition(.opacity)
                    .zIndex(14)
            }
            // もやもやがはれたときの紙ふぶき（押せるものをふさがない）
            if let key = store.confettiKey, !reduceMotion {
                ConfettiView()
                    .id(key)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                    .zIndex(15)
            }
        }
        // はじめての案内（コーチマーク）。部品の位置は .coachTarget(_:) の印から
        .overlayPreferenceValue(CoachTargetKey.self) { anchors in
            GeometryReader { geo in
                if let tour = store.coach {
                    CoachMarkOverlay(
                        tour: tour,
                        rects: anchors.mapValues { geo[$0] },
                        bandBottom: geo.size.height - 54 - ads.bannerHeight - 8
                    ) {
                        Onboarding.markSeen(tour.kind)
                        store.coach = nil
                    }
                    .transition(.opacity)
                }
            }
            .animation(.cssEase(0.25), value: store.coach)
        }
        .overlay(alignment: .top) {
            if let message = store.toast {
                ToastView(message: message)
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .offset(y: -20)))
                    .allowsHitTesting(false)
            }
        }
        .animation(.cssEase(0.25), value: store.selectedTab)
        .animation(.slide, value: store.detailDate)
        .animation(.slide, value: store.showBackup)
        .animation(.slide, value: store.showTags)
        .animation(.slide, value: store.editing)
        .animation(.slide, value: store.sharingDate)
        .animation(.cssEase(0.3), value: store.showLockPreview)
        .animation(.cssEase(0.3), value: store.showSiriPreview)
        .animation(.cssEase(0.3), value: store.showOnboarding)
        .animation(.cssEase(0.3), value: store.showWidgetPreview)
        .animation(.cssEase(0.3), value: store.celebrating)
        .onAppear {
            #if DEBUG
            PreviewTour.prepare(store)
            #endif
            if !store.onboarded { store.showOnboarding = true }
        }
        #if DEBUG
        .task { await PreviewTour.run(store) }
        #endif
        // 広告の同意の確認（UMP・ATT）と SDK の初期化は、はじめの設定とホームの案内が済んでから1回だけ
        .task(id: canStartAds) {
            if canStartAds { AdService.shared.start() }
        }
        // タブを開いたとき（はじめの設定や、ほかの画面が閉じたあと）に、まだ見ていない案内を出す
        .task(id: coachTrigger) {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, canShowCoach else { return }
            let kind = store.selectedTab.coachKind
            guard Onboarding.needs(kind) else { return }
            store.coach = CoachTour(kind: kind, pages: Self.coachPages[kind] ?? [])
        }
    }

    // MARK: - はじめての案内

    private var canStartAds: Bool {
        store.onboarded && !store.showOnboarding && store.coach == nil && !Onboarding.needs(.home)
    }

    /// これが変わるたびに、案内を出せるか見なおす
    private var coachTrigger: String {
        "\(store.selectedTab)-\(canShowCoach)"
    }

    /// ほかの画面やお祝いが出ていないときだけ
    private var canShowCoach: Bool {
        store.onboarded && !store.showOnboarding && store.editing == nil && store.detailDate == nil
            && store.celebrating == nil && !store.showWidgetPreview && !store.showBackup && !store.showTags && store.coach == nil
            && store.sharingDate == nil && !store.showLockPreview && !store.showSiriPreview
    }

    /// 各タブの案内。画面に見えていない部品のページは飛ばす
    private static var coachPages: [Onboarding.Kind: [CoachPage]] {
        [
            .home: [
                CoachPage(target: "home.hero", text: L("体重の変化に合わせて、キャラの表情が変わるよ。タップするとおしゃべりするよ。")),
                CoachPage(target: "home.record", text: L("毎朝ここに体重を入れて「きろくする」をおしてね。タグで、その日のことも残せるよ。")),
                CoachPage(target: "home.streak", text: L("毎日つづけると、ここの日数がふえていくよ。"), radius: nil),
                CoachPage(target: "tabbar", text: L("グラフ・キャラ・せっていは、ここから見られるよ。"), radius: 0),
            ],
            .graph: [
                CoachPage(target: "graph.chart", text: L("1週・1か月・3か月で、体重のうつりかわりを見られるよ。グレーの線は7日平均だよ。")),
                CoachPage(target: "graph.stats", text: L("期間の平均や、いちばん軽い日・重い日がひとめでわかるよ。"), radius: 22),
            ],
            .chara: [
                CoachPage(target: "chara.room", text: L("キャラに名前をつけてあげてね。タップするとおしゃべりするよ。")),
                CoachPage(target: "chara.level", text: L("毎日きろくすると、なかよし度が上がっていくよ。")),
            ],
            .settings: [
                CoachPage(target: "settings.body", text: L("身長ともくひょう体重は、ここでいつでも変えられるよ。"), radius: 22),
                CoachPage(target: "settings.judge", text: L("キャラが表情を決めるときの、くらべかたを変えられるよ。"), radius: 22),
            ],
        ]
    }

    @ViewBuilder
    private var screen: some View {
        switch store.selectedTab {
        case .home: HomeView()
        case .graph: GraphView()
        case .chara: CharaView()
        case .settings: SettingsView()
        }
    }
}

// MARK: - タブバー（.tabbar）

struct TabBar: View {
    @EnvironmentObject private var store: WeightStore

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            // 広告はタブバーの上。届かなければ高さ 0 になって消える（審査が通るまでは出ない）
            AdBannerView()
            HStack(spacing: 0) {
                item(.home, L("ホーム"), TabIcon.home)
                item(.graph, L("グラフ"), TabIcon.graph)
                item(.chara, L("キャラ"), TabIcon.chara)
                item(.settings, L("せってい"), TabIcon.settings)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .frame(height: 54, alignment: .top)
            .coachTarget("tabbar")
            .background {
                Rectangle()
                    .fill(Palette.paper.opacity(0.92))
                    .background(.ultraThinMaterial)
                    .overlay(alignment: .top) { Rectangle().fill(Palette.line).frame(height: 1.5) }
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    private func item(_ tab: AppTab, _ label: String, _ icon: TabIcon) -> some View {
        let on = store.selectedTab == tab
        return Button {
            let switched = store.selectedTab != tab
            store.detailDate = nil
            store.showBackup = false
            store.showTags = false
            store.selectedTab = tab
            // 何回か記録したあとの、つぎのタブ切りかえで全画面広告。いま開いているタブを押しなおしたときは出さない。
            // お祝い（出る直前も）・シート・案内と重なるとき、切りかえた先でこれから案内が出るときは見送る
            guard switched else { return }
            let busy = store.celebrating != nil || store.celebrationPending || store.editing != nil || store.sharingDate != nil
                || store.coach != nil || Onboarding.needs(tab.coachKind)
            AdService.shared.showInterstitialIfDue(isBusy: busy)
        } label: {
            VStack(spacing: 2) {
                icon.stroke(style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                    .frame(width: 26, height: 26)
                Text(label).font(.ui(10))
            }
            .foregroundStyle(on ? Palette.ink : Palette.inkFaint)
            .frame(width: 64, height: 48, alignment: .top)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

/// タブのアイコン（デモの SVG と同じ線。viewBox 24×24）
struct TabIcon: Shape {
    let draw: @Sendable (inout Path) -> Void

    nonisolated func path(in rect: CGRect) -> Path {
        var p = Path()
        draw(&p)
        return p.applying(CGAffineTransform(translationX: rect.minX, y: rect.minY).scaledBy(x: rect.width / 24, y: rect.height / 24))
    }

    static let home = TabIcon { p in
        p.move(to: CGPoint(x: 3, y: 11.5)); p.addLine(to: CGPoint(x: 12, y: 4)); p.addLine(to: CGPoint(x: 21, y: 11.5))
        p.move(to: CGPoint(x: 5.5, y: 10)); p.addLine(to: CGPoint(x: 5.5, y: 19.5)); p.addLine(to: CGPoint(x: 18.5, y: 19.5)); p.addLine(to: CGPoint(x: 18.5, y: 10))
    }
    static let graph = TabIcon { p in
        p.move(to: CGPoint(x: 4, y: 19)); p.addLine(to: CGPoint(x: 9, y: 12)); p.addLine(to: CGPoint(x: 13, y: 15)); p.addLine(to: CGPoint(x: 20, y: 6))
    }
    static let chara = TabIcon { p in
        p.addEllipse(in: CGRect(x: 8, y: 5, width: 8, height: 8))
        p.move(to: CGPoint(x: 4.5, y: 20))
        p.addCurve(to: CGPoint(x: 12, y: 15), control1: CGPoint(x: 6, y: 16.5), control2: CGPoint(x: 8.8, y: 15))
        p.addCurve(to: CGPoint(x: 19.5, y: 20), control1: CGPoint(x: 15.2, y: 15), control2: CGPoint(x: 18, y: 16.5))
    }
    static let settings = TabIcon { p in
        p.addEllipse(in: CGRect(x: 9, y: 9, width: 6, height: 6))
        let spokes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (12, 3, 12, 5.5), (12, 18.5, 12, 21), (3, 12, 5.5, 12), (18.5, 12, 21, 12),
            (5.6, 5.6, 7.4, 7.4), (16.6, 16.6, 18.4, 18.4), (5.6, 18.4, 7.4, 16.6), (16.6, 7.4, 18.4, 5.6),
        ]
        for (x1, y1, x2, y2) in spokes {
            p.move(to: CGPoint(x: x1, y: y1)); p.addLine(to: CGPoint(x: x2, y: y2))
        }
    }
}
