//
//  Models.swift
//  kawaii_taiju_kanri
//

import Foundation

/// 1日ぶんの記録
struct WeightEntry: Identifiable, Equatable, Codable {
    var id: Date { date }
    let date: Date
    var weight: Double
    var fat: Double?
    var tags: [String] = []
    var memo: String?
    /// 自分でえらび直した顔（nil なら体重から自動で決まる）
    var face: Mood?
    /// 最後に書きかえた時刻（iCloud バックアップで、どちらの端末の記録を残すか決めるのに使う）
    var updatedAt: Date?
}

/// 消した記録の印（iCloud バックアップで、ほかの端末に残っている同じ日の記録も消すため）
struct DeletedEntry: Codable, Equatable {
    let date: Date
    let deletedAt: Date
}

/// 日のタグ。保存するのは日本語のまま（キー）で、表示するときに L(tag) で訳す
enum DayTag {
    static let all = ["飲み会", "外食", "寝不足", "のんびり", "運動した"]

    /// 増えた日にタグがあると、キャラがやさしく受け止める
    static let reactions: [(tag: String, mood: Mood, line: String)] = [
        ("のんびり", .cozy, L("のんびりした日も大事だよ。また明日ね")),
        ("飲み会", .trouble, L("飲み会たのしかった？2〜3日で戻るよ")),
        ("外食", .hmm, L("外食は塩分多めだもんね。すぐ戻るよ")),
        ("寝不足", .nightcap, L("寝不足だと増えやすいの。きょうは早く寝よ")),
    ]
}

enum JudgeMode: String, CaseIterable, Codable {
    /// 7日平均とくらべる
    case trend
    /// 前日とくらべる
    case daily
}

struct AppSettings: Equatable, Codable {
    var height: Int = 160
    var goal: Double = 55.0
    /// 毎朝の通知。許可をもらうまでは切っておく（はじめの設定・せっていでオンにしたときに許可をたずねる）
    var remind = false
    var remindTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 30)) ?? .now
    var talk = true
    var move = true
    var strict = false
    var judge: JudgeMode = .trend
}

// あとから項目が増えても、古い保存データを読めるようにする
extension AppSettings {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = AppSettings()
        height = try c.decodeIfPresent(Int.self, forKey: .height) ?? d.height
        goal = try c.decodeIfPresent(Double.self, forKey: .goal) ?? d.goal
        remind = try c.decodeIfPresent(Bool.self, forKey: .remind) ?? d.remind
        remindTime = try c.decodeIfPresent(Date.self, forKey: .remindTime) ?? d.remindTime
        talk = try c.decodeIfPresent(Bool.self, forKey: .talk) ?? d.talk
        move = try c.decodeIfPresent(Bool.self, forKey: .move) ?? d.move
        strict = try c.decodeIfPresent(Bool.self, forKey: .strict) ?? d.strict
        judge = try c.decodeIfPresent(JudgeMode.self, forKey: .judge) ?? d.judge
    }
}

struct Badge: Identifiable, Equatable {
    let id: String
    let big: String
    let unit: String
    let name: String
    let mood: Mood
    let title: String
    let message: String
    /// もらえるもの。まだ作っていないもの（きせかえ・おへやの背景など）は nil にして出さない
    let gift: String?

    static let all: [Badge] = [
        Badge(id: "first", big: "1", unit: L("かいめ"), name: L("はじめての\nきろく"), mood: .happy, title: L("はじめてのきろく！"), message: L("これから毎日いっしょにはかろうね"), gift: L("ごほうび：ずかんに、はじめての顔がのったよ")),
        Badge(id: "streak7", big: "7", unit: L("日"), name: L("7日\nれんぞく"), mood: .doya, title: L("7日れんぞく！"), message: L("1週間つづいたね。すごい！"), gift: L("ごほうび：なかよし度 +5")),
        Badge(id: "down1", big: "1", unit: "kg", name: L("1kg\nへった"), mood: .happy, title: L("1kgへったよ！"), message: L("はじめた日から1kgも減ったよ。えらすぎる〜！"), gift: nil),
        Badge(id: "streak30", big: "30", unit: L("日"), name: L("30日\nれんぞく"), mood: .doya, title: L("30日れんぞく！"), message: L("1か月毎日きろく。もう習慣だね"), gift: nil),
        Badge(id: "down3", big: "3", unit: "kg", name: L("3kg\nへった"), mood: .surprise, title: L("3kgへったよ！"), message: L("見た目でもわかるくらいだよ！"), gift: nil),
        Badge(id: "rec50", big: "50", unit: L("かい"), name: L("きろく\n50回"), mood: .cheer, title: L("きろく50回！"), message: L("50回もはかってくれてありがとう"), gift: L("ごほうび：なかよし度 +10")),
        Badge(id: "goal", big: "🎯", unit: "", name: L("もくひょう\n達成"), mood: .happy, title: L("もくひょう達成！"), message: L("ほんとにやったね！！いっしょにお祝いしよ"), gift: nil),
        Badge(id: "streak100", big: "100", unit: L("日"), name: L("100日\nれんぞく"), mood: .happy, title: L("100日れんぞく！"), message: L("伝説の100日…！ずっといっしょだよ"), gift: nil),
    ]
}

enum LevelTitle {
    static let all = [L("はじめまして"), L("顔見知り"), L("なかよし"), L("しんゆう"), L("ずっといっしょ")]
}

/// もくひょう達成度ごとのおうえん
struct CheerBand {
    let upTo: Double
    let face: String
    let lines: [String]

    static let all: [CheerBand] = [
        CheerBand(upTo: 0, face: "lg_hmm", lines: [L("ここがスタートライン！いっしょにいこ"), L("あせらず、まずは毎日はかろうね")]),
        CheerBand(upTo: 10, face: "lg_good", lines: [L("いいスタート！最初の一歩がいちばんえらい"), L("はじめたこと自体がすごいんだよ")]),
        CheerBand(upTo: 25, face: "cheer", lines: [L("もう{p}%進んだよ！ちゃんと前に進んでる"), L("コツコツがちゃんと数字に出てるね")]),
        CheerBand(upTo: 50, face: "cheer", lines: [L("4分の1こえたね！このままいこ〜"), L("半分まで、あと{toHalf}kgだよ！")]),
        CheerBand(upTo: 75, face: "lg_happy", lines: [L("もう半分こえた！折り返しだよ〜"), L("ここまで来たの、ほんとにすごい")]),
        CheerBand(upTo: 90, face: "cheer", lines: [L("ゴールが見えてきた！あと{left}kg"), L("いっしょにゴールテープ切ろうね")]),
        CheerBand(upTo: 100, face: "cheer", lines: [L("あとちょっと！ラストスパート！"), L("あと{left}kg…どきどきしてきた！")]),
        CheerBand(upTo: .infinity, face: "lg_happy", lines: [L("もくひょう達成おめでとう！これからはキープしよ"), L("ほんとにがんばったね。ずっと見てたよ")]),
    ]
}

/// 判定結果
struct Judgement {
    var mood: Mood
    var diff: Double?
    var line: String?
}

/// その日の顔（えらび直した顔があればそれ、なければ自動）
struct DayFace {
    var mood: Mood
    var line: String?
    var auto: Mood
    var picked: Bool
}

struct GoalInfo {
    var start: Double
    var goal: Double
    var latest: Double
    var pct: Double
    var left: Double
    var span: Double
    /// 直近30日の傾き（kg/日）
    var slope: Double
}

struct ChartPoint: Identifiable {
    var id: Date { date }
    let date: Date
    let weight: Double
}

/// 記録シートを開く対象の日
struct SheetTarget: Identifiable, Hashable {
    let date: Date
    var id: Date { date }
}
