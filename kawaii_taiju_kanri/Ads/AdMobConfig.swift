//
//  AdMobConfig.swift
//  kawaii_taiju_kanri
//
//  AdMob の ID をここ1か所に集める。ほかの場所で直に書かないこと。
//

import Foundation

/// Debug ビルドは Google が配っているテスト用の ID を返す。
/// 開発中に本番の広告を叩いてしまうと、誤クリックとみなされてアカウントが止められることがあるため。
enum AdMobConfig {
    /// アプリ ID。リポジトリ直下の `Info.plist` の `GADApplicationIdentifier` と必ずそろえること。
    static let applicationID = "ca-app-pub-9220331962131574~4431737933"

    /// バナー
    static var bannerAdUnitID: String {
        #if DEBUG
        "ca-app-pub-3940256099942544/2934735716"   // テスト用
        #else
        "ca-app-pub-9220331962131574/1921124665"
        #endif
    }

    /// インタースティシャル（全画面）
    static var interstitialAdUnitID: String {
        #if DEBUG
        "ca-app-pub-3940256099942544/4411468910"   // テスト用
        #else
        "ca-app-pub-9220331962131574/5805810611"
        #endif
    }
}
