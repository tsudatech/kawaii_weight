//
//  Formatters.swift
//  kawaii_taiju_kanri
//

import Foundation

extension Calendar {
    static var app: Calendar { .current }
}

extension Date {
    var startOfDay: Date { Calendar.app.startOfDay(for: self) }

    func adding(days: Int) -> Date {
        Calendar.app.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// self から other までの日数
    func days(to other: Date) -> Int {
        Calendar.app.dateComponents([.day], from: startOfDay, to: other.startOfDay).day ?? 0
    }

    static var today: Date { Date().startOfDay }
}

enum Fmt {
    static func kg(_ v: Double) -> String { String(format: "%.1f", v) }

    /// +0.3 / −0.2 / ±0.0
    static func signed(_ v: Double) -> String {
        let s = abs(v) < 0.05 ? "±" : v > 0 ? "+" : "−"
        return s + String(format: "%.1f", abs(v))
    }

    /// 曜日（日本語は 日〜土、英語は Sun〜Sat）
    static let weekdays: [String] = LanguageOverride.isJapanese
        ? ["日", "月", "火", "水", "木", "金", "土"]
        : ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    /// カレンダーの見出し（日本語は 日〜土、英語は S M T W T F S）
    static let weekdayInitials: [String] = LanguageOverride.isJapanese
        ? weekdays
        : ["S", "M", "T", "W", "T", "F", "S"]

    private static let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    static func weekday(_ d: Date) -> String {
        weekdays[Calendar.app.component(.weekday, from: d) - 1]
    }

    /// 10月28日 / Oct 28
    static func monthDay(_ d: Date) -> String {
        let c = Calendar.app.dateComponents([.month, .day], from: d)
        let m = c.month ?? 1, day = c.day ?? 0
        return LanguageOverride.isJapanese ? "\(m)月\(day)日" : "\(months[m - 1]) \(day)"
    }

    /// 10月28日（火） / Tue, Oct 28
    static func dayTitle(_ d: Date) -> String {
        LanguageOverride.isJapanese ? "\(monthDay(d))（\(weekday(d))）" : "\(weekday(d)), \(monthDay(d))"
    }

    /// 10/28
    static func slash(_ d: Date) -> String {
        let c = Calendar.app.dateComponents([.month, .day], from: d)
        return "\(c.month ?? 0)/\(c.day ?? 0)"
    }

    /// 07:30
    static func time(_ d: Date) -> String {
        let c = Calendar.app.dateComponents([.hour, .minute], from: d)
        return String(format: "%02d:%02d", c.hour ?? 0, c.minute ?? 0)
    }
}
