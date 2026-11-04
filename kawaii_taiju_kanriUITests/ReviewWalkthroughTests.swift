//
//  ReviewWalkthroughTests.swift
//  kawaii_taiju_kanriUITests
//
//  App Review に出す画面収録用に、アプリの使い方を最初から最後まで自動で通すテスト。
//  （審査対応メモ「体重きろく_審査対応.md」§2-2 の流れ。スラッシュの ReviewWalkthroughTests と同じ作り）
//
//  流れ（審査に必要な最低限。約3分）
//  ホーム画面からアイコンで起動 → はじめの設定（通知の許可）→ ホームの案内 → トラッキング許可（ATT）
//  → 過去の2日を記録（飲み会で増えて「もどるまで見守り」が出る）
//  → せってい（見ないモード）→ グラフ（カレンダー・日の詳細）→ キャラ
//  → ホーム：きょうを記録して、もやもやがはれる（紙ふぶき）→ ごほうびの日せんげん → シェアカード
//
//  記録は3回で、3回目は最後にする。全画面広告は3回記録したあとのタブ切りかえで出る作りなので、
//  3回目のあとはタブを切りかえない（収録の途中で広告が出ないように）。
//
//  使い方
//  1. iPhone を Mac につなぎ、ロックを解除しておく
//  2. アプリを削除して、入れ直しておく。開かないこと（はじめの設定と各タブの案内、許可のダイアログから撮るため。削除すると記録は消える）。
//     入っていない状態から実行すると、アイコンがまだなくてタップできず、アイコンを使わない起動になってしまう
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
        wait(1.5)

        // はじめの設定（あいさつ → からだ → おしらせ → じゅんび完了）
        if tapButton(["はじめる", "Get started"], timeout: 8, overTabBar: true) {
            wait(1)
            tapButton(["つぎへ", "Next"], overTabBar: true); wait(1)
            tapButton(["おしらせをうけとる", "Turn on reminders"], overTabBar: true)
            answerAlert(allow: true, timeout: 6)
            wait(1)
            tapButton(["きょうの体重をきろくする", "Log today’s weight"], overTabBar: true); wait(1)
        }

        // ホームの案内 → トラッキング許可（案内が終わってから出る）
        passCoachMarks()
        answerAlert(allow: false, timeout: 10)
        wait(1)

        // 過去の2日を記録：おとといの記録 → きのうは飲み会で増えた
        if tapButton(["＋ 過去の日を入力", "+ Log a past day"]) {
            wait(1)
            tapButton(["前の日", "Previous day"], overTabBar: true, front: true); wait(1)
            swipeSheet(up: true)
            XCTAssertTrue(tapButton(["この日をきろくする", "Log this day"], overTabBar: true, front: true), "記録シートの「この日をきろくする」が見つからない")
            wait(1.5)
            closeReward()   // はじめての記録のごほうび
        }
        if tapButton(["＋ 過去の日を入力", "+ Log a past day"]) {
            wait(1)
            for _ in 0..<5 {
                tapButton(["0.1kg 増やす", "Increase by 0.1kg"], timeout: 1, overTabBar: true, front: true)
            }
            swipeSheet(up: true)
            tapButton(["飲み会", "Night out"], overTabBar: true, front: true); wait(0.8)
            XCTAssertTrue(tapButton(["この日をきろくする", "Log this day"], overTabBar: true, front: true), "記録シートの「この日をきろくする」が見つからない")
            wait(1.5)
        }

        // もどるまで見守り：増えたあとの雲のカードを見せる
        XCTAssertNotNil(scrollTo(["もどるまで見守り", "Bounce-back watch"]), "「もどるまで見守り」のカードが出ていない")
        wait(2)

        settingsSection()
        graphSection()
        charaSection()
        finishOnHome()
    }

    // MARK: - せってい

    /// 見ないモード：オンにしてホームを見せ、もどしてオフにする。ほかの項目は、スクロールで見せるだけ
    private func settingsSection() {
        guard tapButton(["せってい", "Settings"]) else { return }
        wait(1)
        passCoachMarks()
        XCTAssertTrue(setSwitch(["体重の数字をかくす", "Hide my weight"], on: true), "見ないモードのスイッチが押せない")
        wait(1.5)
        if tapButton(["ホーム", "Home"]) {
            wait(2.5)
            tapButton(["せってい", "Settings"]); wait(1)
        }
        XCTAssertTrue(setSwitch(["体重の数字をかくす", "Hide my weight"], on: false), "見ないモードをオフにできない")
        wait(1)
        scroll(up: true); wait(1)
        scroll(up: true); wait(1)
    }

    // MARK: - グラフ

    private func graphSection() {
        guard tapButton(["グラフ", "Graph"]) else { return }
        wait(1)
        passCoachMarks()
        for _ in 0..<3 { scroll(up: true) }
        wait(0.5)
        let day = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", "kg")).firstMatch
        if day.waitForExistence(timeout: 2), safeTap(day) {
            wait(2)
            tapButton(["‹"], contains: true); wait(1)
        }
    }

    // MARK: - キャラ

    private func charaSection() {
        guard tapButton(["キャラ", "Buddy"]) else { return }
        wait(1)
        passCoachMarks()
        scrollTo(["はらした もやもや", "Clouds cleared"]); wait(2)
    }

    // MARK: - ホーム（3回目の記録。このあとはタブを切りかえない）

    private func finishOnHome() {
        guard tapButton(["ホーム", "Home"]) else { return }
        wait(1.5)

        // 少し減らして、もとの体重にもどす → 記録するともやもやがはれる
        for _ in 0..<4 {
            tapButton(["0.1kg 減らす", "Decrease by 0.1kg"], timeout: 1)
        }
        wait(0.5)
        XCTAssertTrue(tapButton(["きろくする", "Log it"]), "ホームの「きろくする」が見つからない")
        wait(3.5)   // キャラの反応と紙ふぶきを見せる
        closeReward(timeout: 1)
        XCTAssertNotNil(scrollTo(["もやもや、はれた", "cloud cleared"]), "もやもやがはれたカードが出ていない")
        wait(1.5)

        // ごほうびの日せんげん
        tapButton(["せんげんする", "Declare"]); wait(2)

        // シェアカード：数字なしのカードを見せて閉じる（共有メニューは開かない）
        for _ in 0..<3 { scroll(up: false) }
        if tapButton(["シェア", "Share"], contains: true) {
            wait(2.5)
            tapButton(["とじる", "Close"], overTabBar: true, front: true)
        }
        wait(2)
    }

    // MARK: - 起動

    /// iOS のホーム画面に戻ってから、アイコンをタップして起動する（審査の収録は「起動から」が条件）
    private func launchFromHomeScreen() {
        XCUIDevice.shared.press(.home)
        wait(1.5)
        // 入れた直後はアイコンがまだないことがあるので、ホーム画面に出るまで待つ
        let icon = springboard.icons.matching(NSPredicate(format: "label IN %@", ["たいかん！", "Taikan!"])).firstMatch
        _ = icon.waitForExistence(timeout: 10)
        // アイコンが2ページめ以降にあるときは、横にめくって探す
        for page in 0..<5 {
            for name in ["たいかん！", "Taikan!"] {
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
            search.typeText(Locale.preferredLanguages.first?.hasPrefix("ja") == true ? "たいかん！" : "Taikan!")
            wait(1.5)
            for name in ["たいかん！", "Taikan!"] {
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
            wait(1.5)   // 見ている人が読めるように少し待つ
            guard let next = findButton(["つぎへ", "Next", "はじめる", "Get started"]) else { break }
            // 案内は暗幕の上に出るので、タブバーには隠れない（広告だけ避ける）
            if !overlapsAd(next.frame) { next.tap() }
            count += 1
            wait(0.3)
        }
        wait(0.5)
    }

    /// springboard のダイアログ（通知の許可・トラッキング許可）に答える
    /// トラッキングは「App にトラッキングしないように要求」（1つめ）、通知は「許可」（いちばん下）
    private func answerAlert(allow: Bool, timeout: Double) {
        let alert = springboard.alerts.firstMatch
        guard alert.waitForExistence(timeout: timeout) else { return }
        wait(1)
        let buttons = alert.buttons
        let b = buttons.element(boundBy: allow ? max(0, buttons.count - 1) : 0)
        if b.exists { b.tap() }
        wait(1)
    }

    /// ごほうびのお祝い（「ありがとう！」）が出ていたら、少し見せてから閉じる
    private func closeReward(timeout: Double = 2.5) {
        var count = 0
        while count < 3, let b = findButton(["ありがとう！", "Thank you!"], timeout: count == 0 ? timeout : 1.5) {
            wait(1.5)
            safeTap(b)
            count += 1
            wait(0.8)
        }
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

    /// カードの見出しなどの文字が見えるところまでスクロールする
    @discardableResult
    private func scrollTo(_ labels: [String]) -> XCUIElement? {
        for i in 0..<9 {
            for l in labels {
                let e = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", l)).firstMatch
                if e.exists, e.isHittable, !isCovered(e) { return e }
            }
            scroll(up: i < 6)
        }
        return nil
    }

    /// スイッチを on にする（すでにそうなら何もしない）。見えて押せるところまでスクロールする
    private func setSwitch(_ labels: [String], on: Bool) -> Bool {
        let e = app.switches.matching(NSPredicate(format: "label IN %@", labels)).firstMatch
        guard e.waitForExistence(timeout: 3) else { return false }
        var tries = 0
        while (!e.isHittable || isCovered(e)) && tries < 10 {
            scroll(up: e.frame.midY > app.frame.height * 0.4)
            tries += 1
        }
        if Self.isOn(e) == on { return true }
        guard safeTap(e) else { return false }
        wait(0.8)
        return Self.isOn(e) == on || on   // オンにするときは、許可の画面が重なって読めないことがある
    }

    private static func isOn(_ e: XCUIElement) -> Bool {
        ["オン", "On", "1"].contains(e.value as? String ?? "")
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
