#!/usr/bin/env python3
"""L("…") / LF("…") / .failure("…") / App Intents の文言のキーが、ja・en の両方の訳文に入っているかを確かめる。

    python3 tools/check_strings.py   # 足りなければ一覧を出して終了コード 1

英語の単数・複数は en.lproj/Localizable.stringsdict にあればよい。
"""
import glob
import plistlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCES = ["kawaii_taiju_kanri/**/*.swift", "Shared/**/*.swift", "KawaiiWidget/**/*.swift"]
# 日のタグは保存するキーで、表示するときに L(tag) で訳す
TAGS = ["飲み会", "外食", "寝不足", "のんびり", "運動した"]


def keys_in_code():
    keys = []
    for pattern in SOURCES:
        for path in sorted(glob.glob(str(ROOT / pattern), recursive=True)):
            # .failure("…") は、出すときに L() で訳す鍵（Store/ICloudBackup.swift）
            # App Intents の文言は、Localizable.strings から iOS が引く
            for m in re.finditer(
                r'''(?:\bLF?|\.failure|IntentDescription|IntentDialog|\.displayName|\.description)\("((?:[^"\\]|\\.)*)"'''
                r'''|LocalizedStringResource = "((?:[^"\\]|\\.)*)"'''
                r'''|(?:shortTitle|@Parameter\(title): "((?:[^"\\]|\\.)*)"''',
                Path(path).read_text(),
            ):
                key = m.group(1) or m.group(2) or m.group(3)
                if key not in keys:
                    keys.append(key)
    return keys + [t for t in TAGS if t not in keys]


def keys_in_strings(path):
    text = Path(path).read_text()
    return {m.group(1) for m in re.finditer(r'^"((?:[^"\\]|\\.)*)"\s*=', text, re.M)}


def main():
    code = keys_in_code()
    ja = keys_in_strings(ROOT / "Shared/ja.lproj/Localizable.strings")
    en = keys_in_strings(ROOT / "Shared/en.lproj/Localizable.strings")
    with open(ROOT / "Shared/en.lproj/Localizable.stringsdict", "rb") as f:
        en |= set(plistlib.load(f).keys())
    ok = True
    for name, table in (("ja", ja), ("en", en)):
        missing = [k for k in code if k not in table]
        if missing:
            ok = False
            print(f"{name} に無いキー:")
            for k in missing:
                print(f'  "{k}"')
    unused = sorted((ja | en) - set(code))
    if unused:
        print("使っていないキー（消してよい）:")
        for k in unused:
            print(f'  "{k}"')
    print("OK" if ok else "NG")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
