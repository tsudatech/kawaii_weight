//
//  CSVExport.swift
//  kawaii_taiju_kanri
//
//  記録を CSV にして共有シートで書き出す
//

import CoreTransferable
import Foundation
import UniformTypeIdentifiers

struct CSVExport: Transferable {
    let fileName: String
    /// Excel で文字化けしないよう BOM つき
    let data: Data

    /// mood: その日のキャラの表情（えらび直した顔があればそれ）
    init(entries: [WeightEntry], mood: (Date) -> Mood) {
        let ymd: (Date) -> String = {
            let c = Calendar.app.dateComponents([.year, .month, .day], from: $0)
            return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
        }
        var rows = [[L("日付"), L("体重(kg)"), L("体脂肪率(%)"), L("タグ"), L("メモ"), L("きぶん")]]
        for e in entries.sorted(by: { $0.date < $1.date }) {
            rows.append([
                ymd(e.date),
                Fmt.kg(e.weight),
                e.fat.map { Fmt.kg($0) } ?? "",
                e.tags.map { L($0) }.joined(separator: " "),
                e.memo ?? "",
                mood(e.date).label,
            ])
        }
        let text = rows.map { $0.map(Self.escape).joined(separator: ",") }.joined(separator: "\r\n") + "\r\n"
        fileName = "taiju_\(ymd(.now).replacingOccurrences(of: "-", with: "")).csv"
        data = Data([0xEF, 0xBB, 0xBF]) + Data(text.utf8)
    }

    private static func escape(_ field: String) -> String {
        guard field.contains(where: { ",\"\n\r".contains($0) }) else { return field }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { export in
            let url = URL.temporaryDirectory.appendingPathComponent(export.fileName)
            try export.data.write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }
}
