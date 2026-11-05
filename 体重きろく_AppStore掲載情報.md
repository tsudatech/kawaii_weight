# たいかん！ — App Store 掲載情報（日英併記）

作成日: 2026年11月4日（10月29日版「かわいい体重きろく」を書き直し）
対象: iOS版「たいかん！」（ホーム画面の表示名は日本語「たいかん！」・英語「Taikan!」・`jp.jntech.kawaii-taiju-kanri` / v1.0）

App Store Connect にそのまま貼れる形でまとめています。コードブロックの中が貼り付ける本文です。

> **今回の書き直しの方針**
> 4.3（スパム）でリジェクトされたので、「かわいい〜」シリーズに見える言葉（名前の「かわいい」など）を外しました。
> そのうえで、このアプリにしかない **もどるまで見守り・ごほうびの日・見ないモード** を、名前のすぐ後・プロモーションテキスト・概要の最初・審査への返信文（`体重きろく_審査対応.md`）で前に出しています。

> **ロケールの設定**
> App Store Connect で **日本語** と **英語（U.S.）** の2つのローカリゼーションを作ってください。
> 日本ストアは日本語に加えて **English (U.S.)** のキーワードもインデックスするため、英語版を入れると日本ストアのキーワード枠が実質2倍になります。
> **English (U.K.) ではありません**（日本は U.K. の例外国です）。

---

## 提出前に必ず確認すること

**掲載情報には、提出するビルドに実際に入っている機能だけを書いてください。** 書いてある機能がアプリにないと、ガイドライン 2.3（正確なメタデータ）でリジェクトされます。
下の機能は SwiftUI 版に実装ずみです。ただし「実機で確認」が残っているものは、提出前に iPhone で動くのを確かめてください。

| 機能                                     | 掲載している場所                                 | 実装 | 確認の状況                                       |
| ---------------------------------------- | ------------------------------------------------ | ---- | ------------------------------------------------ |
| もどるまで見守り                         | サブタイトル、プロモ、概要、スクショ01、審査メモ | ☑    | 実機の UI テストで通過                           |
| ごほうびの日せんげん                     | プロモ、概要、スクショ02、審査メモ               | ☑    | 実機の UI テストで通過                           |
| 見ないモード                             | プロモ、概要、スクショ03、審査メモ               | ☑    | 実機の UI テストで通過                           |
| シェアカード                             | 概要、スクショ05                                 | ☑    | 実機の UI テストでカードの表示まで               |
| ホーム画面ウィジェット                   | 概要、スクショ07                                 | ☑    | ☐ 実機で確認                                     |
| ロック画面ウィジェット・記録コントロール | 概要、スクショ08                                 | ☑    | ☐ 実機で確認                                     |
| Siri・ショートカット                     | 概要、スクショ08                                 | ☑    | ☐ 実機で確認                                     |
| 体重よそう（初期オフ）                   | 概要                                             | ☑    | シミュレータで確認                               |
| ハムスターの新キャラ・新アイコン         | スクショ全部、アイコン                           | ☑    | スクショ 01・03・05・08 は差し替えが必要（§8）   |

ヘルスケア（HealthKit）連携は入れません。概要・キーワード・審査メモ・スクリーンショットにも書いていません。

---

## 早見表

| 項目                   | 日本語                                                          | 英語（U.S.）                                     |
| ---------------------- | --------------------------------------------------------------- | ------------------------------------------------ |
| 名前                   | たいかん！キャラといっしょに体重管理・ダイエット                | Taikan! Weight Log with a Pal                    |
| 文字数                 | 24 / 30                                                         | 29 / 30                                          |
| サブタイトル           | 増えても、もどるまで見守る体重記録                              | Up a bit? Buddy waits with you                   |
| 文字数                 | 17 / 30                                                         | 30 / 30                                          |
| キーワード文字数       | 95 / 100                                                        | 99 / 100                                         |
| プロモーションテキスト | 100 / 170                                                       | 153 / 170                                        |
| カテゴリ               | 主: ヘルスケア／フィットネス / 副: ライフスタイル               | Primary: Health & Fitness / Secondary: Lifestyle |
| 年齢レーティング       | 4+                                                              | 4+                                               |
| 価格                   | 無料・App内課金なし・**広告あり**（AdMob のバナーと全画面広告） | Free, no in-app purchases, **with ads**          |

---

## 1. 名前（30文字）

### 日本語

```
たいかん！キャラといっしょに体重管理・ダイエット
```

24文字。`たいかん` `キャラ` `体重` `体重管理` `管理` `ダイエット` を獲得。

- ホーム画面の表示名「たいかん！」で始まるので、表示名と掲載名がかけ離れているとは言われません。
- 「たいかん」は「たいじゅうかんり」を縮めた名前です。「体感」とも読めるので、すぐ後に「体重管理」を入れて何のアプリかをはっきりさせています。
- 前の名前にあった「かわいい」は外しました。同じアカウントの「かわいい〜」アプリと名前の型をそろえないためです。
- 代替案：`たいかん！：キャラといっしょに体重管理`（19文字。「ダイエット」はキーワードやサブタイトルで補う）。

### English (U.S.)

```
Taikan! Weight Log with a Pal
```

29文字。`Taikan` `Weight` `Log` `Pal`。

表示名は「Taikan!」です（`kawaii_taiju_kanri/en.lproj/InfoPlist.strings`）。前の「Weight Buddy」は、米国ストアに「WeightBuddy: Calorie Tracker」があるため使いません。

---

## 2. サブタイトル（30文字）

### 日本語

```
増えても、もどるまで見守る体重記録
```

17文字。いちばんの差別化（もどるまで見守り）をそのまま書いています。名前と重ならない `増えても` `もどる` `見守る` `体重記録` `記録` を獲得。

- 代替案：`見ないモードも。やさしい体重ダイアリー`（19文字）。

### English (U.S.)

```
Up a bit? Buddy waits with you
```

30文字。代替：`Gentle weight log & diet buddy`（30文字）。

---

## 3. カテゴリ

|                  | 設定                         |
| ---------------- | ---------------------------- |
| 主カテゴリ       | **ヘルスケア／フィットネス** |
| 副カテゴリ       | **ライフスタイル**           |
| 年齢レーティング | **4+**                       |

- 競合（あすけん・SmartDiet・ハミング・シンプルダイエット・カナヘイなど）は **ヘルスケア／フィットネス** にいます。同じ棚に並ぶためにここを主にします。
- 副カテゴリはキャラの雰囲気に合う **ライフスタイル**。
- **4+ を想定しています。** 暴力表現・アプリ内課金・ユーザー生成コンテンツ・外部とのやりとりはありません。年齢レーティングの質問票の「医療・治療の情報」は「なし」です。
- **広告（AdMob のバナーと全画面広告）があります。** 質問票で「広告」を「あり」と答えてください。広告があっても 4+ にできます。

---

## 4. プロモーションテキスト（170文字）

検索には効きませんが、**審査なしでいつでも差し替えられます**。概要の上に出ます。

### 日本語（リリース時）

```
増えた日も、キャラがもとの体重にもどるまでいっしょに見守ってくれる体重記録アプリ。食べる日は「ごほうびの日」として先に伝えておけばOK。数字を見たくない日は、見ないモードで表情とことばだけで伝えます。
```

100文字。

### English (U.S.)

```
Up after a night out? Buddy watches with you until you are back. Plan treat days ahead, or hide the numbers and just see Buddy's face. No sign-up needed.
```

153文字。

### ストック（季節・アップデート用）

| 時期     | 日本語                                                                                                 | English (U.S.)                                                                            |
| -------- | ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| 年末年始 | 忘年会や帰省で増えても大丈夫。「ごほうびの日」を先に伝えておけば、キャラがもどるまで見守ってくれます。 | Holiday parties? Mark them as treat days and Buddy will wait with you until you are back. |
| 年始     | ことしこそ、続けられる体重記録を。増えた日も責めないキャラが、毎朝いっしょにはかってくれます。         | Make this the year you keep logging. Buddy never scolds you, even on the days you go up.  |
| 夏前     | 夏までに、ゆっくり確実に。いまのペースだと、いつごろもくひょうに届くかも教えてくれます。               | Slow and steady before summer. See when you'll reach your goal at your current pace.      |

---

## 5. 概要（Description・4000文字まで）

最初の3行（「さらに表示」の前）で、ほかの体重アプリとの違いを言い切ります。そのあと、差別化の3つの機能 → キャラの反応 → シェア・iPhone の機能 → 基本の記録機能、の順です。

### 日本語

```
増えた日も、ひとりで落ちこまなくていい。
キャラが「もとの体重にもどるまで」いっしょに見守ってくれる、体重記録アプリです。
数字を見たくない日は、数字をかくして、表情とことばだけで伝えます。

■ もどるまで見守り
飲み会や外食のあとに増えると、ホームに「もやもや雲」のカードが出ます。
記録を続けて、もとの体重（その前の7日平均）にもどったら「はれた！」。
何日でもどったかが残るので、「一時的に増えただけ」が目で見てわかります。
もどらない日が続いても、失敗あつかいにはしません。

■ ごほうびの日
ケーキの日や飲み会の日は、前の日にキャラへ「あしたは ごほうびの日」と伝えておけます。
その日や次の朝に増えていても、キャラはおちこまずに「たのしかった？」と受けとめて、そのまま見守ってくれます。
食べる日を責めずに、計画できる体重記録です。

■ 見ないモード
体重の数字を見るのがつらい日に。
数字とグラフの目もりをかくして、「きろくしたよ」「いい流れだよ」と、キャラの表情とことばだけで伝えます。
記録はいつもどおりできます。

■ 体重にあわせて、14の表情
前の7日の平均とくらべて、キャラの表情が変わります。
減った日は「るんるん」、いちばん軽い記録を更新したら「どやっ」、少し増えた日は「こまった」。
日々の水分の上下で表情がころころ変わらないので、続けやすさを大切にしています。
気分に合わない日は、「きょうのきぶん」でえらびなおせます。
飲み会・外食・寝不足・のんびり・運動した、のタグをつけると、キャラがやさしく声をかけてくれます。

■ 数字なしでシェア
その日のキャラが、1枚のカードになります。
体重の数字は「のせる」を選んだときだけ。数字を出さずに、続けていることをシェアできます。
「この日」と「1週間」の2種類、色は4つから。

■ iPhone でもっと手軽に
・ホーム画面ウィジェット（小・中）で、きょうの表情と体重、連続日数
・ロック画面ウィジェットと、1タップで体重の入力画面を開けるボタン
・「たいかん！で体重をきろく」と話しかけると、Siri が何キロかを聞いて記録。ショートカットにも対応
・決まった時間に、キャラのセリフでおしらせ

■ 記録とふりかえり
・1週・1か月・3か月のグラフと、7日平均の線
・カレンダーに、その日の顔と体重
・日の詳細で、前後1週間の流れとメモをふりかえり
・BMI と体脂肪率、もくひょうまでの進み具合と、いまのペースでのゴール予想
・過去の日も、あとから入力できます

■ 続けるのが楽しくなる
・はじめてのきろく、7日れんぞく、もくひょう達成などのメダル
・毎日きろくするほど上がる「なかよし度」と、「ひょうじょうずかん」
・はかる前に「ふえた？へった？」を当てる「体重よそう」（せっていでオンにしたときだけ）
・キャラに名前をつけられます

■ 安心して使える
・アカウント登録なし。インストールしてすぐ始められます
・記録は端末の中に保存。開発者のサーバーには送りません
・iCloud に預けておけば、機種変更しても続きから（使うかどうかは選べます）
・CSV で書き出せます
・日本語と英語に対応

※ 本アプリは体重の記録とふりかえりのためのものです。医療上の診断や助言は行いません。BMI やキャラのセリフは目安としてご利用ください。
```

1418文字。

### English (U.S.)

```
Gone up? You don't have to feel bad alone.
Your buddy watches with you until you're back to where you were.
On days you'd rather not see the numbers, hide them and just see Buddy's face.

■ Bounce-back watch
Gain weight after a night out or a meal out, and a cloud card appears on the Home tab.
Keep logging, and when you're back to your usual weight (the average of the previous 7 days), the cloud clears.
Buddy remembers how many days it took, so you can see that the gain was only temporary.
If it takes a while, it is never counted as a failure.

■ Treat days
Having cake or a party tomorrow? Tell Buddy the day before.
If you're up that day or the next morning, Buddy won't be upset. It asks if you had fun and waits with you until you're back.
Plan your treat days without guilt.

■ Hide my weight
For days when seeing the number is hard.
Hide your weight and the graph scale, and Buddy tells you how it's going in words: "Logged" "Going well"
You can log just like usual.

■ 14 faces that change with your weight
Buddy's face changes compared to the average of the previous 7 days.
Down a little? "Happy." A new lightest record? "Proud." Up a little? "Uh-oh."
Daily water swings won't keep changing the face, so it's easy to keep going.
If the face doesn't match your mood, pick another with "Today's mood."
Tag a day with Night out, Ate out, Short sleep, Lazy day or Worked out, and Buddy responds kindly.

■ Share without numbers
Turn today's Buddy into a card.
Your weight is only shown if you choose to add it, so you can share your streak without sharing the number.
Choose a day card or a week card, in 4 colors.

■ Made for iPhone
• Home Screen widgets (small and medium) with today's face, weight and streak
• Lock Screen widgets and a button that opens weight entry in one tap
• Say "Log my weight in Taikan!" and Siri asks how much, then logs it. Works with Shortcuts
• A reminder at the time you choose, in Buddy's words

■ Look back
• Graphs for 1 week, 1 month or 3 months, with a 7-day average line
• A calendar with each day's face and weight
• Day details with the week before and after, plus your notes
• BMI, body fat, progress to your goal and when you'll get there at your current pace
• Log past days anytime

■ Fun that keeps you going
• Medals for your first log, a 7-day streak, reaching your goal and more
• A friendship level that grows the more you log, and a Face collection
• Weight Guess: guess "up, same or down" before you step on the scale (turn it on in Settings)
• Give your buddy a name

■ Use it with peace of mind
• No account needed. Start right after you install
• Your logs stay on your device and are never sent to the developer's servers
• Back up to iCloud and pick up where you left off on a new phone (optional)
• Export to CSV
• Available in Japanese and English

Note: This app is for logging and looking back on your weight. It does not provide medical diagnosis or advice. Please treat the BMI and Buddy's comments as a rough guide.
```

2989文字。

---

## 6. キーワード（100文字）

カンマ区切り・スペースなし。名前・サブタイトルの語は入れていません（`体重` `管理` `ダイエット` `記録` `キャラ` `見守る` は名前・サブタイトルで獲得ずみ）。

### 日本語（95文字）

```
BMI,体脂肪率,目標,減量,痩せる,習慣化,無料,ウィジェット,通知,メモ,癒し,健康,体重計,ログイン不要,振り返り,推移,平均,相棒,ハムスター,カレンダー,シェア,飲み会,リバウンド
```

- 新しく入れた語：`ハムスター`（新キャラ）、`カレンダー`、`シェア`、`飲み会`・`リバウンド`（もどるまで見守りで探す人向け）。
- 外した語：`管理`（名前に入った）、`キャラクター`（名前の「キャラ」と重なる）、`シンプル`・`朝`・`リマインド`・`体型`（枠を空けるため。体型は体型の話題に触れない方針とも合わない）。

### English (U.S.)（99文字）

```
diet,loss,lose,bmi,body,fat,goal,scale,graph,calendar,widget,habit,mood,streak,health,hamster,track
```

- 英語の名前に `Weight` `Log` が入ったので、キーワードから `weight` `log` を外し、`diet` `hamster` `track` を入れました。
- `kawaii` は、4.3 でリジェクトされた「かわいい〜」シリーズに見えないよう、外しました。

### 使ってはいけない語（商標）

名前・サブタイトル・キーワード・概要のどこにも入れません（審査ガイドライン 2.3.7）。

- あすけん、SmartDiet、ハミング、FiNC、カロミル、RecStyle、Yasegram、Happy Scale、WeightBuddy
- ハローキティ、マイメロディ、サンリオ、カナヘイ、ピスケ
- **要確認**：レコーディングダイエット（商標登録の可能性。J-PlatPat で確認するまで使わない）
- **要確認**：たいかん！（自分のアプリ名。申請前に J-PlatPat で同じ区分の商標がないか確認）

---

## 7. 審査メモ（App Review Information › Notes）

**メモ欄には、この文ではなく `体重きろく_審査対応.md` §1 の文を入れます**（合わせると上限の4000文字を超えるため）。ほかのアプリとの違いは、`体重きろく_審査対応.md` §3 の 4.3(a) への返信文で説明します。下の文は控えとして残しています。

```
Thank you for reviewing Taikan!

Taikan! is a weight log built around a character who responds to the user's weight in a supportive way. Its core features are original to this app and are not found in our other apps or in typical template-based weight trackers:

1. "Bounce-back watch": when weight goes up after a tagged event (a night out, eating out, or a planned treat day), the app tracks the gain as a temporary "cloud" and shows how many days it took to return to the user's previous 7-day average.
2. "Treat days": users can tell the character in advance that tomorrow is a treat day. If weight goes up that day or the next morning, the character responds gently and the return is tracked automatically.
3. "Hide my weight": users can hide weight figures and graph scales on the main screens. The character communicates progress through facial expressions and short phrases instead.

The app also supports Home Screen and Lock Screen widgets, and Siri and Shortcuts. Weight data stays on the device, or in the user's own iCloud if they turn on iCloud Backup (optional). It is never sent to our servers or to the ad SDK.

No account or login is required. To see the features:
- "Bounce-back watch": use "+ Log a past day" to log two past days, with the second one higher and tagged "Night out". The cloud card appears on the Home tab. Log a lower weight today to see it clear.
- "Treat days": after logging today, tap "Declare" on the treat day card on the Home tab.
- "Hide my weight": Settings tab, under "Hidden".
```

- 機能の場所（ボタン名やタブ名）は、実際のアプリの表記に合わせて直してください。
- 同じアカウントのほかのアプリとは、**キャラと名前を変えています**。配色とフォントは `kawaii_shopping_list` と同じなので、「デザインを変えた」とは書かないでください。

---

## 8. App Store Connect に入れるその他の項目

| 項目                    | 日本語                         | English (U.S.)                         |
| ----------------------- | ------------------------------ | -------------------------------------- |
| サポートURL             | https://（紹介ページの URL）   | 同左                                   |
| マーケティングURL       | https://（紹介ページの URL）   | 同左                                   |
| プライバシーポリシーURL | https://（紹介ページ）#privacy | https://（紹介ページ）?lang=en#privacy |
| 著作権                  | 2026 Jun Tsuda                 | 2026 Jun Tsuda                         |
| 問い合わせ先            | angocat215@gmail.com           | 同左                                   |

紹介ページは `web/` にあります。「たいかん！」の内容に直してありますが、手元のファイルだけです。審査に出す前に公開し、上の URL を入れてください。

### App のプライバシー（データ収集の申告）

**広告（Google Mobile Ads SDK）を入れているので、「データの収集なし」では申告できません。**
Google の案内（AdMob の「Apple の App Store のデータ開示」ページ）を見ながら、次の内容で申告します。

| データの種類                                | 用途                               | ユーザーに関連付け | トラッキング                 |
| ------------------------------------------- | ---------------------------------- | ------------------ | ---------------------------- |
| 識別子（デバイス ID＝IDFA など）            | サードパーティ広告、アナリティクス | する               | する（ATT で許可した人のみ） |
| 位置情報（おおよその位置：IP アドレスから） | サードパーティ広告、アナリティクス | する               | する                         |
| 使用状況データ（製品の操作・広告データ）    | サードパーティ広告、アナリティクス | する               | する                         |
| 診断（クラッシュ・パフォーマンスデータ）    | アナリティクス                     | しない             | しない                       |

- 体重の記録・体脂肪率・メモは、開発者も Google も受け取りません（端末の中、または本人の iCloud だけ）。「健康とフィットネス」の項目は申告しません。
- 開発者のサーバーはありません。開発者が自分で集める情報はありません。
- シェアカードは端末の中で画像を作り、iPhone の共有メニューに渡すだけです。開発者には送られません。
- アカウント登録はありません。
- iCloud バックアップは**任意**で、同期先は Apple の iCloud キーバリューストア。開発者は内容を参照できません。

### スクリーンショット（日本語・8枚、`AppStore/appstore_ja_v2`）

| 順番 | 見出し                                 | 見せている画面                                                     |
| ---- | -------------------------------------- | ------------------------------------------------------------------ |
| 01   | ふえても大丈夫　もどるまで見守るよ     | ホーム（もやもや雲の見守りカード）。ラベルはアプリ名「たいかん！」 |
| 02   | 食べる日は　先に伝えておけばOK         | ごほうびの日の翌朝                                                 |
| 03   | 数字を見たくない日は　ことばで伝えるよ | 見ないモード                                                       |
| 04   | 体重にあわせて　キャラがリアクション   | 表情ずかん                                                         |
| 05   | 数字なしで　シェアできる               | シェアカード                                                       |
| 06   | 毎日の表情が　カレンダーにならぶ       | カレンダー                                                         |
| 07   | ホーム画面に　ウィジェットを置ける     | ホーム画面ウィジェット                                             |
| 08   | ロック画面から　1タップで入力へ（差し替え待ち。今の画像は「1タップできろく」） | ロック画面ウィジェット                         |

- サイズは 1320×2868（6.9インチ）と 1206×2622（6.3インチ）。
- **01・03・05・08 は、今のアプリと違うところがあるので、提出前に差し替えます。** 05 の LINE・X・Instagram のボタンはアプリにありません。08 の「1タップできろく」は、ボタンがロックしたまま記録できるように読めます（実際は入力画面を開くボタンで、ロック解除が必要）。
- 英語版（`AppStore/appstore_en_v2`、同じ8枚・同じ2サイズ。画像は未確認）：01 Gained a bit? Buddy waits with you／02 Planning a feast? Tell Buddy first／03 Rather not look? Buddy tells you／04 A buddy that reacts to your weight／05 Share without the numbers／06 Every day’s face on your calendar／07 Put Buddy on your Home Screen／08 Log in one tap from the Lock Screen（日本語と同じ理由で差し替え待ち）。画面の文言は Localizable.strings の英訳に合わせた。

### プレビュー動画・ヘッダ画像

| 素材                                                                              | 状態                                                       |
| --------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| プレビュー動画（`AppStore/preview/out/preview_ja.mp4` / `preview_en.mp4`）        | 新キャラ・新名前で撮り直しずみ（2026年11月4日）            |
| プロダクトページのヘッダ（`AppStore/header/out/ja/header.png` / `en/header.png`） | 新キャラ・「もどるまで見守り」の絵で作り直しずみ（2026年11月5日）。見出しはサブタイトルと同じ意味 |

---

## 9. 数と名前を書いている場所（仕様を変えたら直す）

| 書いている数・名前（審査メモは §7 と `体重きろく_審査対応.md`） | 場所                                                                                                            |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| たいかん！（名前）・Taikan!（英語名）               | 名前、キーワードの注記、審査メモ、`InfoPlist.strings`、紹介ページ、スクリーンショット01、シェアカードの下の文字 |
| もどるまで見守り（7日平均にもどる・何日で）         | サブタイトル、プロモ、概要、審査メモ、スクショ01                                                                |
| ごほうびの日                                        | プロモ、概要、審査メモ、スクショ02、プロモのストック（年末年始）                                                |
| 見ないモード                                        | プロモ、概要、審査メモ、スクショ03                                                                              |
| 14の表情                                            | 概要、スクショ04、紹介ページ                                                                                    |
| タグ5つ（飲み会・外食・寝不足・のんびり・運動した） | 概要                                                                                                            |
| 1週・1か月・3か月                                   | 概要                                                                                                            |
| メダル（7日れんぞく・もくひょう達成）               | 概要                                                                                                            |
| ウィジェット（小・中）・ロック画面・Siri            | 概要、キーワード、審査メモ、スクショ07・08                                                                      |
| シェアカード（この日・1週間・色4つ）                | 概要、スクショ05                                                                                                |
| 体重よそう（初期オフ）                              | 概要                                                                                                            |
| アカウント登録なし・端末の中に保存                  | 概要、プロモ、審査メモ、App のプライバシー                                                                      |
| 課金なし・広告あり                                  | 早見表の価格、カテゴリの注記、App のプライバシー、紹介ページ                                                    |
