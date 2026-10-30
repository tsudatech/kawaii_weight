//
//  Theme.swift
//  kawaii_taiju_kanri
//
//  デモ（kawaii-weight-demo/css/style.css）の :root 変数をそのまま移植した色・フォント
//

import CoreText
import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum Palette {
    static let desk = Color(hex: 0xEFE6DC)
    static let paper = Color(hex: 0xFFF9F3)
    static let card = Color.white
    static let ink = Color(hex: 0x4A3020)
    static let inkSoft = Color(hex: 0x8C7564)
    static let inkFaint = Color(hex: 0xBCA99A)
    static let line = Color(hex: 0xEADDD1)
    static let lineSoft = Color(hex: 0xF4ECE4)
    static let cheek = Color(hex: 0xF9D2CC)
    static let blush = Color(hex: 0xFBEDE7)
    static let rose = Color(hex: 0xE58C86)
    static let gold = Color(hex: 0xF3CA89)
    static let mint = Color(hex: 0x9FD3C7)
    static let mintInk = Color(hex: 0x3E9B86)
    static let sky = Color(hex: 0xB4E1E4)
    static let up = Color(hex: 0xD06A63)
    static let seg = Color(hex: 0xF6EEE7)
    static let soft = Color(hex: 0xFFF6F1)
    static let faceBG = Color(hex: 0xFFF1EC)
    static let heroTop = Color(hex: 0xFFEFE9)
    static let heroBottom = Color(hex: 0xFFF6F0)
    static let heroBorder = Color(hex: 0xF6DCD3)
    static let grid = Color(hex: 0xF1E6DC)
    static let onInk = Color(hex: 0xFFF6EE)
    static let inkShadow = Color(hex: 0x2B1C12)
    static let roseShadow = Color(hex: 0xB8625C)
}

/// デモと同じフォント（Zen Maru Gothic・Baloo 2）。アプリ本体に入れてあり、ウィジェットも本体のファイルを使う
enum AppFont {
    private static let files = [
        "ZenMaruGothic-Medium", "ZenMaruGothic-Bold", "ZenMaruGothic-Black",
        "Baloo2-SemiBold", "Baloo2-Bold", "Baloo2-ExtraBold",
    ]

    /// 最初にフォントを使うときに一度だけ登録する
    static let registered: Bool = {
        var bundles = [Bundle.main.bundleURL]
        if Bundle.main.bundleURL.pathExtension == "appex" {
            // ウィジェット：Foo.app/PlugIns/Bar.appex → Foo.app
            bundles.append(Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent())
        }
        for name in files {
            for dir in bundles {
                let url = dir.appendingPathComponent("\(name).ttf")
                if FileManager.default.fileExists(atPath: url.path) {
                    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
                    break
                }
            }
        }
        return true
    }()
}

extension Font {
    /// 本文・見出し用（Zen Maru Gothic。CSS の 500 / 700 / 900）
    static func ui(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        _ = AppFont.registered
        let name = switch weight {
        case .black, .heavy: "ZenMaruGothic-Black"
        case .medium, .regular, .light, .thin, .ultraLight: "ZenMaruGothic-Medium"
        default: "ZenMaruGothic-Bold"
        }
        return .custom(name, fixedSize: size)
    }

    /// 数字用（Baloo 2。CSS の 600 / 700 / 800）
    static func num(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        _ = AppFont.registered
        let name = switch weight {
        case .semibold, .medium, .regular: "Baloo2-SemiBold"
        case .bold: "Baloo2-Bold"
        default: "Baloo2-ExtraBold"
        }
        return .custom(name, fixedSize: size).monospacedDigit()
    }
}

/// 増減の色（減＝ミント、増＝赤）
func deltaColor(_ v: Double?) -> Color {
    guard let v else { return Palette.ink }
    if v < -0.05 { return Palette.mintInk }
    if v > 0.05 { return Palette.up }
    return Palette.ink
}

// MARK: - CSS の line-height

enum LineMetrics {
    /// フォント本来の1行の高さ（em）。CSS の line-height: normal と同じ
    static let ui: CGFloat = 1.448
    static let num: CGFloat = 1.602
}

extension View {
    /// CSS の line-height を再現する（1行の高さ = size × lh。はみ出す分は上下に均等）
    func lineHeight(_ lh: CGFloat, size: CGFloat, natural: CGFloat = LineMetrics.ui) -> some View {
        let extra = (lh - natural) * size
        return lineSpacing(max(0, extra)).padding(.vertical, extra / 2)
    }

    /// Baloo 2（数字）用
    func numLineHeight(_ lh: CGFloat, size: CGFloat) -> some View {
        lineHeight(lh, size: size, natural: LineMetrics.num)
    }
}

// MARK: - 数字フォントの文字列（"Baloo 2","Zen Maru Gothic" と同じく、英数字は Baloo 2・日本語は Zen Maru Gothic）

extension Text {
    init(num s: String, size: CGFloat, weight: Font.Weight = .heavy) {
        // Baloo 2 の 600 / 700 / 800 に対して、日本語は Zen Maru Gothic の近い太さ
        let jpWeight: Font.Weight = weight == .heavy || weight == .black ? .black : .bold
        var result = Text(verbatim: "")
        var run = ""
        var runIsASCII: Bool?
        func flush() {
            guard !run.isEmpty else { return }
            let t = Text(verbatim: run).font(runIsASCII == true ? .num(size, weight) : .ui(size, jpWeight))
            result = Text("\(result)\(t)")
            run = ""
        }
        for ch in s {
            let ascii = ch.isASCII
            if runIsASCII != nil && runIsASCII != ascii { flush() }
            runIsASCII = ascii
            run.append(ch)
        }
        flush()
        self = result
    }
}
