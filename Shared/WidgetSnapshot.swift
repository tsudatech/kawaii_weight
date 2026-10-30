//
//  WidgetSnapshot.swift
//  kawaii_taiju_kanri
//
//  アプリが書き出し、ウィジェットが読む「いまの状態」。App Group の共有フォルダに置く。
//

import Foundation

struct WidgetSnapshot: Codable {
    /// 書き出した日（この日の 0:00）
    var day: Date
    var characterName: String
    /// 書き出した日のキャラの表情とセリフ
    var mood: Mood
    var line: String?
    /// いちばん新しい記録の日
    var lastRecordDay: Date?
    var latestWeight: Double?
    /// きょうの増減（記録した日だけ）
    var diff: Double?
    var streak: Int
    /// 直近7日の体重（グラフ用）
    var recentWeights: [Double]

    static let appGroup = "group.jp.jntech.kawaii-taiju-kanri"
    static let widgetKind = "KawaiiWeightWidget"

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("widget.json")
    }

    static func load() -> WidgetSnapshot? {
        guard let url = fileURL, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    func save() {
        guard let url = Self.fileURL, let data = try? JSONEncoder().encode(self) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - 表示する日の状態（書き出した日から日付が変わっていても正しく見せる）

    func isRecorded(on today: Date) -> Bool { lastRecordDay == today }

    func moodAndLine(on today: Date) -> (mood: Mood, line: String?) {
        if day == today { return (mood, line) }
        guard let last = lastRecordDay else { return (.cheer, L("はじめまして！まずは、いまの体重を教えてね")) }
        let gap = last.days(to: today)
        if gap >= 3 { return (.lonely, LF("%d日もどこ行ってたの…さみしかったよぉ", gap)) }
        return (.sleepy, nil)
    }

    func streak(on today: Date) -> Int {
        guard let last = lastRecordDay else { return 0 }
        // 記録がきのうまでなら連続はまだ続いている
        return last.days(to: today) <= 1 ? streak : 0
    }

    func diff(on today: Date) -> Double? { isRecorded(on: today) ? diff : nil }

    static let placeholder = WidgetSnapshot(
        day: .today, characterName: "", mood: .good, line: L("いい感じ！"),
        lastRecordDay: .today, latestWeight: 57.8, diff: -0.2, streak: 12,
        recentWeights: [58.4, 58.3, 58.5, 58.1, 58.0, 58.0, 57.8]
    )
}
