# 体重きろく — App Store 掲載情報（日英併記）

作成日: 2026年10月29日
対象: iOS版「かわいい体重きろく」（ホーム画面の表示名は「体重きろく」・英語名 Weight Buddy・`jp.jntech.kawaii-taiju-kanri` / v1.0）
戦略の根拠: [体重きろく_ASO戦略.md](体重きろく_ASO戦略.md)

App Store Connect にそのまま貼れる形でまとめています。コードブロックの中が貼り付ける本文です。

> **ロケールの設定**
> App Store Connect で **日本語** と **英語（U.S.）** の2つのローカリゼーションを作ってください。
> 日本ストアは日本語に加えて **English (U.S.)** のキーワードも追加でインデックスするため、
> 英語版を入れるだけで日本ストアのキーワード枠が実質2倍になります。
> **English (U.K.) ではありません**（日本は U.K. の例外国です）。

---

## 早見表

| 項目 | 日本語 | 英語（U.S.） |
|---|---|---|
| タイトル | かわいい体重きろく：キャラが反応する体重記録・ダイエット | Weight Buddy: Kawaii Tracker |
| 文字数 | 28 / 30 | 28 / 30 |
| サブタイトル | 毎日ゆるく続く。表情とグラフ・カレンダーで見える化 | Diet log with a pal who reacts |
| 文字数 | 25 / 30 | 30 / 30 |
| キーワード文字数 | 95 / 100 | 100 / 100 |
| プロモーションテキスト | 97 / 170 | 152 / 170 |
| カテゴリ | 主: ヘルスケア／フィットネス / 副: ライフスタイル | Primary: Health & Fitness / Secondary: Lifestyle |
| 年齢レーティング | 4+ | 4+ |
| 価格 | 無料・App内課金なし・**広告あり**（AdMob のバナーと全画面広告） | Free, no in-app purchases, **with ads** |

---

## 1. タイトル（30文字）

### 日本語

```
かわいい体重きろく：キャラが反応する体重記録・ダイエット
```

28文字。`かわいい` `体重` `体重きろく` `かわいい体重きろく` `キャラ` `反応` `体重記録` `記録` `ダイエット` を獲得。

- ホーム画面の表示名は「体重きろく」のままで、App Store の名前はその前に「かわいい」を付けています。表示名が名前に含まれているので、審査で「表示名と掲載名がかけ離れている」とは言われません。
- 「かわいい」で探す人（「かわいい 体重管理」など）に出やすくし、ふつうの言葉の「体重きろく」だけより、名前で探してもらいやすくしています。
- 表示名の「きろく」はひらがななので、検索の多い漢字の「体重記録」も名前に入れています。
- 代替案は ASO 戦略の §5（「体重きろく：かわいい体重記録・ダイエット管理」など）。

### English (U.S.)

```
Weight Buddy: Kawaii Tracker
```

28文字。`Weight` `Buddy` `Kawaii` `Tracker`。

> **注意**：米国ストアに「WeightBuddy: Calorie Tracker」があります。App Store Connect は**ほかのアプリと同じ名前**を受け付けないため、「Weight Buddy」単独では登録できない可能性が高く、後ろに語を付けています。混同を避けたい場合は、表示名（`kawaii_taiju_kanri/en.lproj/InfoPlist.strings`）ごと別の英語名にするのが安全です。

---

## 2. サブタイトル（30文字）

### 日本語

```
毎日ゆるく続く。表情とグラフ・カレンダーで見える化
```

25文字。名前と重ならない `毎日` `ゆるく` `続く` `表情` `グラフ` `カレンダー` `見える化` を獲得（「かわいい」は名前に入れたので外しました）。

### English (U.S.)

```
Diet log with a pal who reacts
```

30文字。代替：`A cute pal for daily weigh-ins`（30文字）。

---

## 3. カテゴリ

| | 設定 |
|---|---|
| 主カテゴリ | **ヘルスケア／フィットネス** |
| 副カテゴリ | **ライフスタイル** |
| 年齢レーティング | **4+** |

- 競合（あすけん・SmartDiet・ハミング・シンプルダイエット・カナヘイなど）はいずれも **ヘルスケア／フィットネス** にいます。同じ棚に並ばないと比較の土俵に乗れないので、主戦場はここです。
- 副カテゴリは、かわいいキャラの雰囲気に合う **ライフスタイル** にしました。
- **4+ を想定しています。** 暴力表現・アプリ内課金・ユーザー生成コンテンツ・外部とのやりとりはありません。年齢レーティングの質問票の「医療・治療の情報」は「なし」です（医療上の診断・助言はしません）。
- **広告（AdMob のバナーと全画面広告）があります。** 年齢レーティングの質問票で「広告」を「あり」と答えてください。広告があっても 4+ にはできます。

---

## 4. プロモーションテキスト（170文字）

検索インデックスには乗りませんが、**審査なしでいつでも差し替えられます**。概要の上に出るので、季節やアップデートに合わせて回してください。

### 日本語（リリース時）

```
まいにちの体重に、キャラが反応。減った日はいっしょによろこび、増えた日はやさしく受けとめてくれます。グラフ・カレンダー・ホーム画面ウィジェットつき。アカウント登録なしで、きょうから始められます。
```

97文字。

### English (U.S.)

```
Your buddy reacts to every weigh-in: it cheers when you go down and comforts you when you go up. With graphs, a calendar and widgets. No sign-up needed.
```

152文字。

### ストック（季節・アップデート用）

| 時期 | 日本語 | English (U.S.) |
|---|---|---|
| 年始 | ことしこそ、続けられる体重記録を。増えた日も責めないキャラが、毎朝いっしょにはかってくれます。 | Make this the year you keep logging. Your buddy never scolds you, even on the days you go up. |
| 夏前 | 夏までに、ゆっくり確実に。いまのペースだと、いつごろもくひょうに届くかも教えてくれます。 | Slow and steady before summer. See when you'll reach your goal at your current pace. |
| アップデート | 新しいごほうびが増えました。7日れんぞく・1kgへった・もくひょう達成で、キャラといっしょにお祝い。 | New rewards! Celebrate 7-day streaks, your first 1kg and reaching your goal with your buddy. |

---

## 5. 概要（Description・4000文字まで）

検索には効きませんが、入れてもらう決め手です。最初の3行（「さらに表示」の前）に体験と気軽さを言い切ります。

### 日本語

```
まいにちの体重に、キャラが反応。
減った日はいっしょによろこんで、増えた日はやさしく受けとめてくれる。
ちいさな相棒といっしょに続ける、かわいい体重記録アプリです。

■ 体重でかわる14の表情
前の7日の平均とくらべて、減ったか増えたかでキャラの表情が変わります。
0.3kg へった日は「るんるん」、いちばん軽い記録を更新したら「どやっ」、少し増えた日は「こまった」。
日々の水分の上下で表情がころころ変わらないので、増えた日も落ちこまずに続けられます。
気分に合わない日は、「きょうのきぶん」でえらびなおせます。

■ 増えた理由も、ちゃんと受けとめる
飲み会・外食・寝不足・のんびり・運動した、のタグとひとことメモ。
「飲み会たのしかった？2〜3日で戻るよ」と、キャラがやさしく声をかけてくれます。
きびしめにしたい人には「きびしめモード」もあります。

■ うつりかわりがひと目でわかる
・1週・1か月・3か月のグラフと、7日平均の線
・カレンダーに、その日の顔と体重
・BMI と体脂肪率
・日の詳細で、前後1週間の流れとメモをふりかえり
・過去の日も、あとから入力できます

■ もくひょうまでの道のり
スタートからもくひょうまで、いま何%進んだか。
いまのペースだと、いつごろゴールできそうかも教えてくれます。

■ 続けるのが楽しくなる
・はじめてのきろく、7日れんぞく、1kgへった、もくひょう達成などのメダル
・毎日きろくするほど上がる、キャラとの「なかよし度」
・どの顔に何回なったかがわかる「ひょうじょうずかん」
・キャラに名前をつけられます

■ 毎日のおともに
・決まった時間に、キャラのセリフでおしらせ（記録ずみの日はお休み）
・ホーム画面ウィジェット（小・中）で、きょうの表情と体重、連続日数
・iCloud に預けておけば、機種変更しても続きから（使うかどうかは選べます）
・CSV で書き出して、表計算やほかのアプリでも

■ 安心して使える
・アカウント登録なし。インストールしてすぐ始められます
・記録は端末の中に保存。開発者のサーバーには送りません
・日本語と英語に対応

※ 本アプリは体重の記録とふりかえりのためのものです。医療上の診断や助言は行いません。BMI やキャラのセリフは目安としてご利用ください。
```

### English (U.S.)

```
Your buddy reacts to every weigh-in.
It celebrates with you when you go down and gently cheers you on when you go up.
A cute weight log you can actually keep up with, together with your little buddy.

■ 14 faces that change with your weight
Buddy's face changes depending on whether you went up or down compared to the average of the previous 7 days.
Down 0.3kg? "Happy." A new lightest record? "Proud." Up a little? "Uh-oh."
Daily water swings won't keep changing the face, so a heavier day won't knock you off track.
If the face doesn't match your mood, pick another with "Today's mood."

■ It understands why you went up
Tag a day with Night out, Ate out, Short sleep, Lazy day or Worked out, and add a quick note.
"Fun night out? It'll go back in 2–3 days," Buddy says.
Want it tougher? Turn on Strict mode.

■ See your progress at a glance
• Graphs for 1 week, 1 month or 3 months, with a 7-day average line
• A calendar with each day's face and weight
• BMI and body fat
• Day details with the week before and after, plus your notes
• Log past days anytime

■ Your path to the goal
See how far you've come from your start to your goal,
and when you'll get there at your current pace.

■ Fun that keeps you going
• Medals for your first log, a 7-day streak, losing 1kg, reaching your goal and more
• A friendship level that grows the more you log
• A Face collection that shows how many times each face appeared
• Give your buddy a name

■ Part of your day
• A reminder at the time you choose, in Buddy's words (it takes the day off once you've logged)
• Home Screen widgets (small and medium) with today's face, weight and streak
• Back up to iCloud and pick up where you left off on a new phone (optional)
• Export to CSV for spreadsheets and other apps

■ Use it with peace of mind
• No account needed. Start right after you install
• Your logs stay on your device and are never sent to the developer's servers
• Available in Japanese and English

Note: This app is for logging and looking back on your weight. It does not provide medical diagnosis or advice. Please treat the BMI and Buddy's comments as a rough guide.
```

---

## 6. キーワード（100文字）

カンマ区切り・スペースなし。名前・サブタイトルの語は入れていません（名前の「体重」と組み合わさるので、`管理` で「体重管理」に当たります）。

### 日本語（95文字）

```
管理,BMI,体脂肪率,目標,減量,痩せる,習慣化,シンプル,無料,ウィジェット,通知,リマインド,メモ,キャラクター,癒し,健康,体重計,朝,ログイン不要,振り返り,推移,平均,体型,相棒
```

### English (U.S.)（100文字）

```
weight,loss,lose,bmi,body,fat,goal,scale,graph,calendar,widget,reminder,habit,mood,streak,health,log
```

- `weight` `log` は英語の名前・サブタイトルと重なりますが、日本ストアでは英語の名前が使われないため、日本ストアで英語の検索を拾う目的で残しています。米国ストアを優先するなら `diary,kawaii` などに入れかえてください。
- 広告があるので、`広告なし` は使いません。

### 使ってはいけない語（商標）

名前・サブタイトル・キーワード・概要のどこにも入れません（審査ガイドライン 2.3.7）。

- あすけん、SmartDiet、ハミング、FiNC、カロミル、RecStyle、Yasegram、Happy Scale、WeightBuddy
- ハローキティ、マイメロディ、サンリオ、カナヘイ、ピスケ
- **要確認**：レコーディングダイエット（商標登録の可能性。J-PlatPat で確認するまで使わない）

---

## 7. App Store Connect に入れるその他の項目

| 項目 | 日本語 | English (U.S.) |
|---|---|---|
| サポートURL | https://（紹介ページの URL） | 同左 |
| マーケティングURL | https://（紹介ページの URL） | 同左 |
| プライバシーポリシーURL | https://（紹介ページ）#privacy | https://（紹介ページ）?lang=en#privacy |
| 著作権 | 2026 Jun Tsuda | 2026 Jun Tsuda |
| 問い合わせ先 | angocat215@gmail.com | 同左 |

紹介ページは `web/` にあります。公開後、URL をここに差し替えてください。

### App のプライバシー（データ収集の申告）

**広告（Google Mobile Ads SDK）を入れたので、「データの収集なし」では申告できません。**
Google の案内（AdMob の「Apple の App Store のデータ開示」ページ）を見ながら、次の内容で申告します（ぽこりんと同じ）。

| データの種類 | 用途 | ユーザーに関連付け | トラッキング |
|---|---|---|---|
| 識別子（デバイス ID＝IDFA など） | サードパーティ広告、アナリティクス | する | する（ATT で許可した人のみ） |
| 位置情報（おおよその位置：IP アドレスから） | サードパーティ広告、アナリティクス | する | する |
| 使用状況データ（製品の操作・広告データ） | サードパーティ広告、アナリティクス | する | する |
| 診断（クラッシュ・パフォーマンスデータ） | アナリティクス | しない | しない |

- 体重の記録・体脂肪率・メモなどの健康に関するデータは、開発者も Google も受け取りません（端末の中だけ）。「健康とフィットネス」の項目は申告しません
- 開発者のサーバーはありません。開発者が自分で集める情報はありません
- 広告のために Google が上記の情報を扱います。ATT（トラッキングの許可）を断った人には、IDFA は使われません
- アカウント登録がありません
- iCloud バックアップは**任意**で、同期先は Apple の iCloud キーバリューストア。開発者は内容を参照できません

### プレビュー動画・画像

| 素材 | ファイル |
|---|---|
| プレビュー動画（886×1920・約29秒） | `AppStore/preview/out/preview_ja.mp4` / `preview_en.mp4` |
| プロダクトページのヘッダ（3840×1646） | `AppStore/header/out/ja/header.png` / `en/header.png` |
| スクリーンショット | 未作成（構成案は ASO 戦略 §10） |

---

## 8. 数と名前を書いている場所（仕様を変えたら直す）

| 書いている数・名前 | 場所 |
|---|---|
| 14の表情 | 概要、紹介ページ（`web/`）、ASO 戦略 §10 |
| 0.3kg・0.8kg・7日平均・2〜3日で戻るよ | 概要（表情の例・タグのセリフ） |
| タグ5つ（飲み会・外食・寝不足・のんびり・運動した） | 概要 |
| 1週・1か月・3か月 | 概要 |
| メダル（7日れんぞく・1kgへった・もくひょう達成） | 概要、プロモーションテキストのストック |
| ウィジェット（小・中） | 概要 |
| アカウント登録なし・端末の中に保存 | 概要、プロモーションテキスト、App のプライバシー |
| 課金なし・広告あり | 早見表の価格、カテゴリの注記、App のプライバシー、紹介ページ |
| 英語名 Weight Buddy | タイトル、`InfoPlist.strings`、紹介ページ、ヘッダ画像・プレビュー動画（英語版） |
