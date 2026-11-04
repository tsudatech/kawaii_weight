// たいかん！ 紹介ページ
// 言語切替 (ja / en) ／ scroll ヘッダ ／ fade-in ／ ripple ／ lazy load ／ parallax
// （パズルちゃんの紹介ページ tsudatech/puzzle_chan_web・ぽこりんの web/script.js を踏襲）
//
// 日本語は index.html に直接書いたものと同じ（言語を切りかえて戻すため）。文言を変えたら両方を直すこと。
// 英語の呼び名（Buddy / Face collection / Strict mode など）は、アプリの Shared/en.lproj/Localizable.strings に合わせてある。

const translations = {
  ja: {
    page_title: "たいかん！ - ふえても大丈夫。もどるまで、キャラが見守る体重きろく",
    meta_description: "たいかん！は、体重が増えた日に、もとにもどるまでキャラが見守ってくれる iPhone 向けの体重記録アプリです。食べる日を先に伝えられる「ごほうびの日」、数字をかくせる「見ないモード」、14の表情、数字なしのシェアカード、ウィジェットつき。ログインは不要です。",
    app_name: "たいかん！",
    nav_highlights: "とくちょう",
    nav_faces: "表情",
    nav_features: "機能",
    nav_download: "ダウンロード",
    nav_privacy: "プライバシー",
    nav_contact: "お問い合わせ",
    hero_eyebrow: "キャラといっしょの体重きろく",
    hero_title_line1: "増えた日も、",
    hero_title_line2: "ひとりで落ちこまない。",
    hero_description: "飲み会のあとに増えても、もとの体重にもどるまでキャラがいっしょに見守ります。食べる日は先に伝えておけて、数字を見たくない日は、表情とことばだけで伝えます。",
    hero_cta_download: "ダウンロード",
    hero_cta_faces: "とくちょうを見る",
    hero_bubble: "もやもや、はれたよ！",
    highlights_title: "たいかん！ならではの3つ",
    highlight_watch_title: "もどるまで見守り",
    highlight_watch_text: "飲み会や外食のあとに増えると、「もやもや雲」のカードが出ます。もとの体重（その前の7日平均）にもどったら「はれた！」。何日でもどったかが残り、2週間もどらなくても失敗あつかいにはしません。",
    highlight_treat_title: "ごほうびの日せんげん",
    highlight_treat_text: "ケーキや飲み会の予定があれば、前の日に「あしたは ごほうびの日」と伝えておけます。その日と翌朝に増えても、キャラは「たのしかった？」と受けとめて、そのまま見守ります。",
    highlight_hide_title: "見ないモード",
    highlight_hide_text: "数字を見たくない日に。体重をぼかして、グラフの目盛りもかくします。「きろくしたよ」「いい流れだよ」と、キャラの表情とことばだけで伝えます。記録はいつもどおりできます。",
    faces_title: "体重でかわる14の表情",
    faces_lead: "前の7日の平均とくらべて、減ったか増えたかでキャラの表情が変わります。気分に合わない日は「きょうのきぶん」でえらびなおせます。",
    face_happy_title: "るんるん",
    face_happy_text: "0.3kg 以上へった日、はじめてのきろく",
    face_good_title: "グッド",
    face_good_text: "少しへった日、もくひょうに届いた日",
    face_surprise_title: "びっくり",
    face_surprise_text: "0.8kg 以上へった日",
    face_doya_title: "どやっ",
    face_doya_text: "いちばん軽い記録を更新した日",
    face_hmm_title: "うーん",
    face_hmm_text: "±0.1kg の横ばいの日",
    face_trouble_title: "こまった",
    face_trouble_text: "0.1〜0.5kg ふえた日",
    face_crying_title: "なきそう",
    face_crying_text: "0.5kg 以上ふえた日（きびしめモードでは 0.3kg）",
    face_angry_title: "おこ",
    face_angry_text: "1kg 以上ふえた日",
    face_cozy_title: "ぬくぬく",
    face_cozy_text: "ふえた日に「のんびり」のタグ、ごほうびの日とその翌朝",
    face_nightcap_title: "ねぶそく",
    face_nightcap_text: "ふえた日に「寝不足」のタグ",
    face_sleepy_title: "ねむい",
    face_sleepy_text: "きょうはまだはかっていないとき",
    face_lonely_title: "さみしい",
    face_lonely_text: "3日以上あいて、ひさしぶりに開いたとき",
    faces_note: "ほかに「つかれ」「おうえん」など、ぜんぶで14種類。「ひょうじょうずかん」で、どの顔に何回なったか見られます。",
    features_title: "主な機能",
    feature_graph_title: "グラフとカレンダー",
    feature_graph_text: "1週・1か月・3か月の体重のうつりかわりと、7日平均の線。カレンダーには、その日の顔と体重がならびます。",
    feature_goal_title: "もくひょうまでの道のり",
    feature_goal_text: "スタートからもくひょうまで、いま何%進んだか。いまのペースだと、いつごろゴールできそうかも教えてくれます。",
    feature_tags_title: "タグ・メモ・体脂肪率",
    feature_tags_text: "飲み会・外食・寝不足・のんびり・運動したのタグと、ひとことメモ。増えた理由がわかると、キャラもやさしく受けとめます。",
    feature_reward_title: "ごほうびとなかよし度",
    feature_reward_text: "はじめてのきろく、7日れんぞく、1kg へった、もくひょう達成などのメダル。毎日きろくするほど、キャラとのなかよし度が上がります。",
    feature_remind_title: "はかってね通知",
    feature_remind_text: "決まった時間に、キャラのセリフでおしらせ。その日もう記録していたら、通知はお休みします。",
    feature_widget_title: "ホーム画面ウィジェット",
    feature_widget_text: "小と中の2種類。アプリを開かなくても、きょうの表情と体重、連続日数が見られます。",
    feature_share_title: "数字なしでシェア",
    feature_share_text: "その日のキャラや1週間の流れを、画像カードにしてシェアできます。体重の数字は「のせる」を選んだときだけ。色は4種類です。",
    feature_lock_title: "ロック画面ウィジェット",
    feature_lock_text: "表情・7日平均・もくひょうの進み具合が見られます。「体重をきろく」のボタンを置けば、押すだけで体重の入力画面が開きます。",
    feature_siri_title: "Siri・ショートカット",
    feature_siri_text: "「たいかん！で体重をきろく」と話しかけると、何キロかを聞いて記録します。きょうの体重や7日平均もたずねられます。",
    feature_guess_title: "体重よそう",
    feature_guess_text: "はかる前に「ふえた・おなじ・へった」を当ててポイントをためるゲーム。キャラとの勝負もできます。せっていでオンにしたときだけ出ます。",
    feature_icloud_title: "iCloud に預けられる",
    feature_icloud_text: "記録を iCloud に置いておけば、機種を変えても続きから使えます。使うかどうかは選べます。",
    feature_csv_title: "CSV で書き出せる",
    feature_csv_text: "記録はいつでも CSV ファイルにして、ほかのアプリや表計算で使えます。",
    feature_privacy_title: "ログインなしですぐ使える",
    feature_privacy_text: "アカウントの登録はいりません。日本語と英語に対応し、記録は端末の中に保存されます。",
    download_title: "ダウンロード",
    download_heading: "App Store で今すぐダウンロード",
    download_subheading: "iOS 18.0 以降の iPhone に対応しています。",
    download_button: "App Store でダウンロード",
    download_requirements_title: "システム要件",
    download_requirements_ios: "iOS 18.0 以降",
    download_requirements_devices: "iPhone／縦向き",
    download_requirements_language: "日本語・英語",
    download_requirements_iap: "App内課金なし（広告あり）",
    privacy_title: "プライバシーポリシー",
    privacy_handling_heading: "個人情報の取り扱いについて",
    privacy_handling_text: "たいかん！（以下「本アプリ」）は、利用者のプライバシーを尊重し、個人情報の保護に努めます。本アプリはアカウント登録を必要とせず、開発者のサーバーを持ちません。",
    privacy_collect_heading: "扱う情報",
    privacy_collect_text: "本アプリが扱うのは、利用者が入力した体重・体脂肪率・タグ・メモ・きぶん・ごほうびの日・体重よそう、身長ともくひょう体重、キャラの名前、ごほうびの達成状況、および各種設定だけで、これらはすべて端末の中に留まります（iCloud バックアップを有効にした場合を除きます）。開発者が氏名・メールアドレス・位置情報を収集することはありません。開発者自身は利用状況の解析（アナリティクス）を行いません。ただし、広告の表示のために、下記「広告について」のとおり Google が情報を扱います。",
    privacy_storage_heading: "情報の保存",
    privacy_storage_text: "記録と設定は、端末内のアプリ専用の領域に保存されます。ホーム画面・ロック画面のウィジェットに表示するため、きょうの表情・体重・7日平均・もくひょうの進み具合・連続日数などを、同じ端末の中でアプリとウィジェットが共有する領域（App Group）にも保存します。",
    privacy_icloud_heading: "iCloud について",
    privacy_icloud_text: "設定で iCloud バックアップを有効にした場合に限り、体重の記録（体重よそうをふくむ）・ごほうびの日・ごほうび・キャラの名前が iCloud のキーバリューストアに保存され、同じ Apple アカウントの端末間で同期されます。この同期は Apple の iCloud 上で完結し、開発者がその内容を参照することはできません。設定は同期されず、その端末にだけ残ります。",
    privacy_siri_heading: "Siri・シェアについて",
    privacy_siri_text: "Siri やショートカットで話した内容は、Apple のサービスが扱います。開発者には送られません。シェアカードは端末の中で画像を作り、利用者が選んだ共有先に渡します。「写真に保存」を選んだときだけ、写真ライブラリに追加するための許可を求めます。",
    privacy_notification_heading: "通知について",
    privacy_notification_text: "「はかってね通知」は、端末の中で予約するローカル通知です。通知のために情報を外部へ送ることはありません。通知を使うかどうかは、アプリの設定と iOS の「設定」で変えられます。",
    privacy_ads_heading: "広告について",
    privacy_ads_text: "本アプリは、Google LLC の広告配信サービス「Google AdMob」を使って、画面の下のバナー広告と、画面の切りかえ時の全画面広告を表示します。広告の配信のため、Google は端末の広告識別子（IDFA）、IP アドレスから推定されるおおよその位置、広告の表示やタップの状況、端末の情報などを収集・利用することがあります。IDFA を使うのは、アプリの中で表示される確認（App Tracking Transparency）で利用者が許可した場合だけです。許可しなかった場合も広告は表示されますが、利用者に合わせた広告にはなりません。許可はあとから iOS の「設定」の「プライバシーとセキュリティ」→「トラッキング」で変更できます。体重の記録・体脂肪率・メモなどが広告に使われることはありません。Google による情報の扱いは、Google のプライバシーポリシー（https://policies.google.com/privacy）と、Google のサービスを使うサイトやアプリから収集した情報の Google による使用（https://policies.google.com/technologies/partner-sites）をご覧ください。",
    privacy_network_heading: "外部との通信",
    privacy_network_text: "本アプリは、開発者のサーバーへ利用者の記録を送信しません。本アプリが行う通信は、広告の表示のための Google との通信と、利用者が iCloud バックアップを有効にした場合の Apple のサービスとの通信だけです。体重の記録が Google に送られることはありません。CSV の書き出しとシェアカードの共有は、利用者が共有先を選んだときにだけ行われます。",
    privacy_health_heading: "健康に関する情報について",
    privacy_health_text: "本アプリは、体重の記録と振り返りのためのものです。医療上の診断や助言を行うものではありません。表示される BMI やキャラのセリフは目安としてご利用ください。",
    privacy_delete_heading: "データの削除",
    privacy_delete_text: "アプリの設定の「すべてのデータを消す」、またはアプリの削除で、端末内に保存された記録と設定が削除されます。iCloud バックアップを使っている場合は、「すべてのデータを消す」で iCloud 上の記録も消えます。iOS の設定から iCloud 上のデータを削除することもできます。",
    privacy_children_heading: "お子さまの利用について",
    privacy_children_text: "本アプリは年齢を問わず利用できます。開発者は個人情報を収集せず、アプリ内購入もありません。広告は表示されます。",
    privacy_contact_heading: "お問い合わせ",
    privacy_contact_text_before: "プライバシーポリシーに関するご質問は、",
    privacy_contact_link: "お問い合わせ",
    privacy_contact_text_after: "までご連絡ください。",
    privacy_update: "最終更新: 2026 年 11 月",
    contact_title: "お問い合わせ",
    contact_intro: "アプリに関するご質問、バグ報告、機能要望などがございましたら、お気軽にお問い合わせください。",
    contact_email_heading: "📧メール",
    contact_bug_heading: "🐛バグ報告",
    contact_bug_text: "記録が消えた、表情がおかしいといった不具合を見つけたら、上記メールアドレスまで詳細をお送りください。",
    contact_feature_heading: "💡機能要望",
    contact_feature_text: "こんな表情やごほうびがほしい、といったご要望もお待ちしています。",
    footer_copyright: "© 2026 たいかん！. All rights reserved.",
  },
  en: {
    page_title: "Taikan! - Gone up? Your buddy watches until you’re back.",
    meta_description: "Taikan! is an iPhone weight log where your buddy watches with you until you’re back to your usual weight. Declare treat days ahead of time, hide the numbers when you’d rather not see them, and enjoy 14 faces, shareable cards without numbers, and widgets. No sign-in required.",
    app_name: "Taikan!",
    nav_highlights: "Highlights",
    nav_faces: "Faces",
    nav_features: "Features",
    nav_download: "Download",
    nav_privacy: "Privacy",
    nav_contact: "Contact",
    hero_eyebrow: "A weight log with a buddy",
    hero_title_line1: "Gone up?",
    hero_title_line2: "You’re not alone.",
    hero_description: "Up after a night out? Your buddy watches with you until you’re back to your usual weight. Tell it about treat days ahead of time, and on days you’d rather not see numbers, it lets you know with just faces and words.",
    hero_cta_download: "Download",
    hero_cta_faces: "See what’s different",
    hero_bubble: "The cloud cleared!",
    highlights_title: "Three things that make Taikan! different",
    highlight_watch_title: "Bounce-back watch",
    highlight_watch_text: "Go up after a night out or a meal out, and a little cloud card appears. When you’re back to your usual weight (the average of the previous 7 days), it clears. Buddy remembers how many days it took, and even if you’re not back within 2 weeks, it’s never counted as a failure.",
    highlight_treat_title: "Treat days",
    highlight_treat_text: "Planning cake or a party? Tell Buddy the day before that tomorrow is a treat day. If you go up that day or the next morning, Buddy asks “Was it fun?” and keeps watching with you.",
    highlight_hide_title: "Hide the numbers",
    highlight_hide_text: "For days you’d rather not see numbers. Your weight is blurred and the graph scale is hidden, and Buddy lets you know with faces and words like “Logged” and “Going well”. Logging works as usual.",
    faces_title: "14 faces that change with your weight",
    faces_lead: "Buddy’s face changes depending on whether you went up or down compared to the average of the previous 7 days. If it doesn’t match your mood, pick another with “Today’s mood”.",
    face_happy_title: "Happy",
    face_happy_text: "Down 0.3kg or more, or your first log",
    face_good_title: "Good",
    face_good_text: "Down a little, or at your goal",
    face_surprise_title: "Wow",
    face_surprise_text: "Down 0.8kg or more",
    face_doya_title: "Proud",
    face_doya_text: "A new lightest record",
    face_hmm_title: "Hmm",
    face_hmm_text: "Holding steady within ±0.1kg",
    face_trouble_title: "Uh-oh",
    face_trouble_text: "Up 0.1–0.5kg",
    face_crying_title: "Teary",
    face_crying_text: "Up 0.5kg or more (0.3kg in strict mode)",
    face_angry_title: "Grumpy",
    face_angry_text: "Up 1kg or more",
    face_cozy_title: "Cozy",
    face_cozy_text: "Went up on a “Lazy day”, a treat day, or the morning after",
    face_nightcap_title: "Drowsy",
    face_nightcap_text: "Went up after “Short sleep”",
    face_sleepy_title: "Sleepy",
    face_sleepy_text: "You haven’t weighed in today yet",
    face_lonely_title: "Lonely",
    face_lonely_text: "Opening the app after 3 or more days away",
    faces_note: "Plus “Tired”, “Cheer” and more: 14 faces in all. The Face collection shows how many times each face appeared.",
    features_title: "Features",
    feature_graph_title: "Graph and calendar",
    feature_graph_text: "See your weight over 1 week, 1 month or 3 months with a 7-day average line. The calendar shows each day’s face and weight.",
    feature_goal_title: "Goal progress",
    feature_goal_text: "See how far you’ve come from your start to your goal, and when you’ll get there at your current pace.",
    feature_tags_title: "Tags, notes and body fat",
    feature_tags_text: "Tag a day with Night out, Ate out, Short sleep, Lazy day or Worked out, and add a quick note. When Buddy knows why you went up, it goes easy on you.",
    feature_reward_title: "Rewards and friendship",
    feature_reward_text: "Earn medals for your first log, a 7-day streak, losing 1kg, reaching your goal and more. The more you log, the closer you and Buddy become.",
    feature_remind_title: "Weigh-in reminders",
    feature_remind_text: "Get a reminder in Buddy’s words at the time you choose. If you’ve already logged that day, the reminder takes the day off.",
    feature_widget_title: "Home Screen widgets",
    feature_widget_text: "Small and medium sizes. See today’s face, weight and streak without opening the app.",
    feature_share_title: "Share without numbers",
    feature_share_text: "Turn a day or your week into an image card to share. Your weight appears only if you choose to show it. Pick from 4 colors.",
    feature_lock_title: "Lock Screen widgets",
    feature_lock_text: "See Buddy’s face, your 7-day average and goal progress. Add the Log weight button to jump right to weight entry.",
    feature_siri_title: "Siri and Shortcuts",
    feature_siri_text: "Say “Log my weight in Taikan!” and Siri asks how much, then logs it. You can also ask for today’s weight or your 7-day average.",
    feature_guess_title: "Weight Guess",
    feature_guess_text: "Guess “up, same or down” before you weigh in, earn points and compete with Buddy. It appears only when you turn it on in Settings.",
    feature_icloud_title: "Back up to iCloud",
    feature_icloud_text: "Keep your logs in iCloud and pick up where you left off on a new phone. Backup is optional.",
    feature_csv_title: "Export as CSV",
    feature_csv_text: "Export your logs as a CSV file anytime to use in other apps or spreadsheets.",
    feature_privacy_title: "No sign-in needed",
    feature_privacy_text: "No account required. Available in Japanese and English, and your logs are stored on your device.",
    download_title: "Download",
    download_heading: "Get it on the App Store",
    download_subheading: "For iPhone with iOS 18.0 or later.",
    download_button: "Download on the App Store",
    download_requirements_title: "Requirements",
    download_requirements_ios: "iOS 18.0 or later",
    download_requirements_devices: "iPhone / portrait",
    download_requirements_language: "Japanese and English",
    download_requirements_iap: "No in-app purchases (with ads)",
    privacy_title: "Privacy Policy",
    privacy_handling_heading: "How we handle your information",
    privacy_handling_text: "Taikan! (“the app”) respects your privacy and works to protect your personal information. The app does not require an account, and the developer does not operate any servers.",
    privacy_collect_heading: "Information the app handles",
    privacy_collect_text: "The app only handles the weight, body fat, tags, notes, moods, treat days and weight guesses you enter, your height and goal weight, Buddy’s name, your reward progress, and your settings. All of this stays on your device (except when you turn on iCloud backup). The developer does not collect your name, email address or location, and does not run its own analytics. However, Google handles some information to show ads, as described in “About ads” below.",
    privacy_storage_heading: "Where information is stored",
    privacy_storage_text: "Your logs and settings are stored in the app’s private area on your device. To show the Home Screen and Lock Screen widgets, today’s face, weight, 7-day average, goal progress, streak and similar details are also saved to an area shared by the app and its widgets on the same device (App Group).",
    privacy_icloud_heading: "About iCloud",
    privacy_icloud_text: "Only if you turn on iCloud backup in Settings, your weight logs (including weight guesses), treat days, rewards and Buddy’s name are saved to iCloud key-value storage and synced across devices signed in with the same Apple Account. This sync happens entirely within Apple’s iCloud, and the developer cannot see its contents. Settings are not synced and stay on each device.",
    privacy_siri_heading: "About Siri and sharing",
    privacy_siri_text: "What you say to Siri or use in Shortcuts is handled by Apple’s services and is not sent to the developer. Share cards are created on your device and passed to the destination you choose. Permission to add to your photo library is requested only if you choose to save the image to Photos.",
    privacy_notification_heading: "About notifications",
    privacy_notification_text: "Weigh-in reminders are local notifications scheduled on your device. No information is sent anywhere for notifications. You can turn reminders on or off in the app’s settings and in the iOS Settings app.",
    privacy_ads_heading: "About ads",
    privacy_ads_text: "The app uses Google AdMob, an ad service from Google LLC, to show a banner ad at the bottom of the screen and full-screen ads when you switch screens. To deliver ads, Google may collect and use your device’s advertising identifier (IDFA), your approximate location estimated from your IP address, how ads are shown and tapped, and device information. The IDFA is used only if you allow it in the in-app prompt (App Tracking Transparency). If you don’t allow it, ads are still shown but are not personalized. You can change this later in iOS Settings under Privacy & Security → Tracking. Your weight logs, body fat and notes are never used for ads. For how Google handles information, see Google’s Privacy Policy (https://policies.google.com/privacy) and How Google uses information from sites or apps that use our services (https://policies.google.com/technologies/partner-sites).",
    privacy_network_heading: "Network communication",
    privacy_network_text: "The app never sends your logs to the developer’s servers. The only communication the app itself makes is with Google to show ads, and with Apple’s services when you turn on iCloud backup. Your weight logs are never sent to Google. CSV export and sharing a card happen only when you choose where to share them.",
    privacy_health_heading: "About health information",
    privacy_health_text: "The app is for logging and looking back on your weight. It does not provide medical diagnosis or advice. Please treat the BMI and Buddy’s comments as a rough guide.",
    privacy_delete_heading: "Deleting your data",
    privacy_delete_text: "Using “Erase all data” in the app’s settings, or deleting the app, removes the logs and settings stored on your device. If you use iCloud backup, “Erase all data” also erases your logs in iCloud. You can also delete iCloud data from the iOS Settings app.",
    privacy_children_heading: "Use by children",
    privacy_children_text: "The app can be used by people of any age. The developer collects no personal information, and there are no in-app purchases. The app shows ads.",
    privacy_contact_heading: "Contact",
    privacy_contact_text_before: "If you have any questions about this privacy policy, please ",
    privacy_contact_link: "contact us",
    privacy_contact_text_after: ".",
    privacy_update: "Last updated: November 2026",
    contact_title: "Contact",
    contact_intro: "If you have questions about the app, bug reports or feature requests, please feel free to get in touch.",
    contact_email_heading: "📧 Email",
    contact_bug_heading: "🐛 Bug reports",
    contact_bug_text: "If you find a problem, such as logs disappearing or a face that looks wrong, please send the details to the email address above.",
    contact_feature_heading: "💡 Feature requests",
    contact_feature_text: "We’d love to hear ideas for new faces or rewards, too.",
    footer_copyright: "© 2026 Taikan!. All rights reserved.",
  },
};

// ── Language ─────────────────────────────────────────────────────────────────

function detectLanguage() {
  const params = new URLSearchParams(window.location.search);
  if (params.has("lang")) return params.get("lang");
  const stored = localStorage.getItem("lang");
  if (stored) return stored;
  const browser = navigator.language || navigator.userLanguage || "ja";
  return browser.startsWith("ja") ? "ja" : "en";
}

function applyLanguage(lang) {
  const t = translations[lang] || translations["ja"];

  document.title = t["page_title"] || document.title;
  const metaDesc = document.querySelector('meta[name="description"]');
  if (metaDesc) metaDesc.setAttribute("content", t["meta_description"] || "");

  document.documentElement.lang = lang;

  document.querySelectorAll("[data-i18n-key]").forEach((el) => {
    const key = el.getAttribute("data-i18n-key");
    if (t[key] !== undefined) {
      el.textContent = t[key];
    }
  });

  document.querySelectorAll("img[data-src-ja]").forEach((img) => {
    const src = lang === "ja" ? img.dataset.srcJa : img.dataset.srcEn;
    if (src) img.src = src;
  });

  document.querySelectorAll(".lang-btn").forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.lang === lang);
  });

  localStorage.setItem("lang", lang);
}

// ── Scroll & Header ───────────────────────────────────────────────────────────

function initHeader() {
  const header = document.querySelector(".header");
  if (!header) return;

  let lastScrollY = window.scrollY;

  window.addEventListener(
    "scroll",
    () => {
      const currentScrollY = window.scrollY;
      if (currentScrollY > lastScrollY && currentScrollY > 100) {
        header.style.transform = "translateY(-100%)";
      } else {
        header.style.transform = "translateY(0)";
      }
      lastScrollY = currentScrollY;
    },
    { passive: true },
  );

  header.style.transition = "transform 0.3s ease";
}

function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", (e) => {
      const targetId = anchor.getAttribute("href");
      if (targetId === "#") return;
      const target = document.querySelector(targetId);
      if (!target) return;
      e.preventDefault();
      const headerHeight = document.querySelector(".header")?.offsetHeight ?? 70;
      const top = target.getBoundingClientRect().top + window.scrollY - headerHeight;
      window.scrollTo({ top, behavior: "smooth" });
    });
  });
}

// ── Intersection Observer (fade-in) ──────────────────────────────────────────

function initFadeIn() {
  const targets = document.querySelectorAll(
    ".face-card, .feature-card, .download-info, .download-requirements, .privacy-content, .contact-method",
  );

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("fade-in-up");
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12 },
  );

  // 最初から見えている範囲は隠さない。
  // 隠してしまうと、監視が働かない場面（プレビュー、拡張機能、古い環境）で
  // 画面の先頭から真っ白になってしまう。
  targets.forEach((el) => {
    if (el.getBoundingClientRect().top <= window.innerHeight) return;
    el.style.opacity = "0";
    observer.observe(el);
  });

  document.addEventListener("animationstart", (e) => {
    if (e.animationName === "fadeInUp") {
      e.target.style.opacity = "";
    }
  });

  // 保険。何らかの理由で監視が働かなくても、必ず見える状態に戻す
  setTimeout(() => {
    targets.forEach((el) => {
      if (el.style.opacity === "0") el.style.opacity = "";
    });
  }, 4000);
}

// ── Ripple on buttons ─────────────────────────────────────────────────────────

function initRipple() {
  document.querySelectorAll(".btn, .app-store-placeholder").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      const rect = btn.getBoundingClientRect();
      const ripple = document.createElement("span");
      const size = Math.max(rect.width, rect.height);
      ripple.style.cssText = `
        position:absolute;width:${size}px;height:${size}px;
        left:${e.clientX - rect.left - size / 2}px;
        top:${e.clientY - rect.top - size / 2}px;
        background:rgba(255,255,255,0.35);border-radius:50%;
        transform:scale(0);animation:ripple 0.5s linear;pointer-events:none;
      `;
      btn.style.position = "relative";
      btn.style.overflow = "hidden";
      btn.appendChild(ripple);
      ripple.addEventListener("animationend", () => ripple.remove());
    });
  });

  const style = document.createElement("style");
  style.textContent = `@keyframes ripple{to{transform:scale(2.5);opacity:0}}`;
  document.head.appendChild(style);
}

// ── Lazy images ───────────────────────────────────────────────────────────────

function initLazyImages() {
  const images = document.querySelectorAll("img.lazy");
  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src || img.src;
          img.classList.remove("lazy");
          observer.unobserve(img);
        }
      });
    });
    images.forEach((img) => observer.observe(img));
  }
}

// ── Parallax (hero) ───────────────────────────────────────────────────────────

function initParallax() {
  const hero = document.querySelector(".hero");
  if (!hero) return;
  window.addEventListener(
    "scroll",
    () => {
      const offset = window.scrollY * 0.3;
      hero.style.backgroundPositionY = `${offset}px`;
    },
    { passive: true },
  );
}

// ── Init ──────────────────────────────────────────────────────────────────────

document.addEventListener("DOMContentLoaded", () => {
  const lang = detectLanguage();
  applyLanguage(lang);

  document.querySelectorAll(".lang-btn").forEach((btn) => {
    btn.addEventListener("click", () => applyLanguage(btn.dataset.lang));
  });

  initHeader();
  initSmoothScroll();
  initFadeIn();
  initRipple();
  initLazyImages();
  initParallax();
});
