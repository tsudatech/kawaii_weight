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
    // MARK: - データ（変わったら保存する）
    @Published var entries: [Date: WeightEntry] = [:] {
        didSet {
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

    // MARK: - 画面の状態
    @Published var selectedTab: AppTab = .home
    @Published var editing: SheetTarget?
    @Published var celebrating: Badge?
    /// お祝いを出す直前（記録から 0.7 秒のあいだ）。このあいだは全画面広告を出さない
    private(set) var celebrationPending = false
    @Published var toast: String?
    @Published var showOnboarding = false
    @Published var showWidgetPreview = false
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
            nameUpdatedAt: nameUpdatedAt
        )
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
            nameUpdatedAt: nameUpdatedAt
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
            recentWeights: points(lastDays: 7).map(\.weight)
        ).save()
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshot.widgetKind)

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
            if skip.contains(i) { continue }
            let d = Date.today.adding(days: -i)
            let weight = (w * 10).rounded() / 10
            let fat = ((w * 0.48 + (rnd() - 0.5) * 0.6) * 10).rounded() / 10
            let t = tagged[i]
            result[d] = WeightEntry(date: d, weight: weight, fat: fat, tags: t?.0 ?? [], memo: t?.1)
        }
        // 置きかえた本物の記録を「消した」扱いにしない（あとでバックアップをオンにしたとき、ほかの端末から消さないように）
        applyingBackup = true
        entries = result
        deleted = [:]
        applyingBackup = false
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
        return Judgement(mood: mood, diff: diff, line: line)
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
        if let f = dayFace(.today) { return (f.mood, f.line) }
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
            celebrationPending = true
            Task {
                try? await Task.sleep(for: .milliseconds(700))
                celebrationPending = false
                celebrating = badge
            }
        }
    }

    // MARK: - 操作

    /// - Parameter memo: ホームのひとことメモ。空のときは、もとのメモをそのまま残す
    func saveToday(weight: Double, tags: [String], memo: String = "") {
        var e = entries[.today] ?? WeightEntry(date: .today, weight: weight)
        e.weight = (weight * 10).rounded() / 10
        e.tags = tags
        let trimmed = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { e.memo = trimmed }
        entries[.today] = e
        simulateAbsent = false
        roomMood = nil
        homeBounce += 1
        afterChange()
        AdService.shared.noteSaved()
        showToast(LF("%@kg を記録しました", Fmt.kg(e.weight)))
    }

    func save(_ entry: WeightEntry) {
        var e = entry
        e.weight = (e.weight * 10).rounded() / 10
        entries[e.date] = e
        // 自動で決まる顔と同じなら、えらび直しとしては保存しない
        if let f = e.face, judge(e.date)?.mood == f { entries[e.date]?.face = nil }
        if e.date == .today {
            simulateAbsent = false
            homeBounce += 1
        }
        roomMood = nil
        afterChange()
        AdService.shared.noteSaved()
        showToast(LF("%@を保存しました", Fmt.monthDay(e.date)))
    }

    func delete(_ date: Date) {
        entries[date] = nil
        roomMood = nil
        if detailDate == date { detailDate = nil }
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

    // MARK: - タグ

    /// タグを足す。足せなかったときは、その理由（トーストに出す文言）を返す。
    /// はじめからあるタグは日本語のまま持つので、表示名（L(t)）とも重ならないようにする
    @discardableResult
    func addTag(_ name: String) -> String? {
        let t = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return L("タグの名前を入れてね") }
        guard !settings.tags.contains(where: { $0 == t || L($0) == t }) else { return L("そのタグはもうあるよ") }
        guard settings.tags.count < DayTag.maxCount else { return LF("タグは%dこまでだよ", DayTag.maxCount) }
        // 訳のあるはじめのタグを、訳の名前で足したときは、日本語のキーにもどす（キャラの反応が効くように）
        settings.tags.append(DayTag.all.first { L($0) == t } ?? String(t.prefix(DayTag.maxLength)))
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

    /// 消した「はじめのタグ」を、うしろに足しなおす
    func restoreDefaultTags() {
        settings.tags += DayTag.all.filter { !settings.tags.contains($0) }
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
