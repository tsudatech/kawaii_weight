//
//  OpenRecordIntent.swift
//  kawaii_taiju_kanri
//
//  ロック画面・コントロールセンターの「体重をきろく」ボタン。アプリを開いて、ホームの体重入力を見せる。
//  コントロール（ウィジェット側）とアプリの両方に同じ Intent が要るので Shared に置く。
//

import AppIntents

struct OpenRecordIntent: AppIntent {
    static let title: LocalizedStringResource = "体重をきろく"
    static let description = IntentDescription("アプリを開いて、きょうの体重を入れます")
    static let openAppWhenRun = true
    static let isDiscoverable = false

    func perform() async throws -> some IntentResult {
        WidgetSnapshot.requestOpenRecord()
        return .result()
    }
}
