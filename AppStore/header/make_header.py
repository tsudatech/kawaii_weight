#!/usr/bin/env python3
"""App Store のプロダクトページ用ヘッダ画像を書き出す。

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

絵の内容は「もどるまで見守り」（左から右へ）:
飲み会で増えて雲がかかる → キャラが応援しながら見守る → もとの体重にもどって雲がはれる。
見出しはサブタイトル（体重きろく_AppStore掲載情報.md §2）と同じ意味にそろえる。

絵はアプリと同じキャラ画像（Shared/Characters.xcassets）、文字はアプリと同じ Zen Maru Gothic・Baloo 2。
HTML に組んで Chrome のヘッドレスで撮り、最後に透過を落として書き出す。
"""

import subprocess
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

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
MINT = "#9FD3C7"
MINT_INK = "#3E9B86"
UP = "#D06A63"
GOLD = "#F3CA89"
CHEEK = "#F9D2CC"

COPY = {
    "ja": {
        "lang": "ja",
        "headline": "増えても、<em>もどるまで見守る。</em>",
        "size": 106,
        "tag": "飲み会",
        "cleared": "もどった！",
        "usual": "いつもの体重",
    },
    "en": {
        "lang": "en",
        "headline": "Up a bit? <em>Buddy waits with you.</em>",
        "size": 100,  # 安全領域（幅 1646）におさまる大きさ
        "tag": "Night out",
        "cleared": "Back to normal!",
        "usual": "Your usual weight",
    },
}

# 体重の線（日ごとの点）。y が小さいほど重い。BASE が「いつもの体重」
BASE = 1296
TREND = [
    (-60, 1300), (170, 1292), (400, 1130), (640, 900), (880, 1010), (1130, 1160),
    (1420, 1232), (1760, 1270), (2120, 1284), (2520, 1298), (2880, 1294),
    (3230, 1296), (3560, 1292), (3900, 1296),
]


def char_uri(name: str, tmp: Path) -> str:
    """キャラ画像の URL。元の PNG は体が透明なので、輪郭の内側を白く塗ったものを tmp に作る
    （色のついた背景に置くと、体に背景の色が透けるため）"""
    image = Image.open(CHARS / f"lg_{name}.imageset" / f"lg_{name}.png").convert("RGBA")
    # 外側（四隅からつながる透明なところ）以外を「内側」とする
    solid = image.getchannel("A").point(lambda a: 255 if a >= 128 else 0)
    margin = Image.new("L", (image.width + 2, image.height + 2), 0)
    margin.paste(solid, (1, 1))
    ImageDraw.floodfill(margin, (0, 0), 128)
    inside = margin.crop((1, 1, image.width + 1, image.height + 1)).point(lambda v: 0 if v == 128 else 255)
    # 輪郭の外へ白がはみ出さないように少し細らせる
    inside = inside.filter(ImageFilter.MinFilter(5))
    filled = Image.new("RGBA", image.size, (255, 255, 255, 0))
    filled.paste((255, 255, 255, 255), mask=inside)
    filled.alpha_composite(image)
    dest = tmp / f"lg_{name}.png"
    filled.save(dest)
    return dest.as_uri()


def hamster(name: str, x: int, feet_y: int, d: int, tmp: Path) -> str:
    """キャラを置く。(x, feet_y) は足もとの中心（画像の下に少し余白があるぶん下げる）"""
    top = feet_y - round(d * 0.95)
    return f'<img class="float" src="{char_uri(name, tmp)}" style="left:{x - d // 2}px; top:{top}px; width:{d}px; height:{d}px">'


def sparkle(x: int, y: int, d: int, color: str = GOLD, rotate: float = 0) -> str:
    return f"""
<svg class="float" style="left:{x - d // 2}px; top:{y - d // 2}px; width:{d}px; height:{d}px; transform: rotate({rotate}deg)"
     viewBox="0 0 100 100"><path d="M50 0 C55 38 62 45 100 50 C62 55 55 62 50 100 C45 62 38 55 0 50 C38 45 45 38 50 0Z" fill="{color}"/></svg>"""


def heart(x: int, y: int, d: int, color: str = ROSE, rotate: float = 0) -> str:
    return f"""
<svg class="float" style="left:{x - d // 2}px; top:{y - d // 2}px; width:{d}px; height:{d}px; transform: rotate({rotate}deg)"
     viewBox="0 0 100 100"><path d="M50 88 C20 66 4 48 4 30 C4 16 15 6 28 6 C38 6 46 12 50 20 C54 12 62 6 72 6 C85 6 96 16 96 30 C96 48 80 66 50 88Z" fill="{color}"/></svg>"""


def cloud(x: int, y: int, w: int, opacity: float = 1) -> str:
    """もやもやの雲。(x, y) は中心"""
    h = round(w * 0.62)
    return f"""
<svg class="float" style="left:{x - w // 2}px; top:{y - h // 2}px; width:{w}px; height:{h}px; opacity:{opacity}"
     viewBox="0 0 200 124"><path d="M52 112 C24 112 6 94 6 72 C6 50 24 34 46 36 C52 16 72 6 94 8 C116 10 132 22 138 40 C164 36 192 50 194 76 C196 98 176 112 152 112Z"
     fill="#FFFFFF" stroke="#BFD6DA" stroke-width="7" stroke-linejoin="round"/></svg>"""


def smooth_path(points: list[tuple[int, int]]) -> str:
    """点をなめらかにつなぐ線（Catmull-Rom を3次ベジェに直したもの）"""
    d = f"M{points[0][0]} {points[0][1]}"
    for i in range(len(points) - 1):
        p0 = points[max(i - 1, 0)]
        p1, p2 = points[i], points[i + 1]
        p3 = points[min(i + 2, len(points) - 1)]
        c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        d += f" C{c1[0]:.0f} {c1[1]:.0f} {c2[0]:.0f} {c2[1]:.0f} {p2[0]} {p2[1]}"
    return d


def graph(copy: dict) -> str:
    w, h = SIZE
    line = smooth_path(TREND)
    area = f"{line} L{TREND[-1][0]} {h + 10} L{TREND[0][0]} {h + 10}Z"
    dots = "".join(
        f'<circle cx="{x}" cy="{y}" r="17" fill="#FFFFFF" stroke="{ROSE}" stroke-width="10"/>'
        for x, y in TREND[1:-1]
    )
    return f"""
<svg class="float" style="left:0; top:0" width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <path d="{area}" fill="#FBEDE7" opacity="0.75"/>
  <line x1="0" y1="{BASE}" x2="{w}" y2="{BASE}" stroke="{MINT}" stroke-width="9" stroke-dasharray="4 30" stroke-linecap="round"/>
  <path d="{line}" fill="none" stroke="{ROSE}" stroke-width="13" stroke-linecap="round" stroke-linejoin="round"/>
  {dots}
</svg>
<div class="usual" style="left:{w // 2}px; top:{BASE + 42}px">{copy['usual']}</div>"""


def build_html(copy: dict, tmp: Path) -> str:
    w, h = SIZE
    cx = w // 2
    safe_w, safe_h = SAFE
    safe_top = (h - safe_h) // 2

    peak_x, peak_y = 640, 900
    clear_x = 3230

    floats = [
        # 左：雲の下。右へ行くほど雲がうすく小さくなる
        cloud(560, 215, 520),
        cloud(940, 320, 300),
        cloud(1400, 215, 200, 0.75),
        cloud(1900, 150, 130, 0.45),
        # 右：はれた空
        sparkle(2860, 640, 80, rotate=10),
        sparkle(3620, 620, 96, rotate=-8),
        sparkle(3500, 330, 60),
        sparkle(2980, 300, 56, rotate=12),
        heart(3660, 930, 84, rotate=12),
        heart(2830, 960, 66, CHEEK, rotate=-10),
        # 中央の主役のまわり
        heart(1460, 700, 62, CHEEK, rotate=-12),
        sparkle(2380, 620, 66, rotate=8),
    ]

    return f"""<!doctype html>
<html lang="{copy['lang']}"><head><meta charset="utf-8">
<style>
@font-face {{ font-family: 'Zen Maru Gothic'; src: url('{(FONTS / "ZenMaruGothic-Black.ttf").as_uri()}'); font-weight: 900; }}
@font-face {{ font-family: 'Baloo 2'; src: url('{(FONTS / "Baloo2-ExtraBold.ttf").as_uri()}'); font-weight: 800; }}
html, body {{ margin: 0; padding: 0; }}
body {{
  width: {w}px; height: {h}px; overflow: hidden; position: relative;
  background: linear-gradient(90deg, #E4F2F3 0%, #F4F6F2 26%, rgb{PAPER} 48%, #FFF6E8 100%);
}}
.glow {{
  position: absolute; left: {clear_x - 1000}px; top: -300px; width: 2000px; height: 2000px; border-radius: 50%;
  background: radial-gradient(circle, rgba(243,202,137,0.42) 0%, rgba(243,202,137,0) 66%);
}}
.float {{ position: absolute; }}
.pill {{
  position: absolute; transform: translateX(-50%); white-space: nowrap;
  padding: 10px 40px; border-radius: 999px; background: #FFFFFF; border: 6px solid #EADDD1;
  font-family: 'Baloo 2', 'Zen Maru Gothic', sans-serif; font-weight: 800; font-size: 62px; line-height: 1.25;
  box-shadow: 0 12px 28px rgba(150, 96, 70, 0.12);
}}
.chip {{
  position: absolute; transform: translateX(-50%); white-space: nowrap;
  padding: 8px 36px; border-radius: 999px; background: {CHEEK}; color: {INK};
  font-family: 'Zen Maru Gothic', 'Baloo 2', sans-serif; font-weight: 900; font-size: 52px; line-height: 1.35;
}}
.usual {{
  position: absolute; transform: translateX(-50%); white-space: nowrap; color: {MINT_INK};
  font-family: 'Zen Maru Gothic', 'Baloo 2', sans-serif; font-weight: 900; font-size: 50px;
}}
.headline {{
  position: absolute; left: 0; right: 0; top: {safe_top + 462}px;
  text-align: center; white-space: nowrap;
  font-family: 'Zen Maru Gothic', 'Baloo 2', sans-serif; font-size: {copy['size']}px; font-weight: 900;
  letter-spacing: 0.03em; color: {INK};
}}
.headline em {{ font-style: normal; color: {UP}; }}
.safe {{
  position: absolute; left: {(w - safe_w) // 2}px; top: {safe_top}px;
  width: {safe_w}px; height: {safe_h}px; outline: 4px dashed rgba(0, 120, 255, 0.7);
  display: none;
}}
body.guide .safe {{ display: block; }}
</style></head>
<body>
<div class="glow"></div>
{graph(copy)}
{''.join(floats)}
{hamster('trouble', peak_x, peak_y - 8, 500, tmp)}
<div class="pill" style="left:{peak_x + 310}px; top:{peak_y - 250}px; color:{UP}">+0.6kg</div>
<div class="chip" style="left:230px; top:1050px">{copy['tag']}</div>
{hamster('cheer', cx, safe_top + 462, 470, tmp)}
{hamster('happy', clear_x, BASE - 8, 560, tmp)}
<div class="pill" style="left:{clear_x}px; top:{BASE - 700}px; color:{MINT_INK}">{copy['cleared']}</div>
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
    with tempfile.TemporaryDirectory() as tmp:
        for lang, copy in COPY.items():
            html = build_html(copy, Path(tmp))
            render(html, OUT / lang / "header.png")
            # 安全領域を重ねた確認用。提出には使わない
            render(html, OUT / lang / "header_guide.png", guide=True)
            print(f"wrote {OUT / lang / 'header.png'}")


if __name__ == "__main__":
    main()
