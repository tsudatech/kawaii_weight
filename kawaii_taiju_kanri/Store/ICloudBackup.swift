//
//  ICloudBackup.swift
//  kawaii_taiju_kanri
//
//  iCloud のキーバリューストアに、記録を預ける（ぽこりんの ICloudBackup と同じ考え方）。
//  起動時・記録の保存時・ほかの端末で変わったときに、この端末の記録と iCloud の記録を合わせる。
//
//  預けるのは、体重の記録（体脂肪・タグ・メモ・きぶん・よそう）・ごほうびの日・ごほうび・キャラの名前。
//  せってい（身長・もくひょう・通知・表示）と、はじめての案内の既読は、この端末に残す。
//

import Combine
import Foundation
import OSLog

/// iCloud に預ける中身
struct BackupData: Codable, Equatable {
    var entries: [WeightEntry] = []
    var deleted: [DeletedEntry] = []
    var earnedBadges: [String] = []
    var characterName = ""
    var nameUpdatedAt: Date?
    var treats: [TreatMark] = []

    /// 2つの記録を合わせる。
    ///
    /// 同じ日の記録は、書きかえた時刻（または消した時刻）が新しいほうを残す。
    /// ごほうびは、いちど取ったら消えないよう両方を足し合わせる。名前は、あとで変えたほうを残す。
    /// ごほうびの日は、日ごとに、あとで変えたほうを残す。
    static func merge(_ a: BackupData, _ b: BackupData) -> BackupData {
        let past = Date.distantPast
        var entries: [Date: WeightEntry] = [:]
        for e in a.entries + b.entries {
            if let cur = entries[e.date], (cur.updatedAt ?? past) >= (e.updatedAt ?? past) { continue }
            entries[e.date] = e
        }
        var deleted: [Date: Date] = [:]
        for d in a.deleted + b.deleted {
            deleted[d.date] = max(deleted[d.date] ?? past, d.deletedAt)
        }
        // 消したあとに書いた記録は残し、書いたあとに消した記録は消す
        for (date, at) in deleted {
            if let e = entries[date], (e.updatedAt ?? past) > at {
                deleted[date] = nil
            } else {
                entries[date] = nil
            }
        }

        var out = BackupData()
        out.entries = entries.values.sorted { $0.date < $1.date }
        out.deleted = deleted.map { DeletedEntry(date: $0.key, deletedAt: $0.value) }.sorted { $0.date < $1.date }
        out.earnedBadges = Badge.all.map(\.id).filter { a.earnedBadges.contains($0) || b.earnedBadges.contains($0) }
        if (b.nameUpdatedAt ?? past) > (a.nameUpdatedAt ?? past) {
            out.characterName = b.characterName
            out.nameUpdatedAt = b.nameUpdatedAt
        } else {
            out.characterName = a.characterName
            out.nameUpdatedAt = a.nameUpdatedAt
        }
        var treats: [Date: TreatMark] = [:]
        for t in a.treats + b.treats where (treats[t.date]?.updatedAt ?? past) < t.updatedAt {
            treats[t.date] = t
        }
        out.treats = treats.values.sorted { $0.date < $1.date }
        return out
    }
}

// 古いアプリが預けた中身も読めるようにする（読めないと空とみなして、合わせずに上書きしてしまうため）
extension BackupData {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        entries = try c.decodeIfPresent([WeightEntry].self, forKey: .entries) ?? []
        deleted = try c.decodeIfPresent([DeletedEntry].self, forKey: .deleted) ?? []
        earnedBadges = try c.decodeIfPresent([String].self, forKey: .earnedBadges) ?? []
        characterName = try c.decodeIfPresent(String.self, forKey: .characterName) ?? ""
        nameUpdatedAt = try c.decodeIfPresent(Date.self, forKey: .nameUpdatedAt)
        treats = try c.decodeIfPresent([TreatMark].self, forKey: .treats) ?? []
    }
}

final class ICloudBackup: ObservableObject {
    enum Status: Equatable {
        case idle, syncing, success
        /// 中身は**訳文の鍵**。出すとき（BackupView）に訳す（あとで表示言語を変えても追従するように）
        case failure(String)
    }

    private static let logger = Logger(subsystem: "jp.jntech.kawaii-taiju-kanri", category: "backup")
    private static let enabledKey = "backup.enabled"
    private static let lastSyncedKey = "backup.lastSyncedAt"
    private static let dataKey = "taiju.backup.v1"
    /// キーバリューストアは1アプリ合計1MBまで。手前で止めて書き込み失敗を避ける
    private static let sizeLimit = 900_000

    @Published private(set) var isEnabled: Bool
    @Published private(set) var lastSyncedAt: Date?
    @Published private(set) var status: Status = .idle

    /// 合わせる相手（この端末の記録）
    weak var owner: WeightStore?

    private let kvs = NSUbiquitousKeyValueStore.default
    private let defaults = UserDefaults.standard
    private var watcher: NSObjectProtocol?
    /// まとめて書くための世代印（記録の保存のたびに書きに行かない）
    private var pending = 0

    init() {
        isEnabled = defaults.bool(forKey: Self.enabledKey)
        lastSyncedAt = defaults.object(forKey: Self.lastSyncedKey) as? Date
    }

    /// 起動時に1度だけ呼ぶ
    func start() {
        // 使わない人は iCloud に一切触らない
        if isEnabled {
            kvs.synchronize()
            reconcile()
            stampSynced()
        }
        observe()
    }

    /// この端末で iCloud が使えるか
    var isAvailable: Bool { FileManager.default.ubiquityIdentityToken != nil }

    // MARK: - 入り切り

    func setEnabled(_ on: Bool) {
        guard isEnabled != on else { return }
        // せっていの行（「iCloudに預けています」）も描きなおす
        owner?.objectWillChange.send()
        isEnabled = on
        defaults.set(on, forKey: Self.enabledKey)
        if on { syncNow() } else { status = .idle }
    }

    func syncNow() {
        status = .syncing
        guard isEnabled else { status = .failure("バックアップがオフです"); return }
        guard isAvailable else { status = .failure("iCloudにサインインしてください"); return }
        guard reconcile() else { status = .failure("記録が大きすぎて預けられません"); return }
        guard kvs.synchronize() else { status = .failure("iCloudにつながりませんでした"); return }
        stampSynced()
        status = .success
    }

    /// この端末で記録が保存されたとき。少し待ってからまとめて預ける
    func noteLocalChange() {
        guard isEnabled else { return }
        pending += 1
        let token = pending
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            guard pending == token else { return }
            reconcile()
            stampSynced()
        }
    }

    /// 「すべてのデータを消す」とき。合わせずに、この端末の中身（消した印つき）で iCloud を上書きする。
    /// 合わせてしまうと、ごほうびなどが iCloud から戻ってくるため
    func replaceRemote() {
        guard isEnabled, let owner else { return }
        _ = write(owner.backupData)
        kvs.synchronize()
        stampSynced()
    }

    // MARK: - 合わせる

    /// 容量を超えて書けなかったときだけ false
    @discardableResult
    private func reconcile() -> Bool {
        guard isEnabled, let owner else { return true }
        let local = owner.backupData
        let remote = decode() ?? BackupData()
        let merged = BackupData.merge(local, remote)

        if merged != local { owner.applyBackup(merged) }
        if merged != remote { return write(merged) }
        return true
    }

    private func decode() -> BackupData? {
        guard let data = kvs.data(forKey: Self.dataKey) else { return nil }
        return try? Self.decoder.decode(BackupData.self, from: data)
    }

    private func write(_ backup: BackupData) -> Bool {
        guard let data = try? Self.encoder.encode(backup) else { return true }
        guard data.count <= Self.sizeLimit else {
            Self.logger.error("iCloud に載せるには大きすぎます: \(data.count, privacy: .public) bytes")
            return false
        }
        kvs.set(data, forKey: Self.dataKey)
        return true
    }

    // 日時は秒の端数まで残す形（既定）で書く。丸めると、同じ記録でも毎回ちがうと判定されてしまう
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    // MARK: - ほかの端末の変更

    private func observe() {
        watcher = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: kvs, queue: .main
        ) { [weak self] note in
            let changed = note.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String]
            MainActor.assumeIsolated {
                guard let self, self.isEnabled, changed?.contains(Self.dataKey) ?? true else { return }
                self.reconcile()
                self.stampSynced()
            }
        }
    }

    private func stampSynced() {
        lastSyncedAt = Date()
        defaults.set(lastSyncedAt, forKey: Self.lastSyncedKey)
    }
}
