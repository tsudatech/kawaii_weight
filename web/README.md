# たいかん！ — 紹介ページ

たいかん！（英語名 Taikan!・iPhone 向けの体重記録アプリ）の紹介ページ。HTML / CSS / Vanilla JS だけの静的サイトで、GitHub Pages 等にそのままデプロイできる。

パズルちゃんの紹介ページ（`tsudatech/puzzle_chan_web`）・ぽこりんの `web/` の構成を踏襲し、配色をアプリの `Palette`（`Shared/Theme.swift`）に合わせてある。
ぽこりんの「3つのモード」の節は、このアプリでは「体重でかわる14の表情」の節にしている。スクリーンショットの節は置いていない。

## ファイル

| ファイル | 役割 |
|---|---|
| `index.html` | セマンティック HTML。各テキストは `data-i18n-key` で多言語化対応 |
| `styles.css` | 配色・レイアウト・レスポンシブ。地は `#FFF9F3`、文字は `#4A3020`、アクセントは `#E58C86` |
| `script.js` | 言語切替 (ja / en) ／ scroll ヘッダ ／ fade-in ／ ripple ／ lazy load ／ parallax |
| `images/faces/` | キャラの表情。アプリの `Shared/Characters.xcassets` の lg_*.png を 320px に縮小したもの |
| `images/app-icon.png` | ロゴとファビコン。アプリのアイコンを 192px に縮小したもの |

文字はアプリと同じ Zen Maru Gothic（本文）と Baloo 2（数字）を Google Fonts から読む。

## 文言

- 日本語は `index.html` に直接書いてあり、`script.js` の `translations.ja` にも同じものを持っている（言語を切りかえて戻すため）。
  文言を変えたら両方を直すこと。
- 英語の呼び名（Taikan! / Buddy / Face collection / Strict mode など）は、アプリの `Shared/en.lproj/Localizable.strings` に合わせてある。
- 機能の説明は、提出するアプリの動きに合わせる（ロック画面のボタンは体重の入力画面を開くもの、Siri は「たいかん！で体重をきろく」のあとに何キロかを聞く流れ）。
- 表情の出る条件は、アプリの判定（`WeightStore.judge`）どおりに書いてある。しきい値を変えたら、こちらも直すこと。

## 公開する前に直すところ

- App Store のリンク（`#download` の「App Store でダウンロード」）を、公開後の実際の URL に差しかえる。
- 対応 iOS（「iOS 18.0 以降」）は、いまのプロジェクトの設定（アプリ本体・ウィジェットとも 18.0）に合わせてある。対応 iOS を変えたら直す。
- 広告（AdMob）を入れたので、システム要件は「App内課金なし（広告あり）」、プライバシーポリシーには「広告について」がある。広告の種類や出し方を変えたら直すこと。
- プライバシーポリシーには Siri・シェアの項がある。ヘルスケア連携は今回の提出に入れていないので、載せていない。預ける項目や権限を変えたら直すこと。

## 手元で見る

```bash
cd web
python3 -m http.server 8765
# http://localhost:8765/ を開く。?lang=en で英語
```
