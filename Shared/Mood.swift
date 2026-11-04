//
//  Mood.swift
//  kawaii_taiju_kanri
//

import Foundation

/// キャラの表情（全14種類）
enum Mood: String, CaseIterable, Identifiable, Codable {
    case happy, good, hmm, trouble, crying, angry, tired, sleepy
    case surprise, doya, nightcap, cozy, lonely, cheer

    var id: String { rawValue }

    var label: String {
        switch self {
        case .happy: L("るんるん")
        case .good: L("グッド")
        case .hmm: L("うーん")
        case .trouble: L("こまった")
        case .crying: L("なきそう")
        case .angry: L("おこ")
        case .tired: L("つかれ")
        case .sleepy: L("ねむい")
        case .surprise: L("びっくり")
        case .doya: L("どやっ")
        case .nightcap: L("ねぶそく")
        case .cozy: L("ぬくぬく")
        case .lonely: L("さみしい")
        case .cheer: L("おうえん")
        }
    }

    /// 大サイズ画像 720×720（ホーム・おへや・日の詳細など）
    var largeAsset: String { "lg_\(rawValue)" }

    /// 小サイズ画像 240×240、頭と肩まで（りれき・カレンダー・きぶん選択など）
    var smallAsset: String { "sm_\(rawValue)" }

    var lines: [String] {
        switch self {
        case .happy: [L("やったー！ちゃんと減ってるよ！"), L("この調子この調子♪"), L("すごい！えらい！")]
        case .good: [L("いい感じ！"), L("コツコツがいちばん！"), L("今日もえらいね")]
        case .hmm: [L("うーん、横ばいだね"), L("そういう日もあるよ"), L("明日も一緒にはかろ")]
        case .trouble: [L("ちょっと増えちゃった…"), L("そういう日もあるよ"), L("気にしすぎないでね")]
        case .crying: [L("えーん、増えてるよぉ"), L("昨日なに食べた…？"), L("明日がんばろ…")]
        case .angry: [L("ずっと増えてる！"), L("もう！おやつ禁止！"), L("いっしょに歩きに行くよ！")]
        case .tired: [L("きょうは休んでいいよ"), L("ちょっとひとやすみ"), L("焦らずいこ")]
        case .sleepy: [L("まだはかってないよ〜"), L("ふぁ…おはよう"), L("体重計のってきて〜")]
        case .surprise: [L("えっ！こんなに減ってる！？"), L("びっくりした〜！すごいよ"), L("ほんとに？もう一回のってみて！")]
        case .doya: [L("さいしん最軽量！ふふん"), L("記録更新だよ、どやっ"), L("この調子でいくもんね〜")]
        case .nightcap: [L("寝不足だと増えやすいの。きょうは早く寝よ"), L("ふぁ…ねむねむ"), L("睡眠もダイエットのうちだよ")]
        case .cozy: [L("きょうはゆっくり休もうね"), L("あったかくして、のんびりしよ"), L("お休みの日も大事だよ")]
        case .lonely: [L("さみしかったよぉ…"), L("また会えてうれしい…"), L("きょうから、またいっしょにはかろ？")]
        case .cheer: [L("がんばれ〜！ずっと応援してるよ"), L("フレー！フレー！"), L("いっしょにゴールめざそ！")]
        }
    }

    /// 「きょうのきぶん」で自分でえらんだときの返事
    var faceReply: String {
        switch self {
        case .happy: L("るんるんな気分なんだね！いいね〜")
        case .good: L("いい感じなんだね、よかった！")
        case .hmm: L("うーん、な日もあるよね")
        case .trouble: L("こまったことあった？むりしないでね")
        case .crying: L("かなしい気分なんだね…そばにいるよ")
        case .angry: L("ぷんぷんな気分なんだね。なにかあった？")
        case .tired: L("つかれてるんだね。ゆっくりしてね")
        case .sleepy: L("ねむいよね…きょうは早めに寝よ")
        case .surprise: L("びっくりすることあった？")
        case .doya: L("どやっ！な気分なんだね、いいね〜")
        case .nightcap: L("ねぶそくなんだね。むりしないでね")
        case .cozy: L("ぬくぬくしたい気分なんだね")
        case .lonely: L("さみしい気分なんだね…そばにいるよ")
        case .cheer: L("がんばるぞ！な気分なんだね。おうえんしてる！")
        }
    }

    /// タップするたびに次のセリフ。最初の1回は custom（その場面専用のセリフ）を優先する
    func line(custom: String?, index: Int) -> String {
        if index == 0, let custom { return custom }
        let i = index - (custom == nil ? 0 : 1)
        return lines[i % lines.count]
    }

    /// 増えた・減ったで揺らすかどうか
    var isSad: Bool { [.trouble, .crying, .angry].contains(self) }
}
