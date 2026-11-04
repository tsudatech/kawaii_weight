//
//  WeightStore.swift
//  kawaii_taiju_kanri
//
//  アプリ全体の状態。記録・設定はファイルに保存し、変わるたびにウィジェットと通知の予約も更新する。
//

import Combine
import SwiftUI
import UserNotifications
import WidgetKit

enum AppTab: Hashable {
    case home, graph, chara, settings
}

final class WeightStore: ObservableObject {
    /// 画面と App Intents（Siri・ショートカット）で同じものを使う
    static let shared = WeightStore()

    // MARK: - データ（変わったら保存する）
    @Published var entries: [Date: WeightEntry] = [:] {
        didSet {
            watchesCache = nil
            stampEntries(from: oldValue)
            scheduleSave()
        }
    }
    @Published var settings = AppSettings() { didSet { scheduleSave() } }
    @Published var characterName = "" {
        didSet {
            if !applyingBackup && characterName != oldValue { nameUpdatedAt = Self.stamp() }
            scheduleSave()
        }
    }
    @Published var earnedBadges: [String] = [] { didSet { scheduleSave() } }
    @Published var onboarded = false { didSet { scheduleSave() } }
    /// ごほうびの日の印（日 → 印）
    @Published private(set) var treats: [Date: TreatMark] = [:] {
        didSet {
            watchesCache = nil
            scheduleSave()
        }
    }
    /// 記録の前にしたよそう
    @Published private(set) var pendingGuess: PendingGuess? { didSet { scheduleSave() } }

    // MARK: - 画面の状態
    @Published var selectedTab: AppTab = .home
    @Published var editing: SheetTarget?
    @Published var celebrating: Badge?
    /// お祝いを出す直前（記録から 0.7 秒のあいだ）。このあいだは全画面広告を出さない
    var celebrationPending: Bool { pendingCelebrations > 0 }
    /// 出る直前のお祝いの数（つづけて記録して重なっても、最後のが出るまで数える）
    private var pendingCelebrations = 0
    @Published var toast: String?
    @Published var showOnboarding = false
    @Published var showWidgetPreview = false
    /// せってい › ロック画面ウィジェット・Siri のプレビュー
    @Published var showLockPreview = false
    @Published var showSiriPreview = false
    /// シェアカードを作る日
    @Published var sharingDate: Date?
    /// ホームのキャラがその場で返すひとこと
    @Published var heroSay: HeroSay?
    /// もやもやがはれたときの紙ふぶき（変わるたびに出す）
    @Published var confettiKey: Int?
    /// せってい › バックアップ
    @Published var showBackup = false
    /// せってい › タグ
    @Published var showTags = false
    /// 「3日ぶりに開いた」状態を再現する（デバッグ用）
    @Published var simulateAbsent = false
    /// 日の詳細（カレンダー・りれきから開く）
    @Published var detailDate: Date?
    @Published var detailFrom = L("もどる")
    /// グラフの期間・カレンダーの月（タブを切りかえても残す）
    @Published var graphRange = 30
    @Published var calendarOffset = 0
    /// おへやのキャラ（ずかんでえらんだ顔。nil ならきょうの状態の顔）
    @Published var roomMood: Mood?
    /// ホームのキャラを跳ねさせる（記録したとき。悲しい顔なら左右にゆれる）
    @Published var homeBounce = 0
    /// いま出しているはじめての案内（コーチマーク）
    @Published var coach: CoachTour?

    private var toastTask: Task<Void, Never>?

    // MARK: - iCloud バックアップ
    let backup = ICloudBackup()
    /// 消した記録の印（日 → 消した時刻）
    private var deleted: [Date: Date] = [:]
    private var nameUpdatedAt: Date?
    /// iCloud から届いた記録を入れている間は、書きかえた時刻を付けなおさない
    private var applyingBackup = false
    private var saveTask: Task<Void, Never>?
    private var watchesCache: (day: Date, value: (done: [WatchRecord], active: WatchRecord?))?

    init() {
        // @Published の didSet は init の中でも呼ばれるので、読みこんだ記録に書きかえた時刻を付けないようにする
        applyingBackup = true
        if let saved = Persistence.load() {
            entries = Dictionary(saved.entries.map { ($0.date.startOfDay, $0) }, uniquingKeysWith: { $1 })
            settings = saved.settings
            characterName = saved.characterName
            earnedBadges = saved.earnedBadges
            onboarded = saved.onboarded
            deleted = Dictionary(saved.deleted.map { ($0.date, $0.deletedAt) }, uniquingKeysWith: { max($0, $1) })
            nameUpdatedAt = saved.nameUpdatedAt
            treats = Dictionary(saved.treats.map { ($0.date, $0) }, uniquingKeysWith: { $0.updatedAt >= $1.updatedAt ? $0 : $1 })
            pendingGuess = saved.pendingGuess
        }
        applyingBackup = false
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        backup.owner = self
        if !isScratch { backup.start() }
    }

    // MARK: - 日の詳細

    /// 記録がある日は日の詳細を、ない日は入力シートを開く
    func openDay(_ date: Date, from: String) {
        guard entries[date] != nil else {
            editing = SheetTarget(date: date)
            return
        }
        detailFrom = from
        detailDate = date
    }

    // MARK: - 保存・ウィジェット・通知

    private var savedData: SavedData {
        SavedData(
            entries: sortedDates.compactMap { entries[$0] },
            settings: settings,
            characterName: characterName,
            earnedBadges: earnedBadges,
            onboarded: onboarded,
            deleted: deletedList,
            nameUpdatedAt: nameUpdatedAt,
            treats: treatList,
            pendingGuess: pendingGuess
        )
    }

    private var treatList: [TreatMark] {
        treats.values.sorted { $0.date < $1.date }
    }

    private var deletedList: [DeletedEntry] {
        deleted.map { DeletedEntry(date: $0.key, deletedAt: $0.value) }.sorted { $0.date < $1.date }
    }

    /// 書きかえた時刻。秒で切りそろえる（保存ファイルの ISO 8601 と iCloud の値が同じになるように）
    private static func stamp() -> Date {
        Date(timeIntervalSince1970: Date().timeIntervalSince1970.rounded(.down))
    }

    /// 記録が変わったら、その日に書きかえた時刻を付け、消した日は印を残す
    private func stampEntries(from old: [Date: WeightEntry]) {
        guard !applyingBackup else { return }
        let now = Self.stamp()
        for (date, e) in entries where old[date] != e {
            entries[date]?.updatedAt = now
            deleted[date] = nil
        }
        for date in old.keys where entries[date] == nil {
            deleted[date] = now
        }
    }

    /// iCloud に預ける中身
    var backupData: BackupData {
        BackupData(
            entries: sortedDates.compactMap { entries[$0] },
            deleted: deletedList,
            earnedBadges: Badge.all.map(\.id).filter { earnedBadges.contains($0) },
            characterName: characterName,
            nameUpdatedAt: nameUpdatedAt,
            treats: treatList
        )
    }

    /// iCloud と合わせた結果を入れる
    func applyBackup(_ data: BackupData) {
        applyingBackup = true
        defer { applyingBackup = false }
        entries = Dictionary(data.entries.map { ($0.date.startOfDay, $0) }, uniquingKeysWith: { $1 })
        deleted = Dictionary(data.deleted.map { ($0.date, $0.deletedAt) }, uniquingKeysWith: { max($0, $1) })
        earnedBadges = data.earnedBadges
        characterName = data.characterName
        nameUpdatedAt = data.nameUpdatedAt
        treats = Dictionary(data.treats.map { ($0.date, $0) }, uniquingKeysWith: { $0.updatedAt >= $1.updatedAt ? $0 : $1 })
        roomMood = nil
    }

    /// 連続した変更をまとめて保存する
    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            saveNow()
        }
    }

    /// バックグラウンドに移るときなど、すぐに保存する
    func saveNow() {
        saveTask?.cancel()
        // プレビュー動画の自動の流れでは、見本の記録を保存も同期もしない（本物の記録を守る）
        guard !isScratch else { return }
        Persistence.save(savedData)
        refreshOutside()
        backup.noteLocalChange()
    }

    /// アプリが前面に来たとき（日付が変わっているかもしれない）
    func didBecomeActive() {
        objectWillChange.send()
        // ロック画面・コントロールセンターの「体重をきろく」から開いたら、ホームの入力へ
        if WidgetSnapshot.consumeOpenRecord() { goToRecord() }
        guard !isScratch else { return }
        refreshOutside()
        syncRemindWithPermission()
    }

    /// 通知の許可がない（設定アプリで切られた・まだたずねていない）のに、せっていでオンになっていたら切る。
    /// 「オンなのに届かない」状態を見せないため
    private func syncRemindWithPermission() {
        guard settings.remind else { return }
        Task {
            if await !Reminder.isAuthorized() { settings.remind = false }
        }
    }

    /// ホームの体重入力を見せる（ほかの画面は閉じる）
    private func goToRecord() {
        detailDate = nil
        showBackup = false
        showTags = false
        showWidgetPreview = false
        showLockPreview = false
        showSiriPreview = false
        sharingDate = nil
        selectedTab = .home
    }

    /// ウィジェットと通知の予約を、いまの記録に合わせる
    private func refreshOutside() {
        let ts = todayState
        WidgetSnapshot(
            day: .today,
            characterName: characterName,
            mood: ts.mood,
            line: ts.line,
            lastRecordDay: sortedDates.last,
            latestWeight: latestWeight,
            diff: judge(.today)?.diff,
            streak: streak,
            recentWeights: points(lastDays: 7).map(\.weight),
            average7: recentAverage,
            goalPct: goalInfo().map { max(0, min(100, $0.pct)) },
            hideNumbers: settings.hideNumbers
        ).save()
        WidgetCenter.shared.reloadAllTimelines()

        let settings = settings, name = characterName, last = sortedDates.last
        Task { await Reminder.reschedule(settings: settings, characterName: name, lastRecordDay: last) }
    }

    // MARK: - 通知の設定

    /// 「毎朝はかってね通知」のオン・オフ。オンにするときは許可をたずねる
    func setRemind(_ on: Bool) {
        settings.remind = on
        guard on else { return }
        Task {
            if await Reminder.requestAuthorization() { return }
            settings.remind = false
            showToast(L("設定アプリで通知をオンにしてね"))
        }
    }

    func sendTestNotification() {
        let name = characterName, recorded = isTodayRecorded, time = settings.remindTime
        Task {
            guard await Reminder.requestAuthorization() else {
                showToast(L("設定アプリで通知をオンにしてね"))
                return
            }
            await Reminder.sendTest(characterName: name, recordedToday: recorded, time: time)
            showToast(L("3びょう後にとどくよ"))
        }
    }

    // MARK: - CSV

    var csvExport: CSVExport {
        CSVExport(entries: Array(entries.values)) { mood(for: $0) }
    }

    // MARK: - データの削除

    /// すべての記録と設定を消して、はじめの設定からやりなおす
    func resetAll() {
        entries = [:]
        settings = AppSettings()
        characterName = ""
        earnedBadges = []
        // ほかの端末の分も消えるよう、消さずに「とりけし」の印にする
        let now = Self.stamp()
        treats = treats.mapValues { TreatMark(date: $0.date, on: false, updatedAt: now) }
        pendingGuess = nil
        // iCloud に預けた分も消す（消した印つきで書きなおすので、ほかの端末の記録も消える）
        backup.replaceRemote()
        simulateAbsent = false
        onboarded = false
        selectedTab = .home
        showOnboarding = true
        // 各タブの案内も、はじめから見せなおす
        Onboarding.setAllSeen(false)
    }

    // MARK: - サンプルデータ（デバッグ用）

    #if DEBUG
    /// 約3か月分のサンプルで記録を置きかえる（ゆるやかに減少・たまに抜けの日あり・今日は未記録）
    func loadSample() {
        // サンプルが iCloud に届いて、ほかの端末の本物の記録を消したり置きかえたりしないよう、先にバックアップを切る
        backup.setEnabled(false)
        var result: [Date: WeightEntry] = [:]
        var w = 60.4
        var seed = 7.0
        func rnd() -> Double {
            seed = (seed * 16807).truncatingRemainder(dividingBy: 2147483647)
            return seed / 2147483647
        }
        let skip: Set<Int> = [77, 63, 52, 41, 33]
        let tagged: [Int: ([String], String?)] = [
            3: (["飲み会"], L("友だちと焼肉")), 2: (["外食"], nil), 6: (["運動した"], L("30分ウォーキング")),
            9: (["運動した"], nil), 12: (["のんびり"], nil), 13: (["のんびり"], nil), 16: (["運動した"], nil),
            25: (["外食"], L("ラーメン")), 19: (["寝不足"], nil),
        ]
        for i in stride(from: 89, through: 1, by: -1) {
            w += -0.06 + (rnd() - 0.5) * 0.7
            if i == 3 || i == 2 { w += 0.35 }
            if i == 13 || i == 12 { w += 0.25 }
            if i == 48 { w += 0.6 }     // ごほうびの日の翌朝
            if i == 46 { w -= 0.5 }
            if skip.contains(i) { continue }
            let d = Date.today.adding(days: -i)
            let weight = (w * 10).rounded() / 10
            let fat = ((w * 0.48 + (rnd() - 0.5) * 0.6) * 10).rounded() / 10
            let t = tagged[i]
            result[d] = WeightEntry(date: d, weight: weight, fat: fat, tags: t?.0 ?? [], memo: t?.1)
        }
        // 体重よそう：直近40日のうち、ときどき予想している（6割くらい的中）
        let days = result.keys.sorted()
        for (n, d) in days.enumerated() where n > 0 && d.days(to: .today) <= 40 && rnd() >= 0.15 {
            let actual = Self.actual(from: result[days[n - 1]]?.weight ?? 0, to: result[d]?.weight ?? 0)
            let others = WeightGuess.allCases.filter { $0 != actual }
            result[d]?.guess = rnd() < 0.62 ? actual : others[rnd() < 0.5 ? 0 : 1]
            result[d]?.bot = Self.botPattern(d)
        }
        // 置きかえた本物の記録を「消した」扱いにしない（あとでバックアップをオンにしたとき、ほかの端末から消さないように）
        applyingBackup = true
        entries = result
        deleted = [:]
        applyingBackup = false
        // 49日前に「ごほうびの日」をせんげんしていた
        let treatDay = Date.today.adding(days: -49)
        treats = [treatDay: TreatMark(date: treatDay, on: true, updatedAt: Self.stamp())]
        onboarded = true
        simulateAbsent = false
        earnedBadges = computeBadges()
    }
    #endif

    /// その起動のあいだだけの、保存しない状態か（プレビュー動画の自動の流れ・デバッグビルドのみ）
    private var isScratch: Bool {
        #if DEBUG
        PreviewTour.isOn
        #else
        false
        #endif
    }

    // MARK: - 参照

    var sortedDates: [Date] { entries.keys.sorted() }
    var todayEntry: WeightEntry? { entries[.today] }
    var isTodayRecorded: Bool { todayEntry != nil }
    var latestWeight: Double? { sortedDates.last.flatMap { entries[$0]?.weight } }
    var lastWeightOrDefault: Double { latestWeight ?? 58 }

    var streak: Int {
        if simulateAbsent { return 0 }
        var d = isTodayRecorded ? Date.today : Date.today.adding(days: -1)
        var s = 0
        while entries[d] != nil {
            s += 1
            d = d.adding(days: -1)
        }
        return s
    }

    /// その日より前・7日以内の平均（ホームの「7日平均」・表情の判定・グラフの灰色の線で共通）
    func average7(before date: Date) -> Double? {
        let ws = sortedDates.filter { $0 < date && $0.days(to: date) <= 7 }.compactMap { entries[$0]?.weight }
        return ws.isEmpty ? nil : ws.reduce(0, +) / Double(ws.count)
    }

    /// 直近7日（きょうをふくむ）の平均。ウィジェット・ロック画面の「7日平均」
    var recentAverage: Double? {
        let ws = points(lastDays: 7).map(\.weight)
        return ws.isEmpty ? nil : ws.reduce(0, +) / Double(ws.count)
    }

    var absentDays: Int {
        if simulateAbsent { return 3 }
        guard let last = sortedDates.last, !isTodayRecorded else { return 0 }
        let g = last.days(to: .today)
        return g >= 3 ? g : 0
    }

    // MARK: - 表情判定（デモの judge() を移植）

    func judge(_ date: Date) -> Judgement? {
        let ds = sortedDates
        guard let i = ds.firstIndex(of: date), let entry = entries[date] else { return nil }
        let w = entry.weight
        let weight: (Date) -> Double = { self.entries[$0]?.weight ?? 0 }
        let trend = settings.judge == .trend

        var base: Double?
        if trend {
            let prev = ds[..<i].filter { $0.days(to: date) <= 7 }
            if !prev.isEmpty { base = prev.map(weight).reduce(0, +) / Double(prev.count) }
        } else if i > 0 {
            base = weight(ds[i - 1])
        }
        let diff = base.map { ((w - $0) * 10).rounded() / 10 }

        var mood: Mood
        var line: String?
        if i == 0 {
            mood = .happy
            line = L("はじめてのきろく、ありがとう！ここがスタートだよ")
        } else if w <= settings.goal {
            mood = .good
        } else if let diff {
            let risingThreeDays = i >= 3 && (0...2).allSatisfy { weight(ds[i - $0]) > weight(ds[i - $0 - 1]) }
            if !trend && risingThreeDays {
                mood = .angry
            } else if trend && diff >= 1.0 {
                mood = .angry
            } else if diff <= -0.8 {
                mood = .surprise
            } else if diff < 0, let minBefore = ds[..<i].map(weight).min(), w < minBefore {
                mood = .doya
            } else {
                let cry = settings.strict ? 0.3 : 0.5
                mood = diff <= -0.3 ? .happy : diff < -0.1 ? .good : diff <= 0.1 ? .hmm : diff < cry ? .trouble : .crying
            }
        } else {
            mood = .hmm
        }

        if let diff, diff > 0.1, let r = DayTag.reactions.first(where: { entry.tags.contains($0.tag) }) {
            mood = r.mood
            line = r.line
        }
        if line == nil, entry.tags.contains("運動した") {
            line = (diff ?? 0) < 0 ? L("運動したから減ったね！えらい！") : L("運動したんだね、えらい！")
        }
        // ごほうびの日とその翌朝は、増えてもおちこまない
        if let diff, diff > 0.1, treatHit(date) {
            mood = .cozy
            line = L("ごほうびの日、たのしかった？もどるまで見守るね")
        }
        // もやもやがはれた日は、どの画面でも同じ顔でよろこぶ（ホーム・きぶん・カレンダー・シェアカード）
        if let cleared = watches.done.first(where: { $0.end == date }) {
            mood = .happy
            line = LF("もやもや、はれたよ！%@でもとにもどったね", LF("%d日", cleared.days))
        }
        return Judgement(mood: mood, diff: diff, line: line, base: base)
    }

    func dayFace(_ date: Date) -> DayFace? {
        guard let j = judge(date) else { return nil }
        if let f = entries[date]?.face, f != j.mood {
            return DayFace(mood: f, line: f.faceReply, auto: j.mood, picked: true)
        }
        return DayFace(mood: j.mood, line: j.line, auto: j.mood, picked: false)
    }

    func mood(for date: Date) -> Mood {
        entries[date]?.face ?? judge(date)?.mood ?? .sleepy
    }

    /// ホーム・おへやのキャラの状態
    var todayState: (mood: Mood, line: String?) {
        if entries.isEmpty { return (.cheer, L("はじめまして！まずは、いまの体重を教えてね")) }
        let gap = absentDays
        if gap > 0 { return (.lonely, LF("%d日もどこ行ってたの…さみしかったよぉ", gap)) }
        if let f = dayFace(.today) {
            guard !f.picked else { return (f.mood, f.line) }
            if clearedWatchToday != nil { return (f.mood, f.line) }
            if settings.game, let g = guessResult(.today) {
                if g.hit && f.mood.isSad { return (f.mood, L("ふえたけど、よそうはあたり！さすがだね")) }
                if g.hit && !g.botHit { return (f.mood, L("よそうでぼくに勝ったね！くやし〜")) }
            }
            return (f.mood, f.line)
        }
        if settings.game {
            if let g = todayPendingGuess {
                return (.sleepy, LF("「%@」によそうしたね", g.guess.label))
            }
            return (.sleepy, L("ふえた？へった？はかる前によそうしてみて"))
        }
        return (.sleepy, nil)
    }

    // MARK: - もくひょう

    func goalInfo(previewPct: Double? = nil) -> GoalInfo? {
        let ds = sortedDates
        guard let first = ds.first, let last = ds.last,
              let start = entries[first]?.weight, var latest = entries[last]?.weight else { return nil }
        let goal = settings.goal
        let span = start - goal
        if let previewPct { latest = start - span * previewPct / 100 }
        let pct = span > 0 ? (start - latest) / span * 100 : (latest <= goal ? 100 : 0)

        let rec = ds.filter { $0.days(to: .today) < 30 }
        var slope = 0.0
        if rec.count >= 5 {
            let xs = rec.map { Double(-$0.days(to: .today)) }
            let ys = rec.compactMap { entries[$0]?.weight }
            let mx = xs.reduce(0, +) / Double(xs.count)
            let my = ys.reduce(0, +) / Double(ys.count)
            let num = zip(xs, ys).reduce(0) { $0 + ($1.0 - mx) * ($1.1 - my) }
            let den = xs.reduce(0) { $0 + ($1 - mx) * ($1 - mx) }
            slope = den == 0 ? 0 : num / den
        }
        return GoalInfo(start: start, goal: goal, latest: latest, pct: pct, left: max(0, latest - goal), span: span, slope: slope)
    }

    // MARK: - グラフ

    func points(lastDays range: Int, endingAt end: Date = .today) -> [ChartPoint] {
        (0..<range).reversed().compactMap { i in
            let d = end.adding(days: -i)
            return entries[d].map { ChartPoint(date: d, weight: $0.weight) }
        }
    }

    // MARK: - キャラ

    /// なかよし度（記録1回で1。ごほうびの「なかよし度 +5」「+10」もここで足す）
    var friendshipPoints: Int {
        entries.count
            + (earnedBadges.contains("streak7") ? 5 : 0)
            + (earnedBadges.contains("rec50") ? 10 : 0)
    }

    var level: (lv: Int, inLevel: Int, title: String) {
        let n = friendshipPoints
        let lv = n / 15 + 1
        return (lv, n % 15, LevelTitle.all[min(lv - 1, LevelTitle.all.count - 1)])
    }

    var moodCounts: [Mood: Int] {
        var c: [Mood: Int] = [:]
        for d in entries.keys { c[mood(for: d), default: 0] += 1 }
        return c
    }

    // MARK: - ごほうび判定

    func computeBadges() -> [String] {
        let ds = sortedDates
        guard let first = ds.first.flatMap({ entries[$0]?.weight }),
              let last = ds.last.flatMap({ entries[$0]?.weight }) else { return [] }
        var best = 1, run = 1
        for i in ds.indices.dropFirst() {
            run = ds[i - 1].days(to: ds[i]) == 1 ? run + 1 : 1
            best = max(best, run)
        }
        let minW = ds.compactMap { entries[$0]?.weight }.min() ?? first
        var got = ["first"]
        if best >= 7 { got.append("streak7") }
        if first - minW >= 1 { got.append("down1") }
        if best >= 30 { got.append("streak30") }
        if first - minW >= 3 { got.append("down3") }
        if ds.count >= 50 { got.append("rec50") }
        if last <= settings.goal { got.append("goal") }
        if best >= 100 { got.append("streak100") }
        return got
    }

    private func afterChange() {
        let now = computeBadges()
        let fresh = now.filter { !earnedBadges.contains($0) }
        earnedBadges = Array(Set(earnedBadges + now))
        if let id = fresh.first, let badge = Badge.all.first(where: { $0.id == id }) {
            pendingCelebrations += 1
            Task {
                try? await Task.sleep(for: .milliseconds(700))
                pendingCelebrations -= 1
                celebrating = badge
            }
        }
    }

    // MARK: - 操作

    /// - Parameter memo: ホームのひとことメモ。空のときは、もとのメモをそのまま残す
    func saveToday(weight: Double, tags: [String], memo: String = "") {
        let wasCleared = clearedWatchToday != nil
        var e = entries[.today] ?? WeightEntry(date: .today, weight: weight)
        e.weight = (weight * 10).rounded() / 10
        e.tags = tags
        let trimmed = String(memo.prefix(WeightEntry.memoLimit)).trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { e.memo = trimmed }
        takePendingGuess(into: &e)
        entries[.today] = e
        simulateAbsent = false
        roomMood = nil
        heroSay = nil
        homeBounce += 1
        afterChange()
        celebrateClear(wasCleared: wasCleared)
        AdService.shared.noteSaved()
        writeToHealth(e)
        let saved = settings.hideNumbers ? L("記録しました") : LF("%@kg を記録しました", Fmt.kg(e.weight))
        showToast(saved + guessToastSuffix)
    }

    func save(_ entry: WeightEntry) {
        let wasCleared = clearedWatchToday != nil
        var e = entry
        e.weight = (e.weight * 10).rounded() / 10
        // 記録シートは、よそうをさわらない。前のよそうをそのまま残す
        e.guess = entries[e.date]?.guess
        e.bot = entries[e.date]?.bot
        if e.date == .today { takePendingGuess(into: &e) }
        entries[e.date] = e
        // 自動で決まる顔と同じなら、えらび直しとしては保存しない
        if let f = e.face, judge(e.date)?.mood == f { entries[e.date]?.face = nil }
        if e.date == .today {
            simulateAbsent = false
            homeBounce += 1
        }
        roomMood = nil
        heroSay = nil
        afterChange()
        celebrateClear(wasCleared: wasCleared)
        AdService.shared.noteSaved()
        writeToHealth(e)
        showToast(LF("%@を保存しました", Fmt.monthDay(e.date)))
    }

    func delete(_ date: Date) {
        entries[date] = nil
        roomMood = nil
        if detailDate == date { detailDate = nil }
        #if HEALTH_SYNC
        if settings.health && !isScratch { Task { await HealthSync.delete(date) } }
        #endif
        showToast(L("記録を削除しました"))
    }

    func pickTodayFace(_ mood: Mood) {
        guard var e = entries[.today] else { return }
        e.face = mood == judge(.today)?.mood ? nil : mood
        entries[.today] = e
    }

    /// 「＋ 過去の日を入力」：まだ記録のない一番近い過去の日
    func nearestMissingPastDate() -> Date {
        for i in 1...119 {
            let d = Date.today.adding(days: -i)
            if entries[d] == nil { return d }
        }
        return Date.today.adding(days: -1)
    }

    // MARK: - ごほうびの日

    func isTreat(_ date: Date) -> Bool { treats[date]?.on == true }

    /// ごほうびの日か、その翌日
    func treatHit(_ date: Date) -> Bool { isTreat(date) || isTreat(date.adding(days: -1)) }

    /// あしたの「ごほうびの日」をせんげんする・とりけす
    func toggleTomorrowTreat() {
        let tomorrow = Date.today.adding(days: 1)
        let on = !isTreat(tomorrow)
        treats[tomorrow] = TreatMark(date: tomorrow, on: on, updatedAt: Self.stamp())
        heroSay = on
            ? HeroSay(mood: .happy, line: L("わかった！あしたは思いっきりたのしんでね"))
            : HeroSay(line: L("わかった、とりけしたよ"))
        showToast(on ? L("あしたを ごほうびの日にしました") : L("ごほうびの日をとりけしました"))
    }

    // MARK: - 体重よそう

    /// きょうのよそう（記録の前）
    var todayPendingGuess: PendingGuess? {
        pendingGuess?.date == .today ? pendingGuess : nil
    }

    /// よそうをえらぶ。同じものをもう一度押すと外す
    func tapGuess(_ guess: WeightGuess) {
        if todayPendingGuess?.guess == guess {
            pendingGuess = nil
            heroSay = HeroSay(mood: .sleepy, line: todayState.line ?? Mood.sleepy.lines[0])
            return
        }
        let bot = todayPendingGuess?.bot ?? botGuess(.today)
        pendingGuess = PendingGuess(date: .today, guess: guess, bot: bot)
        heroSay = HeroSay(mood: .sleepy, line: LF("「%1$@」ね！ぼくは「%2$@」だよ", guess.label, bot.label))
    }

    private func takePendingGuess(into e: inout WeightEntry) {
        guard let g = todayPendingGuess else { return }
        e.guess = g.guess
        e.bot = g.bot
        pendingGuess = nil
    }

    /// 記録したときのトーストのうしろ
    private var guessToastSuffix: String {
        guard settings.game, let g = guessResult(.today) else { return "" }
        return g.hit ? LF(" ・ よそうあたり！+%dpt", g.points) : L(" ・ よそうははずれ")
    }

    private static func actual(from previous: Double, to weight: Double) -> WeightGuess {
        let d = ((weight - previous) * 10).rounded() / 10
        return d > 0.1 ? .up : d < -0.1 ? .down : .same
    }

    /// 日付ごとに決まる、キャラの気まぐれ
    private static func botPattern(_ date: Date) -> WeightGuess {
        let c = Calendar.app.dateComponents([.year, .month, .day], from: date)
        let key = String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
        let hash = key.utf8.reduce(UInt32(7)) { $0 &* 31 &+ UInt32($1) }
        return [WeightGuess.same, .down, .up, .same, .down][Int(hash % 5)]
    }

    /// キャラのよそう：飲み会・外食・ごほうびの日のあとは「へった」、ほかは気まぐれ
    private func botGuess(_ date: Date) -> WeightGuess {
        if let p = sortedDates.last(where: { $0 < date }) {
            let tags = entries[p]?.tags ?? []
            if tags.contains("飲み会") || tags.contains("外食") || treatHit(p) { return .down }
        }
        return Self.botPattern(date)
    }

    private func guessResult(for e: WeightEntry, previous: Double?) -> GuessResult? {
        guard let guess = e.guess, let previous else { return nil }
        let actual = Self.actual(from: previous, to: e.weight)
        let bot = e.bot ?? botGuess(e.date)
        let hit = guess == actual, botHit = bot == actual
        return GuessResult(guess: guess, bot: bot, actual: actual, hit: hit, botHit: botHit,
                           points: (hit ? 10 : 0) + (hit && !botHit ? 5 : 0))
    }

    func guessResult(_ date: Date) -> GuessResult? {
        guard let e = entries[date] else { return nil }
        let p = sortedDates.last { $0 < date }
        return guessResult(for: e, previous: p.flatMap { entries[$0]?.weight })
    }

    var guessStats: GuessStats {
        var s = GuessStats()
        var monthCount = 0, monthHits = 0
        let ds = sortedDates
        let thisMonth = Calendar.app.dateComponents([.year, .month], from: .today)
        for (i, d) in ds.enumerated() where i > 0 {
            guard let e = entries[d], let r = guessResult(for: e, previous: entries[ds[i - 1]]?.weight) else { continue }
            s.count += 1
            s.points += r.points
            s.run = r.hit ? s.run + 1 : 0
            if r.hit && !r.botHit { s.wins += 1 }
            if !r.hit && r.botHit { s.losses += 1 }
            if Calendar.app.dateComponents([.year, .month], from: d) == thisMonth {
                monthCount += 1
                if r.hit { monthHits += 1 }
            }
        }
        if monthCount > 0 { s.monthRate = Int((Double(monthHits) / Double(monthCount) * 100).rounded()) }
        return s
    }

    // MARK: - もどるまで見守り

    /// 飲み会・外食・ごほうびの日のあとに増えた日から、もとの体重（その前の7日平均）にもどるまで。
    /// 2週間もどらなければ、失敗にせず静かに終わる
    var watches: (done: [WatchRecord], active: WatchRecord?) {
        // 1回の描画で何度も読むので、記録が変わるか日付が変わるまで取っておく
        let today = Date.today
        if let c = watchesCache, c.day == today { return c.value }
        let value = computeWatches()
        watchesCache = (today, value)
        return value
    }

    private func computeWatches() -> (done: [WatchRecord], active: WatchRecord?) {
        var done: [WatchRecord] = []
        var cur: WatchRecord?
        for d in sortedDates {
            guard let e = entries[d] else { continue }
            if var c = cur {
                // 小数の誤差で「ちょうどもどった日」を逃さないように、ごくわずかに甘くする
                if e.weight <= c.base + 0.1 + 0.0001 {
                    c.end = d
                    done.append(c)
                    cur = nil
                    continue
                }
                if c.start.days(to: d) > 14 {
                    cur = nil
                } else {
                    c.current = e.weight
                    c.peak = max(c.peak, e.weight)
                    cur = c
                    continue
                }
            }
            let label = treatHit(d) ? "ごほうびの日" : Self.watchTags.first { e.tags.contains($0) }
            guard let label, let avg = average7(before: d) else { continue }
            let base = (avg * 10).rounded() / 10
            guard ((e.weight - avg) * 10).rounded() / 10 > 0.1 else { continue }
            cur = WatchRecord(start: d, label: label, base: base, peak: e.weight, current: e.weight)
        }
        if let c = cur, c.start.days(to: .today) > 14 { cur = nil }
        return (done, cur)
    }

    private static let watchTags = ["飲み会", "外食"]

    /// きょう、もどった見守り
    var clearedWatchToday: WatchRecord? {
        watches.done.first { $0.end == .today }
    }

    /// きょうの記録で、もやもやがはれたら紙ふぶき
    private func celebrateClear(wasCleared: Bool) {
        guard !wasCleared, clearedWatchToday != nil else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            confettiKey = (confettiKey ?? 0) + 1
            // 降り終わったら部品ごと消す（ConfettiView は約3秒。出したままだと描きつづける）
            let key = confettiKey
            try? await Task.sleep(for: .seconds(3.5))
            if confettiKey == key { confettiKey = nil }
        }
    }

    // MARK: - ヘルスケア

    #if HEALTH_SYNC
    /// 「ヘルスケアと同期」のオン・オフ。オンにするときは許可をたずねる
    func setHealth(_ on: Bool) {
        guard on else {
            settings.health = false
            showToast(L("ヘルスケアとの同期をやめました"))
            return
        }
        guard HealthSync.isAvailable else {
            showToast(L("この端末ではヘルスケアを使えません"))
            return
        }
        Task {
            guard await HealthSync.requestAuthorization() else {
                showToast(L("設定アプリでヘルスケアをオンにしてね"))
                return
            }
            settings.health = true
            showToast(L("ヘルスケアと同期します"))
        }
    }

    /// ヘルスケアのいちばん新しい体重。なければトーストを出して nil
    func readHealthWeight() async -> Double? {
        guard let w = await HealthSync.latestWeight() else {
            showToast(L("ヘルスケアに体重の記録がないよ"))
            return nil
        }
        let v = (w * 10).rounded() / 10
        showToast(settings.hideNumbers ? L("ヘルスケアから読みこみました") : LF("ヘルスケアから %@kg を読みこみました", Fmt.kg(v)))
        return v
    }
    #endif

    private func writeToHealth(_ e: WeightEntry) {
        #if HEALTH_SYNC
        guard settings.health, !isScratch else { return }
        let date = e.date, weight = e.weight
        Task { await HealthSync.write(date: date, weight: weight) }
        #endif
    }

    // MARK: - タグ

    /// タグを足す。足せなかったときは、その理由（トーストに出す文言）を返す。
    /// はじめからあるタグは日本語のまま持つので、表示名（L(t)）とも重ならないようにする
    @discardableResult
    func addTag(_ name: String) -> String? {
        let t = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return L("タグの名前を入れてね") }
        // 入力欄では切らない（日本語の変換中に切ると、変換がこわれるため）
        guard t.count <= DayTag.maxLength else { return LF("タグの名前は%d文字までだよ", DayTag.maxLength) }
        guard !settings.tags.contains(where: { $0 == t || L($0) == t }) else { return L("そのタグはもうあるよ") }
        guard settings.tags.count < DayTag.maxCount else { return LF("タグは%dこまでだよ", DayTag.maxCount) }
        // 訳のあるはじめのタグを、訳の名前で足したときは、日本語のキーにもどす（キャラの反応が効くように）
        settings.tags.append(DayTag.all.first { L($0) == t } ?? t)
        return nil
    }

    /// 一覧から消す。これまでの記録に付いたタグはそのまま残る
    func removeTag(_ tag: String) {
        settings.tags.removeAll { $0 == tag }
    }

    func moveTagUp(_ tag: String) {
        guard let i = settings.tags.firstIndex(of: tag), i > 0 else { return }
        settings.tags.swapAt(i, i - 1)
    }

    /// 消した「はじめのタグ」を、うしろに足しなおす（上限まで）。足せなかった分があれば、その理由を返す
    @discardableResult
    func restoreDefaultTags() -> String? {
        let missing = DayTag.all.filter { !settings.tags.contains($0) }
        let room = max(0, DayTag.maxCount - settings.tags.count)
        settings.tags += missing.prefix(room)
        return missing.count > room ? LF("タグは%dこまでだよ", DayTag.maxCount) : nil
    }

    // MARK: - トースト

    func showToast(_ message: String) {
        toastTask?.cancel()
        withAnimation(.spring(duration: 0.3)) { toast = message }
        toastTask = Task {
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.25)) { toast = nil }
        }
    }
}
