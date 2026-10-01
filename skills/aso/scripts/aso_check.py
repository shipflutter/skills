#!/usr/bin/env python3
"""Audit fastlane store-listing metadata against App Store / Google Play limits
and metadata policy. Python 3.8+, no dependencies, never uploads anything.

  python3 aso_check.py                         # auto-detect fastlane/metadata in the cwd
  python3 aso_check.py --root path/to/app
  python3 aso_check.py --ios fastlane/metadata/ios --android fastlane/metadata/android
  python3 aso_check.py --format json > aso.json

Exit code: 1 if any check is an error (❌), else 0, so it can gate CI.

Counts characters as Unicode code points after trimming (what both consoles
show), ignoring the trailing newline fastlane files end with.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path

PASS, WARN, ERROR = 'pass', 'warning', 'error'
ICON = {PASS: '✅', WARN: '⚠️', ERROR: '❌'}

# (file, limit, required) — required + empty = error, optional + empty = warning.
IOS_FIELDS = [
    ('name.txt', 30, True),
    ('subtitle.txt', 30, True),
    ('keywords.txt', 100, True),
    ('promotional_text.txt', 170, False),
    ('description.txt', 4000, True),
    ('release_notes.txt', 4000, False),
]
PLAY_FIELDS = [
    ('title.txt', 30, True),
    ('short_description.txt', 80, True),
    ('full_description.txt', 4000, True),
]
PLAY_CHANGELOG_LIMIT = 500
# Indexed fields worth filling to the brim: unused characters are lost ranking.
FILL_TARGET = 0.9
FILL_FIELDS = {'name.txt', 'subtitle.txt', 'keywords.txt', 'title.txt', 'short_description.txt'}
# Apple's reference says the keyword field is "100 bytes", but App Store Connect counts characters:
# a ja keyword field of 100 characters / 220 UTF-8 bytes was accepted (checked 2026-10-01).

STOP = {
    'the', 'and', 'for', 'with', 'your', 'you', 'of', 'to', 'in', 'on', 'an', 'a', 'or', 'by', 'at', 'is', 'my',
    'it', 'its', 'de', 'la', 'el', 'en', 'y', 'los', 'las', 'para', 'con', 'que', 'un', 'una', 'del', 'por',  # es
    'le', 'les', 'des', 'et', 'du', 'pour', 'avec', 'vos', 'votre', 'dans',  # fr
    'e', 'o', 'os', 'as', 'do', 'da', 'com', 'seu', 'sua',  # pt
    'der', 'die', 'das', 'und', 'mit', 'für', 'ihre', 'zu',  # de
    'dan', 'yang', 'di', 'untuk', 'dengan', 'anda', 'ke', 'dari',  # id
    'và', 'của', 'cho', 'với', 'các', 'những', 'là', 'bạn', 'một',  # vi
    've', 'bir', 'ile', 'için', 'bu',  # tr
}

# Price, ranking and call-to-action words both stores reject in titles / short text.
CLAIMS = [
    'free', 'best', '#1', 'no.1', 'no 1', 'top', 'top 1', 'sale', 'discount', 'cheap', 'download now',
    'install now', 'app of the year', 'editor\'s choice', 'million downloads', 'new', 'popular', 'no ads',
    'miễn phí', 'tốt nhất', 'số 1', 'giảm giá', 'khuyến mãi', 'rẻ nhất', 'tải ngay',  # vi
    'gratuit', 'gratuite', 'meilleur', 'meilleure', 'promo', 'soldes', 'pas cher', 'téléchargez',  # fr
    'gratis', 'gratuito', 'mejor', 'oferta', 'descuento', 'barato', 'descarga ya',  # es
    'grátis', 'melhor', 'desconto', 'baixe agora',  # pt
    'kostenlos', 'beste', 'rabatt', 'jetzt herunterladen',  # de
    'migliore', 'sconto', 'scarica ora',  # it
    'ücretsiz', 'bedava', 'en iyi', 'indirim', 'ucuz', 'hemen indir',  # tr
    'terbaik', 'diskon', 'murah', 'unduh sekarang',  # id
    'مجاني', 'مجانا', 'مجانًا', 'الأفضل', 'أفضل', 'خصم', 'تخفيض', 'رخيص', 'حمّل الآن', 'حمل الآن',  # ar
    'मुफ़्त', 'मुफ्त', 'सबसे अच्छा', 'बेस्ट', 'छूट', 'सस्ता', 'अभी डाउनलोड',  # hi
    'бесплатно', 'лучший', 'скидка',  # ru
]
# Matched anywhere: no spaces between words, or particles glued on (무료로).
CLAIMS_UNSPACED = [
    '無料', '最高', 'ナンバーワン', '1位', 'セール', '割引', '激安', '今すぐダウンロード',  # ja
    '무료', '최고', '1위', '할인', '최저가', '지금 다운로드',  # ko
    '免费', '免費', '最好', '最佳', '第一名', '排名第一', '折扣', '打折', '促销', '促銷', '便宜',
    '立即下载', '立即下載',  # zh
    'ฟรี', 'ดีที่สุด', 'อันดับ 1', 'อันดับหนึ่ง', 'ลดราคา', 'ส่วนลด', 'ถูกที่สุด', 'ดาวน์โหลดเลย',  # th
]
# Apple says these waste keyword space: already implied or indexed elsewhere.
IOS_WASTED_KEYWORDS = {'app', 'apps', 'application', 'iphone', 'ipad', 'ios', 'apple', 'free'}
APPLE_MARKS = re.compile(r'\b(iphone|ipad|apple|ios|app store|siri|facetime)\b', re.I)
EMOJI = re.compile('[\U0001F000-\U0001FAFF☀-➿⬀-⯿️]')
SHOUT = re.compile(r'\b[A-Z]{4,}\b')  # AI, UI, iOS are fine
REPEAT_PUNCT = re.compile(r'([!?.*~★☆])\1{1,}')
WORD = re.compile(r"[^\W_][\w'’-]*")


@dataclass
class Check:
    locale: str
    store: str
    rule: str
    severity: str
    file: str = ''
    detail: str = ''
    found: list = field(default_factory=list)


def count(text: str) -> int:
    return len(text.strip())


def words(text: str) -> list[str]:
    return [w for w in WORD.findall(text.lower()) if len(w) > 1 and w not in STOP]


def claims(text: str) -> list[str]:
    low = text.lower()
    hits = [c for c in CLAIMS if re.search(r'(^|[^\w#])' + re.escape(c) + r'($|[^\w])', low)]
    return hits + [c for c in CLAIMS_UNSPACED if c in low]


def read(d: Path, name: str) -> str | None:
    p = d / name
    return p.read_text(encoding='utf-8') if p.is_file() else None


def rule(out: list, loc: str, store: str, name: str, found: list, sev: str, file: str = '', detail: str = ''):
    found = sorted(set(found), key=str)
    out.append(Check(loc, store, name, sev if found else PASS, file, detail if found else '', found))


def length(out: list, loc: str, store: str, file: str, text: str | None, limit: int, required: bool):
    n = count(text or '')
    if n > limit:
        sev, detail = ERROR, f'{n}/{limit}: {n - limit} over the limit'
    elif n == 0:
        sev, detail = (ERROR if required else WARN), f'empty ({"required" if required else "optional"})'
    elif file in FILL_FIELDS and n < FILL_TARGET * limit:
        sev, detail = WARN, f'{n}/{limit}: {limit - n} indexed characters unused'
    else:
        sev, detail = PASS, f'{n}/{limit}'
    out.append(Check(loc, store, 'length', sev, file, detail, [n, limit]))


def check_ios(d: Path, base: dict | None) -> list[Check]:
    loc, S, out = d.name, 'App Store', []
    v = {f: read(d, f) for f, _, _ in IOS_FIELDS}
    for f, limit, req in IOS_FIELDS:
        length(out, loc, S, f, v[f], limit, req)
    name, sub, raw = (v['name.txt'] or '').strip(), (v['subtitle.txt'] or '').strip(), (v['keywords.txt'] or '').strip()
    kws = [k.strip().lower() for k in raw.split(',') if k.strip()]
    title_words = set(words(name)) | set(words(sub))
    kw_words = [w for k in kws for w in words(k)]

    rule(out, loc, S, 'keyword-separators', [m for m in ('space next to a comma' if re.search(r'\s,|,\s', raw) else '',
                                                         'trailing comma' if raw.endswith(',') else '') if m],
         WARN, 'keywords.txt', 'use "a,b,c": spaces and trailing commas burn characters')
    seen, dup = set(), []
    for k in kws:
        (dup.append(k) if k in seen else seen.add(k))
    rule(out, loc, S, 'keyword-duplicates', dup, WARN, 'keywords.txt', 'listed more than once')
    rule(out, loc, S, 'keyword-in-name-or-subtitle',
         [k for k in kws if words(k) and all(w in title_words for w in words(k))], WARN, 'keywords.txt',
         'already indexed from the name/subtitle; free these characters')
    plural = [w for w in set(kw_words) | title_words
              if len(w) > 3 and w.endswith('s') and w[:-1] in (set(kw_words) | title_words) and w in kw_words]
    rule(out, loc, S, 'keyword-plurals', plural, WARN, 'keywords.txt',
         'singular and plural both present; Apple matches plurals, keep one')
    rule(out, loc, S, 'keyword-wasted-words', [w for w in kw_words if w in IOS_WASTED_KEYWORDS], WARN,
         'keywords.txt', '"app", device names and "free" add nothing')
    rule(out, loc, S, 'keyword-multiword', [k for k in kws if len(k.split()) > 1], WARN, 'keywords.txt',
         'allowed, but Apple combines single words across name+subtitle+keywords, so phrases waste characters')
    rule(out, loc, S, 'subtitle-repeats-name', [w for w in words(sub) if w in set(words(name))], WARN,
         'subtitle.txt', 'subtitle should add new keywords')
    rule(out, loc, S, 'claims', claims(f'{name} {sub} {raw}'), WARN, 'name/subtitle/keywords',
         'price, ranking or call-to-action words (Guideline 2.3.7)')
    rule(out, loc, S, 'emoji', EMOJI.findall(f'{name}{sub}{raw}'), WARN, 'name/subtitle/keywords')
    rule(out, loc, S, 'apple-trademarks', APPLE_MARKS.findall(f'{name} {sub}'), WARN, 'name/subtitle',
         'Apple trademarks in the name/subtitle risk rejection (Guideline 5.2.5)')
    missing = [f for f in ('privacy_url.txt', 'support_url.txt') if not (read(d, f) or '').strip().startswith('https://')]
    rule(out, loc, S, 'urls', missing, WARN, '', 'needs an https URL')
    if base is not None and d.name != base['locale'] and raw and raw == base['keywords']:
        rule(out, loc, S, 'keywords-copied', [base['locale']], WARN, 'keywords.txt',
             'same keywords as the base locale: write local search terms (and use this slot for '
             'cross-localization)')
    return out


def png_size(p: Path) -> tuple[int, int] | None:
    b = p.read_bytes()[:64]
    if b[:8] == b'\x89PNG\r\n\x1a\n':
        return struct.unpack('>II', b[16:24])
    data = p.read_bytes()
    if data[:2] == b'\xff\xd8':  # JPEG: walk to the first SOFn marker
        i = 2
        while i < len(data) - 9:
            if data[i] != 0xFF:
                i += 1
                continue
            marker, seg = data[i + 1], struct.unpack('>H', data[i + 2:i + 4])[0]
            if marker in (0xC0, 0xC1, 0xC2):
                h, w = struct.unpack('>HH', data[i + 5:i + 9])
                return w, h
            i += 2 + seg
    return None


def check_play(d: Path, base: dict | None) -> list[Check]:
    loc, S, out = d.name, 'Google Play', []
    v = {f: read(d, f) for f, _, _ in PLAY_FIELDS}
    for f, limit, req in PLAY_FIELDS:
        length(out, loc, S, f, v[f], limit, req)
    logs = sorted((d / 'changelogs').glob('*.txt'), key=lambda p: int(p.stem) if p.stem.isdigit() else -1)
    if logs:
        length(out, loc, S, f'changelogs/{logs[-1].name}', logs[-1].read_text(encoding='utf-8'),
               PLAY_CHANGELOG_LIMIT, False)
    title, short, full = ((v[f] or '').strip() for f in ('title.txt', 'short_description.txt', 'full_description.txt'))
    rule(out, loc, S, 'claims', claims(f'{title} {short}'), ERROR, 'title/short_description',
         'Play metadata policy bans price, ranking and CTA claims here')
    rule(out, loc, S, 'emoji', EMOJI.findall(f'{title}{short}'), ERROR, 'title/short_description')
    rule(out, loc, S, 'all-caps', SHOUT.findall(f'{title} {short}'), WARN, 'title/short_description',
         'ALL CAPS only for a registered brand')
    rule(out, loc, S, 'repeated-punctuation', [m.group(0) for m in REPEAT_PUNCT.finditer(f'{title} {short}')], ERROR,
         'title/short_description')
    w = words(full)
    stuffed = []
    if len(w) >= 100:
        freq: dict[str, int] = {}
        for x in w:
            freq[x] = freq.get(x, 0) + 1
        stuffed = [f'{k} {100 * n / len(w):.1f}%' for k, n in freq.items() if n / len(w) > 0.03 and len(k) > 2]
    rule(out, loc, S, 'keyword-stuffing', stuffed, WARN, 'full_description.txt', 'a word above ~3% density')
    low = full.lower()
    rule(out, loc, S, 'title-keywords-in-description', [x for x in words(title) if full and x not in low], WARN,
         'full_description.txt', 'Play ranks on the description too: repeat title keywords naturally')
    head = low[:300]
    rule(out, loc, S, 'keywords-early', [x for x in words(title) if full and x in low and x not in head], WARN,
         'full_description.txt', 'title keywords appear, but not in the first ~300 characters')
    if base is not None and d.name != base['locale'] and short and short == base['short']:
        rule(out, loc, S, 'short-copied', [base['locale']], WARN, 'short_description.txt', 'not localized')

    img = d / 'images'
    if img.is_dir():
        for name, want in (('icon', (512, 512)), ('featureGraphic', (1024, 500))):
            files = list(img.glob(name + '.*'))
            if not files and base is not None and d.name != base['locale']:
                continue  # locales without their own graphic fall back to the default listing's
            size = png_size(files[0]) if files else None
            bad = [] if size == want else [f'{name}: {size or "missing"} (want {want[0]}x{want[1]})']
            rule(out, loc, S, f'{name}-size', bad, WARN if not files else ERROR, f'images/{name}')
        shots = sorted((img / 'phoneScreenshots').glob('*.*')) if (img / 'phoneScreenshots').is_dir() else []
        bad = [] if 2 <= len(shots) <= 8 else [f'{len(shots)} phone screenshots (want 2-8, 4+ to be featured)']
        for s in shots:
            sz = png_size(s)
            if sz and (min(sz) < 320 or max(sz) > 3840 or max(sz) > 2 * min(sz)):
                bad.append(f'{s.name}: {sz[0]}x{sz[1]}')
        rule(out, loc, S, 'phone-screenshots', bad, ERROR if not shots else WARN, 'images/phoneScreenshots')
    video = (read(d, 'video.txt') or '').strip()
    rule(out, loc, S, 'video-url', [video] if video and 'youtu' not in video else [], WARN, 'video.txt',
         'must be a YouTube URL')
    return out


def find_dirs(root: Path) -> tuple[Path | None, Path | None]:
    def has(d: Path, f: str) -> bool:
        return d.is_dir() and any((c / f).is_file() for c in d.iterdir() if c.is_dir())
    ios = next((d for d in (root / 'fastlane/metadata/ios', root / 'ios/fastlane/metadata', root / 'fastlane/metadata')
                if has(d, 'name.txt')), None)
    play = next((d for d in (root / 'fastlane/metadata/android', root / 'android/fastlane/metadata/android')
                 if has(d, 'title.txt')), None)
    return ios, play


def run(meta: Path, store: str) -> list[Check]:
    locales = sorted(c for c in meta.iterdir() if c.is_dir() and not c.name.startswith(('.', 'review_information',
                                                                                         'trade_representative')))
    pick = next((c for c in locales if c.name.startswith('en')), locales[0] if locales else None)
    out: list[Check] = []
    if store == 'ios':
        base = {'locale': pick.name, 'keywords': (read(pick, 'keywords.txt') or '').strip()} if pick else None
        for c in locales:
            if (c / 'name.txt').exists() or (c / 'keywords.txt').exists():
                out += check_ios(c, base)
    else:
        base = {'locale': pick.name, 'short': (read(pick, 'short_description.txt') or '').strip()} if pick else None
        for c in locales:
            if (c / 'title.txt').exists():
                out += check_play(c, base)
    return out


def report_md(checks: list[Check], dirs: dict) -> str:
    lines = ['# ASO audit', '']
    for store, d in dirs.items():
        cs = [c for c in checks if c.store == store]
        if not cs:
            continue
        files = list(dict.fromkeys(c.file for c in cs if c.rule == 'length'))
        locs = list(dict.fromkeys(c.locale for c in cs))
        lines += [f'## {store} · `{d}` · {len(locs)} locales', '',
                  '| locale | ' + ' | '.join(f.replace('.txt', '') for f in files) + ' | issues |',
                  '|' + '---|' * (len(files) + 2)]
        for loc in locs:
            row = []
            for f in files:
                c = next((c for c in cs if c.locale == loc and c.file == f and c.rule == 'length'), None)
                row.append(f'{c.found[0]}/{c.found[1]} {ICON[c.severity]}' if c else '—')
            n = sum(1 for c in cs if c.locale == loc and c.severity != PASS)
            lines.append(f'| {loc} | ' + ' | '.join(row) + f' | {n} |')
        lines.append('')
    bad = [c for c in checks if c.severity != PASS]
    if bad:
        lines += ['## Issues', '']
        for c in sorted(bad, key=lambda c: (c.severity != ERROR, c.store, c.locale)):
            what = c.detail if c.rule == 'length' else f'{", ".join(map(str, c.found))}' + (f' — {c.detail}' if c.detail else '')
            lines.append(f'- {ICON[c.severity]} **{c.store} {c.locale}** `{c.file}` · {c.rule}: {what}')
        lines.append('')
    passed = sum(1 for c in checks if c.severity == PASS)
    errors = sum(1 for c in checks if c.severity == ERROR)
    lines.append(f'**Score: {passed}/{len(checks)} checks passed · {errors} errors · {len(bad) - errors} warnings**')
    return '\n'.join(lines)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--root', default='.', help='project root (default: cwd)')
    ap.add_argument('--ios', help='App Store metadata dir (locale folders with name.txt)')
    ap.add_argument('--android', help='Google Play metadata dir (locale folders with title.txt)')
    ap.add_argument('--format', choices=['md', 'json'], default='md')
    a = ap.parse_args()
    root = Path(a.root)
    ios, play = find_dirs(root)
    ios = Path(a.ios) if a.ios else ios
    play = Path(a.android) if a.android else play
    if not ios and not play:
        sys.exit('No fastlane metadata found. Pass --ios / --android, or run `fastlane deliver download_metadata` '
                 '/ `fastlane supply init` first.')
    checks = (run(ios, 'ios') if ios else []) + (run(play, 'play') if play else [])
    if a.format == 'json':
        print(json.dumps([asdict(c) for c in checks], ensure_ascii=False, indent=2))
    else:
        print(report_md(checks, {'App Store': ios, 'Google Play': play}))
    sys.exit(1 if any(c.severity == ERROR for c in checks) else 0)


if __name__ == '__main__':
    main()
