//
//  AdBannerView.swift
//  kawaii_taiju_kanri
//
//  タブバーの上に出すバナー広告（かわいい日記の AdBannerView と同じ作り）。
//  端末の幅いっぱいのアダプティブバナー（かわいい日記と同じ）。広告が届くまでと、届かなかったとき（審査前・在庫なし）は
//  高さ 0 にして、空の帯が残らないようにする。
//

import GoogleMobileAds
import SwiftUI
import UIKit

struct AdBannerView: View {
    @ObservedObject private var ads = AdService.shared
    /// SDK の初期化が済むまでは 0（場所を取らない）
    @State private var height: CGFloat = 0

    /// 端末の幅いっぱいのアダプティブバナー（高さは幅で決まり、6.3インチの iPhone で 60pt ほど）。
    /// 起動中は縦向きだけなので、最初に1回決めたら変えない
    static let size: AdSize = {
        let width = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.screen.bounds.width }
            .first ?? 390
        let adaptive = currentOrientationAnchoredAdaptiveBanner(width: width)
        return adaptive.size.height >= 1 ? adaptive : AdSizeBanner
    }()

    var body: some View {
        if ads.isEnabled {
            BannerViewContainer(height: $height)
                // 広告の枠は最初から同じ大きさのまま変えない。枠の大きさを途中で変えると、SDK がそれに合わせて
                // 頼む広告の大きさまで変えてしまい（高さ 0 や 320×100 の広告になる）、表示が崩れるため
                .frame(width: AdBannerView.size.size.width, height: AdBannerView.size.size.height)
                // 届くまでは外側で高さ 0 にして、場所を取らない（審査前・在庫なしのとき）
                .frame(maxWidth: .infinity)
                .frame(height: height, alignment: .top)
                .clipped()
                // 背後をスクロールしてくる内容が透けないように地を敷く
                .background(Palette.paper)
                .onChange(of: height) { _, h in ads.bannerHeight = h }
        }
    }
}

private struct BannerViewContainer: UIViewRepresentable {
    @Binding var height: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator(height: $height) }

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdBannerView.size)
        banner.adUnitID = AdMobConfig.bannerAdUnitID
        banner.rootViewController = UIApplication.shared.topViewController()
        banner.delegate = context.coordinator
        context.coordinator.banner = banner
        // SDK の初期化（同意の確認のあと）を待ってから読み込む
        context.coordinator.observe()
        return banner
    }

    func updateUIView(_ banner: BannerView, context: Context) {}

    final class Coordinator: NSObject, BannerViewDelegate {
        private let height: Binding<CGFloat>
        weak var banner: BannerView?
        private var observer: NSObjectProtocol?

        init(height: Binding<CGFloat>) { self.height = height }

        deinit {
            if let observer { NotificationCenter.default.removeObserver(observer) }
        }

        func observe() {
            observer = NotificationCenter.default.addObserver(forName: .adMobDidInitialize, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.load() }
            }
            // すでに初期化が済んでいたら（タブを切りかえて作り直したときなど）すぐ読む
            // （作っている途中に高さを変えないよう、次の周回で）
            if ConsentManager.shared.isStarted { DispatchQueue.main.async { [weak self] in self?.load() } }
        }

        private func load() {
            guard let banner else { return }
            banner.rootViewController = UIApplication.shared.topViewController()
            banner.load(Request())
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            height.wrappedValue = AdBannerView.size.size.height
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            AdLog.error("バナー広告の読み込みに失敗", error)
            height.wrappedValue = 0
        }
    }
}
