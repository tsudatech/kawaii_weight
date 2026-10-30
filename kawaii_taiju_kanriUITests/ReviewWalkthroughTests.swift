//
//  ReviewWalkthroughTests.swift
//  kawaii_taiju_kanriUITests
//
//  App Review に出す画面収録用に、アプリの使い方を最初から最後まで自動で通すテスト。
//  （審査対応メモ「体重きろく_審査対応.md」§2-2 の流れ。スラッシュの ReviewWalkthroughTests と同じ作り）
//
//  流れ
//  ホーム画面からアイコンで起動 → はじめの設定（通知の許可）→ ホームの案内 → トラッキング許可（ATT）
//  → 過去の日を記録（記録シート）→ きょうを記録してキャラが反応 → きょうのきぶん
//  → グラフ（期間・カレンダー・日の詳細）→ キャラ（名前・ずかん・ごほうび）
//  → せってい（通知をためす・ウィジェット・バックアップ・CSV）→ ホーム
//
//  記録は2回だけ（全画面広告は3回記録したあとに出る作りなので、収録の途中で出ないように）。
//
//  使い方
//  1. iPhone を Mac につなぎ、ロックを解除しておく
//  2. アプリを削除しておく（はじめの設定と各タブの案内、許可のダイアログから撮るため。削除すると記録は消える）
//  3. テスト用のアプリ（kawaii_taiju_kanriUITests-Runner）が収録に映らないよう、ホーム画面の別のページに移しておく
//  4. 画面収録を始めてから、このテストを実行する（くわしくは審査対応メモ §2-4）
//     xcodebuild test -project kawaii_taiju_kanri.xcodeproj -scheme kawaii_taiju_kanri -configuration Release -parallel-testing-enabled NO \
//       -destination 'id=<iPhone の ID>' -allowProvisioningUpdates -only-testing:kawaii_taiju_kanriUITests/ReviewWalkthroughTests
//
//  ボタンは表示されている文字で探す。端末の言語が日本語でも英語でも動くよう、両方の文字で探す
//  （文字は Shared/ja.lproj・en.lproj の Localizable.strings と同じ）。
//  広告は絶対に押さない：バナー（画面の下のほう）にかかるボタンは、上にスクロールしてから押す。出せないときは押さない。
//

import XCTest

final class ReviewWalkthroughTests: XCTestCase {
    private let app = XCUIApplication()
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    override func setUp() {
        continueAfterFailure = true
    }

    func testReviewWalkthrough() {
        launchFromHomeScreen()
        wait(2)

        // はじめの設定（あいさつ → からだ → おしらせ → じゅんび完了）
        if tapButton(["はじめる", "Get started"], timeout: 8, overTabBar: true) {
            wait(2)
            // 身長・もくひょう体重：もくひょうを少し下げてみせる
            let minus = app.buttons.matching(NSPredicate(format: "label == %@", "−"))
            if minus.count >= 2 {
                safeTap(minus.element(boundBy: 1), overTabBar: true); wait(0.6)
                safeTap(minus.element(boundBy: 1), overTabBar: true); wait(1.2)
            }
            tapButton(["つぎへ", "Next"], overTabBar: true); wait(2.2)
            // おしらせ → 通知の許可（許可する）
            tapButton(["おしらせをうけとる", "Turn on reminders"], overTabBar: true)
            answerAlert(allow: true, timeout: 6)
            wait(2)
            tapButton(["きょうの体重をきろくする", "Log today’s weight"], overTabBar: true); wait(2)
        }

        // ホームの案内 → トラッキング許可（案内が終わってから出る）
        passCoachMarks()
        answerAlert(allow: false, timeout: 10)
        wait(2)

        // 過去の日を記録（記録シート：日付・体重・体脂肪率・タグ・メモ）
        if tapButton(["＋ 過去の日を入力", "+ Log a past day"]) {
            wait(2)
            tapButton(["外食", "Ate out"], overTabBar: true, front: true); wait(1)
            swipeSheet(up: true); wait(1.5)
            XCTAssertTrue(tapButton(["この日をきろくする", "Log this day"], overTabBar: true, front: true), "記録シートの「この日をきろくする」が見つからない")
            wait(2.5)
            closeReward()   // はじめての記録のごほうび
            for _ in 0..<4 { scroll(up: false) }   // きょうの体重のカードまでもどる
            wait(1)
        }

        // きょうを記録（少し減らして「運動した」）→ キャラが反応
        for _ in 0..<4 {
            tapButton(["0.1kg 減らす", "Decrease by 0.1kg"], timeout: 1); wait(0.35)
        }
        wait(0.8)
        tapButton(["運動した", "Worked out"]); wait(1.2)
        XCTAssertTrue(tapButton(["きろくする", "Log it"]), "ホームの「きろくする」が見つからない")
        wait(4)   // キャラの反応とセリフを見せる
        closeReward()

        // きょうのきぶん：ほかの顔をえらびなおす
        tapButton(["グッド", "Good"], contains: true, timeout: 2); wait(2.5)

        // ホームを下まで見せる（もくひょうまで・2週間グラフ・りれき）
        for _ in 0..<3 { scroll(up: true); wait(1.3) }
        for _ in 0..<3 { scroll(up: false) }
        wait(1)

        // グラフ：期間を切りかえ → カレンダーの日 → 日の詳細
        if tapButton(["グラフ", "Graph"]) {
            wait(1.5)
            passCoachMarks()
            tapButton(["1週", "1W"]); wait(1.8)
            tapButton(["3か月", "3M"]); wait(1.8)
            for _ in 0..<3 { scroll(up: true); wait(1.2) }
            let day = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", "kg")).firstMatch
            if day.waitForExistence(timeout: 2), safeTap(day) {
                wait(3)
                scroll(up: true); wait(1.5)
                scroll(up: false); wait(1)
                tapButton(["‹"], contains: true); wait(2)
            }
        }

        // キャラ：名前をつける → ずかんで顔を変える → ごほうびのお祝い
        if tapButton(["キャラ", "Buddy"]) {
            wait(1.5)
            passCoachMarks()
            let name = app.textFields.matching(NSPredicate(format: "label IN %@", ["キャラの名前", "Buddy’s name"])).firstMatch
            if name.waitForExistence(timeout: 2), !overlapsAd(name.frame) {
                name.tap(); wait(0.8)
                name.typeText(Locale.preferredLanguages.first?.hasPrefix("ja") == true ? "もち" : "Mochi")
                wait(0.8)
                // 入力欄の外（見出し）をタップしてキーボードを閉じる
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
                wait(2)
                closeReward()   // 名前をつけたごほうび
            }
            for _ in 0..<2 { scroll(up: true); wait(1.2) }
            if tapButton(["はじめての", "First"], contains: true, timeout: 1) {
                closeReward()
            }
            for _ in 0..<2 { scroll(up: true); wait(1.2) }
            tapButton(["どやっ", "Proud"], contains: true); wait(1.5)
            for _ in 0..<4 { scroll(up: false) }
            wait(2)
        }

        // せってい：通知をためす → ウィジェット → バックアップ → CSV
        if tapButton(["せってい", "Settings"]) {
            wait(1.5)
            passCoachMarks()
            scroll(up: true); wait(1.2)
            if tapButton(["通知をためす", "Test notification"], contains: true) {
                wait(4.5)   // 3秒後に届く通知を見せる
            }
            if tapButton(["ホーム画面ウィジェット", "Home Screen widget"], contains: true) {
                wait(3.5)
                tapButton(["アプリにもどる", "Back to app"], overTabBar: true); wait(1.5)
            }
            scroll(up: true); wait(1.2)
            if tapButton(["バックアップ", "Backup"], contains: true) {
                wait(3)
                tapButton(["‹ せってい", "‹ Settings"]); wait(1.5)
            }
            if tapButton(["CSVで書き出す", "Export as CSV"], contains: true) {
                wait(3)
                closeShareSheet()
            }
            for _ in 0..<3 { scroll(up: true); wait(1.2) }
            for _ in 0..<5 { scroll(up: false) }
            wait(1)
        }

        tapButton(["ホーム", "Home"])
        wait(3)
    }

    // MARK: - 起動

    /// iOS のホーム画面に戻ってから、アイコンをタップして起動する（審査の収録は「起動から」が条件）
    private func launchFromHomeScreen() {
        XCUIDevice.shared.press(.home)
        wait(1.5)
        // アイコンが2ページめ以降にあるときは、横にめくって探す
        for page in 0..<5 {
            for name in ["体重きろく", "Weight Buddy"] {
                let icon = springboard.icons[name]
                if icon.exists, icon.isHittable {
                    wait(1)
                    icon.tap()
                    return
                }
            }
            if page < 4 { springboard.swipeLeft(); wait(1) }
        }
        // ホーム画面にないときは、App ライブラリ（いちばん右のページ）の検索から開く
        let search = springboard.searchFields.firstMatch
        if search.waitForExistence(timeout: 2) {
            search.tap()
            wait(1)
            search.typeText(Locale.preferredLanguages.first?.hasPrefix("ja") == true ? "体重きろく" : "Weight Buddy")
            wait(1.5)
            for name in ["体重きろく", "Weight Buddy"] {
                let icon = springboard.icons[name].firstMatch
                if icon.exists, icon.isHittable { icon.tap(); return }
            }
        }
        // それでも見つからないときは、ふつうに起動する
        app.launch()
    }

    // MARK: - 案内・ダイアログ

    /// はじめての案内（コーチマーク）を「つぎへ」で最後まで進める。案内が出ていなければ何もしない
    private func passCoachMarks() {
        guard findButton(["スキップ", "Skip"], timeout: 3) != nil else { return }
        var count = 0
        while count < 8, findButton(["スキップ", "Skip"]) != nil {
            wait(2.4)   // 見ている人が読めるように少し待つ
            guard let next = findButton(["つぎへ", "Next", "はじめる", "Get started"]) else { break }
            // 案内は暗幕の上に出るので、タブバーには隠れない（広告だけ避ける）
            if !overlapsAd(next.frame) { next.tap() }
            count += 1
            wait(0.6)
        }
        wait(1)
    }

    /// springboard のダイアログ（通知の許可・トラッキング許可）に答える
    /// トラッキングは「App にトラッキングしないように要求」（1つめ）、通知は「許可」（いちばん下）
    private func answerAlert(allow: Bool, timeout: Double) {
        let alert = springboard.alerts.firstMatch
        guard alert.waitForExistence(timeout: timeout) else { return }
        wait(2)
        let buttons = alert.buttons
        let b = buttons.element(boundBy: allow ? max(0, buttons.count - 1) : 0)
        if b.exists { b.tap() }
        wait(1)
    }

    /// ごほうびのお祝い（「ありがとう！」）が出ていたら、少し見せてから閉じる
    private func closeReward(timeout: Double = 2.5) {
        var count = 0
        while count < 3, let b = findButton(["ありがとう！", "Thank you!"], timeout: count == 0 ? timeout : 1.5) {
            wait(3)
            safeTap(b)
            count += 1
            wait(1.5)
        }
    }

    /// CSV の共有シートを閉じる（閉じるボタンがなければ下へスワイプ）
    private func closeShareSheet() {
        for l in ["閉じる", "Close"] {
            let b = app.buttons[l].firstMatch
            if b.waitForExistence(timeout: 1.5), b.isHittable { b.tap(); wait(1.5); return }
        }
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.98)))
        wait(1.5)
    }

    // MARK: - 操作

    private func wait(_ s: Double) { Thread.sleep(forTimeInterval: s) }

    /// up: 上へ引いて下の内容を出す / false: 上の内容にもどす
    private func scroll(up: Bool) {
        let a = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.62 : 0.3))
        let b = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.3 : 0.62))
        a.press(forDuration: 0.05, thenDragTo: b)
        wait(0.5)
    }

    /// 記録シートの中をスクロールする（シートは画面の下のほうにあるので、少し下寄りで引く）
    private func swipeSheet(up: Bool) {
        let a = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.75 : 0.45))
        let b = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.45 : 0.75))
        a.press(forDuration: 0.05, thenDragTo: b)
        wait(0.5)
    }

    /// front: 同じ文字のボタンが裏の画面にもあるとき（記録シートの「外食」など）、手前（あとから出た画面）のほうを選ぶ
    private func findButton(_ labels: [String], contains: Bool = false, timeout: Double = 0, front: Bool = false) -> XCUIElement? {
        let end = Date().addingTimeInterval(timeout)
        repeat {
            for l in labels {
                let q = app.buttons.matching(NSPredicate(format: contains ? "label CONTAINS %@" : "label == %@", l))
                if front {
                    if let e = q.allElementsBoundByIndex.last(where: { $0.isHittable }) { return e }
                    continue
                }
                let e = q.firstMatch
                if e.exists && e.isHittable { return e }
            }
            if timeout > 0 { wait(0.25) }
        } while Date() < end
        return nil
    }

    /// 見つからなければ少し上へスクロールして探す。広告にかかるときは、かからなくなるまでスクロールしてから押す
    @discardableResult
    /// overTabBar: タブバーとバナーを覆って手前に出る画面（はじめの設定・記録シート・ウィジェットの紹介）。
    /// 下のほうのボタンもその画面のものなので、そのまま押してよい（広告には触れない）
    private func tapButton(_ labels: [String], contains: Bool = false, timeout: Double = 3, overTabBar: Bool = false, front: Bool = false) -> Bool {
        var found = findButton(labels, contains: contains, timeout: timeout, front: front)
        // 下へ3回、それでもなければ上へもどりながら探す
        var looked = 0
        while found == nil && looked < 8 {
            scroll(up: looked < 3)
            looked += 1
            found = findButton(labels, contains: contains, timeout: 0.5, front: front)
        }
        guard let b = found else { return false }
        var e = b
        var tries = 0
        while isCovered(e, overTabBar: overTabBar) && tries < 4 {
            scroll(up: true)
            tries += 1
            if let again = findButton(labels, contains: contains, front: front) { e = again }
        }
        return safeTap(e, overTabBar: overTabBar)
    }

    /// 広告にかからないときだけ押す
    @discardableResult
    private func safeTap(_ e: XCUIElement, overTabBar: Bool = false) -> Bool {
        guard e.exists, !isCovered(e, overTabBar: overTabBar) else { return false }
        e.tap()
        return true
    }

    private static let tabLabels: Set<String> = ["ホーム", "グラフ", "キャラ", "せってい", "Home", "Graph", "Buddy", "Settings"]

    /// 広告にかかるか、タブバーの裏に隠れているか（隠れたボタンを押すと、タブのほうが押されてしまう）
    private func isCovered(_ e: XCUIElement, overTabBar: Bool = false) -> Bool {
        if overTabBar { return false }
        let f = e.frame
        if overlapsAd(f) { return true }
        if Self.tabLabels.contains(e.label) { return false }
        let tab = app.buttons.matching(NSPredicate(format: "label IN %@", Array(Self.tabLabels))).allElementsBoundByIndex
            .map(\.frame).filter { $0.minY > app.frame.height * 0.7 }.map(\.minY).min()
        if let top = tab, f.maxY > top - 4 { return true }
        return false
    }

    /// 画面の下のほうにあるバナー広告（中身は Web ビュー）にかかるか
    private func overlapsAd(_ frame: CGRect) -> Bool {
        let h = app.frame.height
        for v in app.webViews.allElementsBoundByIndex where v.exists {
            let f = v.frame
            if f.minY > h * 0.5 && f.height < 160 && f.insetBy(dx: -4, dy: -6).intersects(frame) { return true }
        }
        return false
    }
}
