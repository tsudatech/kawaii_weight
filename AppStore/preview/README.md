# App Store プレビュー動画

App Store の紹介画像の欄に載せるプレイ動画（日本語・英語）。

| ファイル | 中身 |
|---|---|
| `out/preview_ja.mp4` / `out/preview_en.mp4` | 提出する動画（無音の音声トラックつき） |
| `out/contact_sheet_ja.jpg` / `out/contact_sheet_en.jpg` | 1秒ごとのコマの一覧（確認用。提出しない） |

## 仕様（App Store Connect の App Preview specifications・2026年10月に確認）

- 886×1920（縦）。iPhone の Dynamic Island・Face ID の機種は、この1サイズでぜんぶに使える
- 28.1秒（日本語）・28.6秒（英語）。15〜30秒
- 30fps（1コマずつ置いているので、止まった画面もコマが抜けない）
- H.264 High Profile 4.0
- 音声：AAC ステレオ 256kbps・44.1kHz（音声トラックは必須なので、無音を入れてある）
- 代表のコマ（ポスターフレーム）は既定で5秒め。ちょうど記録して、もやもやがはれて紙ふぶきが舞っているところ

## 流れ

差別化の機能（もどるまで見守り・ごほうびの日・見ないモード）を先に見せる。

1. ホーム（約8秒）：まだはかっていない「ねむい」顔 → −ボタンで8回減らす、「運動した」のタグ → 「きろくする」→ もやもやがはれて紙ふぶき（見守りカードがお日さまに）
2. ごほうびの日せんげん（約2.6秒）
3. 見ないモード（約2.6秒）：体重が「きろくしたよ」に
4. シェアカード（約3秒）：数字なしのカード
5. グラフ（約3秒）：1か月 → 3か月
6. キャラ（約2.6秒）：おへや、はらしたもやもや
7. ロック画面（約2.4秒）→ Siri（約3秒）

見本の記録は、3日前の飲み会から増えていて、8回減らすとちょうどはれるように `PreviewTour.setUpWatch` で直している。

## 作り方

アプリのデバッグビルドに、この流れを自動で進める起動引数 `--preview-tour` がある（`kawaii_taiju_kanri/Debug/PreviewTour.swift`）。
見本の記録（約3か月分）を入れ、はじめの設定・案内を出さずに、体重の入力カードを本当に押したのと同じように動かす。リリース版には入らない。

シミュレータ（iPhone 17 Pro）で録る：

```sh
S=作業用のフォルダ
U=<シミュレータの ID>
# ステータスバーを 9:41・電池満タンに
xcrun simctl status_bar $U override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularMode notSupported
# Debug でビルドしてインストールしたあと、言語ごとに録る
xcrun simctl terminate $U jp.jntech.kawaii-taiju-kanri
xcrun simctl io $U recordVideo --codec=h264 --force $S/raw_ja.mp4 &
sleep 1.5
xcrun simctl launch $U jp.jntech.kawaii-taiju-kanri --preview-tour --lang ja
sleep 36; kill -INT %1
```

つないで書き出す（ffmpeg は使わない。道具は slash の `appstore/preview/tools` と同じ作り）：

```sh
swiftc -O tools/compose.swift -o $S/compose
swiftc -O tools/silence.swift -o $S/silence && $S/silence $S/silence.wav
$S/compose out/preview_ja.mp4 $S/silence.wav $S/raw_ja.mp4 7.0-35.1
$S/compose out/preview_en.mp4 $S/silence.wav $S/raw_en.mp4 6.0-34.6
```

- 切り出す区間（秒）は録画ごとに少しずれる。`tools/frames.swift` でコマの一覧を作って（`frames 動画 出力の接頭辞 1.0 10`）、区間を決めなおす
- `tools/probe.swift`：書き出した動画の解像度・fps・音声を確かめる
- 流れの長さを変えたら、`PreviewTour.run` の待ち時間と、上の区間の両方を直す
