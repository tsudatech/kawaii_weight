#!/usr/bin/env python3
"""App Store のプロダクトページ用ヘッダ画像を書き出す（かわいい日記の make_header.py と同じ作り）。

    python3 AppStore/header/make_header.py      # 要 Pillow（python3 -m pip install --user pillow）

AppStore/header/out/<lang>/header.png に 3840 x 1646（21:9）の PNG を書く。
header_guide.png は安全領域の枠を重ねた確認用（提出しない）。

App Store Connect の仕様（Creative assets specifications・2026年10月に確認）:
- プロダクトページのヘッダ: 21:9 / 3840 x 1646 px / .jpeg .jpg .png
  （16:9 / 5244 x 2950 px の .png を1枚出すと、ヘッダと検索結果の両方に使うこともできる）
- アルファチャンネル・透過は不可
- 端末や向きで切り抜き方が変わるので、要の絵と文字は中央の安全領域に置く
  （Apple のテンプレートの ART SAFE AREA は中央の約 1646 x 661 px）
- 価格・URL・他プラットフォームのロゴ・Apple の受賞表記は入れない。文言は各言語に訳す

絵はアプリと同じキャラ画像（Shared/Characters.xcassets）、文字はアプリと同じ Zen Maru Gothic・Baloo 2。
HTML に組んで Chrome のヘッドレスで撮り、最後に透過を落として書き出す。
"""

import subprocess
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[1]
CHARS = REPO / "Shared" / "Characters.xcassets"
FONTS = REPO / "kawaii_taiju_kanri" / "Resources" / "Fonts"
OUT = ROOT / "out"

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
SIZE = (3840, 1646)
SAFE = (1646, 661)

# アプリの配色（Shared/Theme.swift の Palette）
PAPER = (0xFF, 0xF9, 0xF3)
INK = "#4A3020"
INK_SOFT = "#8C7564"
ROSE = "#E58C86"
MINT_INK = "#3E9B86"
UP = "#D06A63"
GOLD = "#F3CA89"

COPY = {
    "ja": {
        "lang": "ja",
        "headline": "まいにちの体重に、<em>キャラが反応</em>。",
        "size": 92,
    },
    "en": {
        "lang": "en",
        "headline": "Your buddy <em>reacts</em> to every weigh-in.",
        "size": 84,  # 安全領域（幅 1646）におさまる大きさ
    },
}


def char(name: str) -> str:
    """キャラ画像のファイル（SVG か PNG）の URL"""
    folder = CHARS / f"{name}.imageset"
    for ext in ("svg", "png"):
        path = folder / f"{name}.{ext}"
        if path.exists():
            return path.as_uri()
    raise FileNotFoundError(name)


def sticker(name: str, x: int, y: int, d: int, rotate: float, delta: str | None = None, up: bool = False) -> str:
    """白い丸に載せたキャラ。(x, y) は中心。delta は体重の増減のふだ（「−0.4kg」など）"""
    tag = ""
    if delta:
        color = UP if up else MINT_INK
        tag = f'<div class="delta" style="color:{color}">{delta}</div>'
    return f"""
<div class="sticker" style="left:{x - d // 2}px; top:{y - d // 2}px; width:{d}px; height:{d}px;
     transform: rotate({rotate}deg);">
  <img src="{char(name)}" style="width:{round(d * 0.8)}px; height:{round(d * 0.8)}px">
  {tag}
</div>"""


def sparkle(x: int, y: int, d: int, color: str = GOLD, rotate: float = 0) -> str:
    """4つの角のきらきら（アプリのキャラの効果線と同じ雰囲気）"""
    return f"""
<svg class="float" style="left:{x - d // 2}px; top:{y - d // 2}px; width:{d}px; height:{d}px; transform: rotate({rotate}deg)"
     viewBox="0 0 100 100"><path d="M50 0 C55 38 62 45 100 50 C62 55 55 62 50 100 C45 62 38 55 0 50 C38 45 45 38 50 0Z" fill="{color}"/></svg>"""


def heart(x: int, y: int, d: int, color: str = ROSE, rotate: float = 0) -> str:
    return f"""
<svg class="float" style="left:{x - d // 2}px; top:{y - d // 2}px; width:{d}px; height:{d}px; transform: rotate({rotate}deg)"
     viewBox="0 0 100 100"><path d="M50 88 C20 66 4 48 4 30 C4 16 15 6 28 6 C38 6 46 12 50 20 C54 12 62 6 72 6 C85 6 96 16 96 30 C96 48 80 66 50 88Z" fill="{color}"/></svg>"""


def build_html(copy: dict) -> str:
    w, h = SIZE
    cx = w // 2

    # 左右にキャラを散らす（中央の安全領域 x 1097〜2743 には主役と文字があるので避ける）。
    # 減った日はミント、増えた日は赤の増減ふだ（アプリの色分けと同じ）
    stickers = [
        sticker("lg_good", 560, 600, 400, -6, "−0.2kg"),
        sticker("surprise", 1130, 300, 270, 5, "−0.8kg"),
        sticker("cozy", 880, 1210, 330, 4),
        sticker("lg_trouble", 220, 1230, 290, -4, "+0.3kg", up=True),
        sticker("doya", 3280, 600, 400, 6, "−0.5kg"),
        sticker("lg_crying", 2710, 300, 270, -5, "+0.6kg", up=True),
        sticker("cheer", 2960, 1210, 330, -4),
        sticker("yawn", 3640, 1240, 260, 5),
    ]

    floats = [
        sparkle(1460, 560, 76, rotate=12),
        sparkle(2400, 470, 58, rotate=-10),
        sparkle(90, 400, 64),
        sparkle(3720, 960, 70, rotate=8),
        sparkle(1730, 1330, 48),
        heart(2390, 680, 92, rotate=10),
        heart(1440, 790, 70, "#F9D2CC", rotate=-12),
        heart(300, 860, 80, "#F9D2CC", rotate=-6),
        heart(3600, 300, 84, rotate=12),
        heart(1390, 1260, 64, "#F9D2CC", rotate=-8),
    ]

    # 背景のやわらかい丸。端が切れても困らないものだけ
    blobs = [
        (cx, 690, 1180, 0.6),
        (560, 600, 760, 0.35),
        (3280, 600, 760, 0.35),
        (cx - 1500, 1500, 900, 0.25),
        (cx + 1500, 1500, 900, 0.25),
        (cx, -300, 900, 0.22),
    ]
    blob_html = "".join(
        f'<div class="blob" style="left:{x - d // 2}px; top:{y - d // 2}px;'
        f' width:{d}px; height:{d}px; opacity:{o}"></div>'
        for x, y, d, o in blobs
    )

    safe_w, safe_h = SAFE
    medallion = 440
    medallion_y = 496  # 上端（安全領域 y 493〜1154 に、主役と文字がおさまるように）

    return f"""<!doctype html>
<html lang="{copy['lang']}"><head><meta charset="utf-8">
<style>
@font-face {{ font-family: 'Zen Maru Gothic'; src: url('{(FONTS / "ZenMaruGothic-Black.ttf").as_uri()}'); font-weight: 900; }}
@font-face {{ font-family: 'Baloo 2'; src: url('{(FONTS / "Baloo2-ExtraBold.ttf").as_uri()}'); font-weight: 800; }}
html, body {{ margin: 0; padding: 0; }}
body {{
  width: {w}px; height: {h}px; overflow: hidden; position: relative;
  background: rgb{PAPER};
}}
.blob {{
  position: absolute; border-radius: 50%;
  background: radial-gradient(circle, #FBE0D6 0%, rgba(251,224,214,0) 70%);
}}
.sticker {{
  position: absolute; border-radius: 50%;
  background: #FFFFFF;
  border: 6px solid #F6DCD3;
  box-sizing: border-box;
  box-shadow: 0 28px 60px rgba(150, 96, 70, 0.14), 0 6px 14px rgba(150, 96, 70, 0.08);
  display: flex; align-items: center; justify-content: center;
}}
.sticker img {{ display: block; }}
.delta {{
  position: absolute; right: -18px; bottom: 6%;
  padding: 6px 22px 2px; border-radius: 999px;
  background: #FFFFFF; border: 5px solid #EADDD1;
  font-family: 'Baloo 2', sans-serif; font-weight: 800; font-size: 46px; line-height: 1.2;
  box-shadow: 0 10px 24px rgba(150, 96, 70, 0.12);
}}
.float {{ position: absolute; }}
.medallion {{
  position: absolute; left: {cx - medallion // 2}px; top: {medallion_y}px;
  width: {medallion}px; height: {medallion}px; border-radius: 50%;
  background: radial-gradient(circle at 50% 40%, #FFEFE9 0%, #F9D2CC 100%);
  border: 22px solid rgba(255,255,255,0.9);
  box-sizing: border-box;
  box-shadow: 0 34px 80px rgba(229, 140, 134, 0.26);
  display: flex; align-items: center; justify-content: center;
}}
.medallion img {{ width: 330px; height: 330px; display: block; }}
.headline {{
  position: absolute; left: 0; right: 0; top: {medallion_y + medallion + 46}px;
  text-align: center; white-space: nowrap;
  font-family: 'Zen Maru Gothic', 'Baloo 2', sans-serif; font-size: {copy['size']}px; font-weight: 900;
  letter-spacing: 0.04em; color: {INK};
}}
.headline em {{ font-style: normal; color: {ROSE}; }}
.safe {{
  position: absolute; left: {(w - safe_w) // 2}px; top: {(h - safe_h) // 2}px;
  width: {safe_w}px; height: {safe_h}px; outline: 4px dashed rgba(0, 120, 255, 0.7);
  display: none;
}}
body.guide .safe {{ display: block; }}
</style></head>
<body>
{blob_html}
{''.join(floats)}
{''.join(stickers)}
<div class="medallion"><img src="{char('lg_happy')}"></div>
<div class="headline">{copy['headline']}</div>
<div class="safe"></div>
<script>if (location.hash === '#guide') document.body.classList.add('guide');</script>
</body></html>"""


def render(html: str, dest: Path, guide: bool = False) -> None:
    with tempfile.TemporaryDirectory() as tmp:
        page = Path(tmp) / "header.html"
        page.write_text(html)
        shot = Path(tmp) / "shot.png"
        url = page.as_uri() + ("#guide" if guide else "")
        subprocess.run(
            [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
             "--allow-file-access-from-files", "--force-device-scale-factor=1",
             "--virtual-time-budget=3000",
             f"--window-size={SIZE[0]},{SIZE[1]}", f"--screenshot={shot}", url],
            check=True, capture_output=True,
        )
        image = Image.open(shot)
        assert image.size == SIZE, f"撮れた寸法が違う: {image.size}"
        # App Store はアルファを受け付けない。地の色で塗ってから RGB に落とす
        flat = Image.new("RGB", SIZE, PAPER)
        flat.paste(image.convert("RGBA"), mask=image.convert("RGBA").split()[3])
        dest.parent.mkdir(parents=True, exist_ok=True)
        flat.save(dest, optimize=True)


def main() -> None:
    for lang, copy in COPY.items():
        html = build_html(copy)
        render(html, OUT / lang / "header.png")
        # 安全領域を重ねた確認用。提出には使わない
        render(html, OUT / lang / "header_guide.png", guide=True)
        print(f"wrote {OUT / lang / 'header.png'}")


if __name__ == "__main__":
    main()
