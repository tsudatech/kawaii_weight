//
//  Persistence.swift
//  kawaii_taiju_kanri
//
//  記録・設定を JSON ファイル（Application Support/data.json）に保存する
//

import Foundation

struct SavedData: Codable {
    var entries: [WeightEntry] = []
    var settings = AppSettings()
    var characterName = ""
    var earnedBadges: [String] = []
    var onboarded = false
    /// 消した記録の印（iCloud バックアップ用）
    var deleted: [DeletedEntry] = []
    /// キャラの名前を最後に変えた時刻（iCloud バックアップ用）
    var nameUpdatedAt: Date?
    /// ごほうびの日の印（iCloud バックアップにも預ける）
    var treats: [TreatMark] = []
    /// 記録の前にしたよそう
    var pendingGuess: PendingGuess?
}

enum Persistence {
    private static var fileURL: URL {
        let dir = URL.applicationSupportDirectory
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("data.json")
    }

    /// 保存がなければ nil（はじめての起動）
    static func load() -> SavedData? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? decoder.decode(SavedData.self, from: data)
    }

    static func save(_ saved: SavedData) {
        do {
            try encoder.encode(saved).write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        } catch {
            print("保存に失敗しました: \(error)")
        }
    }

    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = .sortedKeys
        return e
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}

// あとから項目が増えても、古い保存データを読めるようにする
extension SavedData {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        entries = try c.decodeIfPresent([WeightEntry].self, forKey: .entries) ?? []
        settings = try c.decodeIfPresent(AppSettings.self, forKey: .settings) ?? AppSettings()
        characterName = try c.decodeIfPresent(String.self, forKey: .characterName) ?? ""
        earnedBadges = try c.decodeIfPresent([String].self, forKey: .earnedBadges) ?? []
        onboarded = try c.decodeIfPresent(Bool.self, forKey: .onboarded) ?? false
        deleted = try c.decodeIfPresent([DeletedEntry].self, forKey: .deleted) ?? []
        nameUpdatedAt = try c.decodeIfPresent(Date.self, forKey: .nameUpdatedAt)
        treats = try c.decodeIfPresent([TreatMark].self, forKey: .treats) ?? []
        pendingGuess = try c.decodeIfPresent(PendingGuess.self, forKey: .pendingGuess)
    }
}
