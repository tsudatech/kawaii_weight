# たいかん！（Taikan!・kawaii_taiju_kanri）

SwiftUI の iPhone アプリ ＋ ホーム画面ウィジェット（`KawaiiWidget/`）。見た目の参考元は `kawaii-weight-demo/`（HTML 版）。

## ローカライズ

- 日本語の文言をそのままキーにして、`L("…")` / `LF("…", 値)` で訳を引く（`Shared/Localization.swift`）。
  `Text("…")` に直接書かず、`Text(L("…"))` にする（デバッグ用の `--lang` の切りかえが効かなくなるため）。
- 文言を足したら `Shared/ja.lproj` と `Shared/en.lproj` の両方の `Localizable.strings` に追加する。
  英語の単数・複数は `Shared/en.lproj/Localizable.stringsdict`。`Shared/` はアプリとウィジェットの両方に入る。
- 追加したら `python3 tools/check_strings.py` で足りないキーがないか確かめる（最後に OK が出ればよい）。
- 日のタグ（`DayTag.all`）は日本語のまま保存するキー。表示するときだけ `L(tag)` で訳す。キーは変えないこと。
  「きょうのこと」に出すタグの一覧は `AppSettings.tags`（せってい › タグ・`Views/Settings/TagsView.swift`。はじめは `DayTag.all`）。
  自分で足したタグは訳がないので、`L(tag)` でも書いたとおりに出る。一覧はせっていなので端末ごと（iCloud には預けない）。
- 日付は `Fmt`（`Shared/Formatters.swift`）が言語ごとに出し分ける（10月28日（水） / Wed, Oct 28）。
- アプリの表示名は `kawaii_taiju_kanri/{ja,en}.lproj/InfoPlist.strings`。
  表示名は日本語「たいかん！」・英語「Taikan!」。アプリの中の名前は `L("たいかん！")`（`Localizable.strings`）。
- 開発中は起動引数 `--lang en` / `--lang ja` で、端末の設定を変えずに言語を切りかえられる（デバッグビルドのみ・保存しない）。

## はじめての案内（コーチマーク）

- 初回起動は、まず「はじめの設定」（`Views/Onboarding/OnboardingView.swift`、4ステップ）。
  終わったあと、各タブをはじめて開いたときに、そのタブの案内（コーチマーク）を出す（ぽこりんと同じ作り）。
- 案内の部品は `Views/Onboarding/CoachMarks.swift`。暗幕に穴を開けて部品を見せ、どこを押しても次へ・「スキップ」で最後まで飛ばす。
- 見せる部品には `.coachTarget("home.hero")` のように印をつけ、ページは `RootView.coachPages` に書く。
  画面に見えていない部品のページは飛ばすので、スクロールしないと見えない部品は選ばないこと。
- 見たかどうかはタブごとに UserDefaults（`onboarding.seen.<tab>.v1`）。「すべてのデータを消す」で未読にもどる。
  デバッグビルドでは、せってい › デバッグ「案内をもう一度見る」で未読にもどせる。起動引数 `--coach-page N` で N ページ目から見られる。
- 記録シート・日の詳細・お祝いなどが出ているあいだは出さない（閉じてから出す）。

## iCloud バックアップ

- iCloud のキーバリューストアに、体重の記録・ごほうび・キャラの名前を預ける（`Store/ICloudBackup.swift`、ぽこりんと同じ考え方）。
  せってい（身長・もくひょう・通知・表示）と案内の既読は端末ごとに残す。画面は せってい › データ › バックアップ（`Views/Settings/BackupView.swift`）。
- 起動時・記録の保存時（`WeightStore.saveNow`）・ほかの端末の変更時に合わせる（`BackupData.merge`）。
  - 同じ日の記録は `updatedAt`（書きかえた時刻）が新しいほう。消した日は `DeletedEntry`（消した時刻）を残し、ほかの端末から戻ってこないようにする。
  - `updatedAt` と消した印は `WeightStore.entries` の didSet で自動で付く。iCloud から入れるとき・起動時の読みこみでは付けない（`applyingBackup`）。
    ここを外すと、起動するたびに全部の記録が「いま書きかえた」扱いになり、合わせ方が壊れる。
  - 時刻は秒で切りそろえる（保存ファイルは ISO 8601 で端数が落ちるため、そろえないと毎回ちがうと判定される）。
  - ごほうびは足し合わせ、名前はあとで変えたほう。
  - ごほうびの日は `TreatMark`（`on` と変えた時刻）で、日ごとにあとで変えたほう。とりけしも消さずに `on: false` で残す。
- 預ける項目を足したら `BackupData`（`init(from:)` も）・`merge`・`WeightStore.backupData` / `applyBackup` の4か所に足すこと。
  `BackupData` は古い中身も読めるように `decodeIfPresent` にする（読めないと空とみなして、合わせずに上書きしてしまう）。
- 「すべてのデータを消す」は、合わせずに iCloud 側も上書きする（`replaceRemote`。合わせるとごほうびなどが戻ってくるため）。
- 権限は `kawaii_taiju_kanri.entitlements`（`com.apple.developer.ubiquity-kvstore-identifier`）。

## 差別化の機能（デモ v0.5 から）

- もどるまで見守り：`WeightStore.watches`。「飲み会」「外食」タグ、ごほうびの日とその翌朝に、その前の7日平均より 0.1kg を超えて増えた日から、平均＋0.1kg 以下にもどるまで。2週間もどらなければ静かに終わる（失敗にしない）。もどった日の顔は `judge` で「るんるん」にする（どの画面でも同じ顔にするため）。`watches` から `judge` を呼ばないこと（呼び合いになる）。
- ごほうびの日：`WeightStore.treats`・`treatHit`（その日と翌日）。増えても `cozy` で受け止める。
- 体重よそう（せっていでオンにした人だけ）：記録の前は `pendingGuess`、記録したら `WeightEntry.guess` / `bot` に移す。記録シートは前のよそうを残す（`WeightStore.save`）。
- 見ないモード（`settings.hideNumbers`）：体重の数字には `.hiddenNumber()` を付ける。**数字を出す画面を足したら忘れないこと。** 数字を文に入れるときは、かくすときの文言も用意する。ウィジェットはぼかさず「••.•」に置きかえる。
- シェア（`Views/Share/ShareCardView.swift`）：`ImageRenderer` で 1080×1350 の画像を作り、`ShareLink` で共有メニューへ。数字は「のせる」を選んだときだけ。
- ヘルスケア（`Store/HealthSync.swift`）：**いまの提出には入れていない**（iCloud バックアップと併存すると、ガイドライン 5.1.3 に触れるおそれがあるため）。コードは `#if HEALTH_SYNC` で残してある。
  もどすときは、コンパイル条件 `HEALTH_SYNC` を定義し、`com.apple.developer.healthkit`（entitlements）と `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription`（pbxproj の INFOPLIST_KEY・InfoPlist.strings）を足す。紹介ページ・掲載情報・審査メモ・UI テストも直す。データは広告に渡さない。
- ロック画面（`KawaiiWidget/LockScreenWidgets.swift`）：表情・7日平均・もくひょう％と、「体重をきろく」のコントロール（`Shared/OpenRecordIntent.swift`。アプリを開いて入力へ）。
- Siri・ショートカット（`Intents/WeightIntents.swift`）：言いかたは `{ja,en}.lproj/AppShortcuts.strings`。アプリ名を入れた言いかたしか登録できないので「たいかん！で体重をきろく」→ 何キロかを聞く、の流れ。

## 広告（Google AdMob・`kawaii_taiju_kanri/Ads/`）

- かわいい日記（kawaiidiary）の広告と同じ作り。バナー（`AdBannerView`）と全画面広告（`InterstitialAdManager`）。ID は `AdMobConfig`（Debug は Google のテスト用 ID）。
  アプリ ID はリポジトリ直下の `Info.plist`（`GADApplicationIdentifier`・`SKAdNetworkItems`）と必ずそろえる。
- **審査前・在庫なしのときは何も出ない作り。** バナーは SDK の初期化が済んで広告が届くまで高さ0（場所を取らない）、全画面広告は読めたときだけ出す。
- バナーはタブバーの上（`TabBar`）。スクロールする画面は、下の余白を `110 + AdService.shared.bannerHeight` にする（`ScreenScroll`・日の詳細・バックアップ）。
  新しくスクロールする画面を足したら、この余白を忘れないこと。
- 全画面広告は、体重を3回記録・修正したあと、つぎにタブを切りかえたときだけ（`AdService.showInterstitialIfDue`）。
  記録した直後（キャラの反応・ごほうびのお祝い）やシート・案内の上には出さない。
- 同意（UMP）と ATT は、はじめの設定とホームの案内が済んでから1回だけ（`RootView` の `canStartAds`）。
- 紹介動画の自動の流れ（`--preview-tour`）では出さない（`AdService.isEnabled`）。
- 広告の種類や出し方を変えたら、紹介ページ（`web/`）のプライバシーポリシーと、App Store の「App のプライバシー」（`体重きろく_AppStore掲載情報.md` §7）も直すこと。
