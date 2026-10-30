//
//  Reminder.swift
//  kawaii_taiju_kanri
//
//  毎日の「はかってね」通知（時刻は せってい で決める）。
//  くり返し通知だとセリフを変えられないので、先の60日ぶんを1日ずつ予約し、アプリを開くたびに予約しなおす。
//

import Foundation
import UserNotifications

enum Reminder {
    private static let prefix = "remind-"
    /// iOS が1アプリに予約させてくれるのは64件まで。アプリを開かない日が続いても、2か月ほどは届くように
    private static let daysAhead = 60
    private static var center: UNUserNotificationCenter { .current() }

    /// 通知の許可をたずねる（すでに決まっていればダイアログは出ない）
    static func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    static func isAuthorized() async -> Bool {
        let s = await center.notificationSettings().authorizationStatus
        return s == .authorized || s == .provisional || s == .ephemeral
    }

    /// 予約をすべて入れなおす
    static func reschedule(settings: AppSettings, characterName: String, lastRecordDay: Date?) async {
        let pending = await center.pendingNotificationRequests().map(\.identifier).filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: pending)
        guard settings.remind, await isAuthorized() else { return }

        let time = Calendar.app.dateComponents([.hour, .minute], from: settings.remindTime)
        let name = displayName(characterName)
        let today = Date.today

        for i in 0..<daysAhead {
            let day = today.adding(days: i)
            // きょうもう記録していたら、きょうの分は送らない
            if day == lastRecordDay { continue }
            var c = Calendar.app.dateComponents([.year, .month, .day], from: day)
            c.hour = time.hour
            c.minute = time.minute
            guard let fire = Calendar.app.date(from: c), fire > .now else { continue }

            let content = UNMutableNotificationContent()
            let gap = lastRecordDay.map { $0.days(to: day) } ?? 0
            if gap >= 3 {
                content.title = LF("%@「さみしいよぉ…」", name)
                content.body = LF("%d日もはかってないよ。ちょっとだけ体重計のってみない？", gap)
            } else {
                (content.title, content.body) = greeting(name: name, time: settings.remindTime)
            }
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: c, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: prefix + "\(i)", content: content, trigger: trigger))
        }
    }

    /// 「通知をためす」：数秒後にとどく。セリフは、せっていの時刻にとどくものと同じ
    static func sendTest(characterName: String, recordedToday: Bool, time: Date) async {
        let content = UNMutableNotificationContent()
        let name = displayName(characterName)
        if recordedToday {
            content.title = LF("%@「きょうもえらい！」", name)
            content.body = L("またあしたも、いっしょにはかろうね")
        } else {
            (content.title, content.body) = greeting(name: name, time: time)
        }
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: "test", content: content, trigger: trigger))
    }

    /// 通知の時刻に合わせたあいさつ（朝 4〜10時・昼 10〜17時・夕方から夜）
    private static func greeting(name: String, time: Date) -> (title: String, body: String) {
        let hour = Calendar.app.component(.hour, from: time)
        let at = Fmt.time(time)
        switch hour {
        case 4..<10:
            return (LF("%@「おはよ〜」", name), LF("%@だよ。体重計のってきて〜 ふぁ…", at))
        case 10..<17:
            return (LF("%@「やっほ〜」", name), LF("%@だよ。きょうの体重、はかってみよ？", at))
        default:
            return (LF("%@「おつかれさま〜」", name), LF("%@だよ。ねる前に、きょうの体重をはかってみない？", at))
        }
    }

    private static func displayName(_ name: String) -> String {
        name.isEmpty ? L("キャラ") : name
    }
}

/// アプリを開いているあいだも通知をバナーで見せる
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
