//
//  Localization.swift
//  kawaii_taiju_kanri
//
//  文言のローカライズ。日本語の文言をそのままキーにして、
//  Localizable.strings で各言語の訳を引く（ぽこりん・パズルちゃんと同じやり方）。
//
//  キーを別に立てないのは、コードを読むだけで何が出るか分かるようにするため。
//  訳が見つからなければキー（＝日本語）がそのまま出るので、
//  訳し忘れても画面が空になることはない。
//
//  訳文は Shared/ja.lproj・Shared/en.lproj（アプリとウィジェットの両方に入る）。
//  英語の単数・複数は en.lproj/Localizable.stringsdict。
//

import Foundation

/// 表示言語の上書き。開発用に、端末の設定を変えずに言語を切り替えるためのもの（起動引数 `--lang en`）。
/// 何も指定していなければ端末の言語がそのまま使われる。上書きはその起動のあいだだけで、保存しない。
enum LanguageOverride {
    /// "ja" / "en"。nil なら端末に合わせる。リリース版では常に nil。
    private(set) static var current: String? = {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "--lang"), i + 1 < args.count { return args[i + 1] }
        #endif
        return nil
    }()

    /// 上書き中の言語の .lproj。未指定なら nil。
    static let bundle: Bundle? = {
        guard let id = current, let path = Bundle.main.path(forResource: id, ofType: "lproj") else { return nil }
        return Bundle(path: path)
    }()

    /// いま実際に出ている言語。上書きしていなければ、端末に合わせて選ばれたほうを返す。
    ///
    /// `Locale.current` ではなく `preferredLocalizations` を見るのは、
    /// アプリが持っていない言語の端末でも、実際に出る訳（＝英語）と食い違わないようにするため。
    static var effective: String {
        current ?? Bundle.main.preferredLocalizations.first ?? "ja"
    }

    static var isJapanese: Bool { effective.hasPrefix("ja") }
}

/// 訳文を引く。見つからなければキーをそのまま返す。
func L(_ key: String) -> String {
    if let bundle = LanguageOverride.bundle {
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
    return NSLocalizedString(key, comment: "")
}

/// 差し込みのある訳文を引く。
///
/// 語順は言語で変わるので、訳文側では %1$@ のように順番を明示してよい。
/// 英語の単数・複数（1 day / 2 days）は en.lproj/Localizable.stringsdict で出し分ける。
///
/// locale は en_US_POSIX に固定する。渡さないと単数・複数の判定に端末の言語が使われ、
/// 日本語の端末で英語を出したときに「1 days」になる。
private let formatLocale = Locale(identifier: "en_US_POSIX")

func LF(_ key: String, _ args: CVarArg...) -> String {
    String(format: L(key), locale: formatLocale, arguments: args)
}
