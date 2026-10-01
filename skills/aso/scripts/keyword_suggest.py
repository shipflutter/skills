#!/usr/bin/env python3
"""Keyword ideas straight from the stores' own search boxes. No API key, no deps.

  python3 keyword_suggest.py "habit tracker"                      # both stores, US, English
  python3 keyword_suggest.py "habit tracker" --az                 # + "habit tracker a".."z" long-tail
  python3 keyword_suggest.py "quản lý chi tiêu" --country vn --lang vi
  python3 keyword_suggest.py "habit tracker" --competition        # top-10 App Store results per term
  python3 keyword_suggest.py "habit tracker" --format csv > kw.csv

Sources (all public, unauthenticated, may change without notice):
  - App Store: search hints (the autocomplete under the App Store search box)
  - Google Play: batchexecute IJ4APc (the autocomplete under the Play search box)
  - App Store competition: iTunes Search API (documented, ~20 calls/minute)

Suggestion order is the store's own ranking, so a lower position means more
searched. It is a popularity signal, not a volume number.
"""

from __future__ import annotations

import argparse
import csv
import json
import plistlib
import re
import statistics
import sys
import time
import urllib.parse
import urllib.request

# App Store storefront ids (X-Apple-Store-Front) for the hints endpoint.
STOREFRONTS = {
    'us': 143441, 'gb': 143444, 'ca': 143455, 'au': 143460, 'de': 143443,
    'fr': 143442, 'es': 143454, 'it': 143450, 'nl': 143452, 'br': 143503,
    'mx': 143468, 'jp': 143462, 'kr': 143466, 'cn': 143465, 'tw': 143470,
    'hk': 143463, 'vn': 143471, 'th': 143475, 'id': 143476, 'my': 143473,
    'ph': 143474, 'sg': 143464, 'in': 143467, 'sa': 143479, 'ae': 143481,
    'tr': 143480, 'ru': 143469, 'pl': 143478, 'se': 143456,
}

UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15'
PAUSE = 0.35  # seconds between requests; be polite


def _get(url: str, headers: dict | None = None, data: bytes | None = None) -> bytes:
    req = urllib.request.Request(url, data=data, headers={'User-Agent': UA, **(headers or {})})
    with urllib.request.urlopen(req, timeout=20) as r:
        return r.read()


def apple_hints(term: str, country: str) -> list[str]:
    sf = STOREFRONTS.get(country)
    if sf is None:
        raise SystemExit(f'No storefront id for "{country}". Known: {", ".join(sorted(STOREFRONTS))}')
    url = ('https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints'
           '?clientApplication=Software&term=' + urllib.parse.quote(term))
    data = plistlib.loads(_get(url, {'X-Apple-Store-Front': f'{sf}-1,29'}))
    return [h['term'] for h in data.get('hints', []) if h.get('term')]


def play_suggest(term: str, country: str, lang: str) -> list[str]:
    payload = [[None, [term], [10], [2], 4]]
    body = 'f.req=' + urllib.parse.quote(json.dumps([[['IJ4APc', json.dumps(payload), None, 'generic']]]))
    url = (f'https://play.google.com/_/PlayStoreUi/data/batchexecute?rpcids=IJ4APc'
           f'&hl={lang}&gl={country.upper()}')
    text = _get(url, {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
                body.encode()).decode('utf-8')
    for line in text.splitlines():
        if not line.startswith('[['):
            continue
        for row in json.loads(line):
            if row and row[0] == 'wrb.fr' and isinstance(row[2], str):
                rows = (json.loads(row[2]) or [[[]]])[0][0] or []
                return [r[0] for r in rows if r and r[0]]
    return []


def apple_competition(term: str, country: str) -> dict:
    """Top-10 App Store results for a term and how beatable they look."""
    url = ('https://itunes.apple.com/search?entity=software&limit=10&country=' + country
           + '&term=' + urllib.parse.quote(term))
    results = json.loads(_get(url)).get('results', [])
    words = [w for w in term.lower().split() if len(w) > 1]
    ratings = [r.get('userRatingCount', 0) for r in results]
    in_title = sum(1 for r in results if all(w in r.get('trackName', '').lower() for w in words))
    weak = sum(1 for n in ratings if n < 1000)
    return {
        'top_app': results[0]['trackName'] if results else '',
        'title_match': in_title,           # top-10 apps with every word of the term in the name
        'weak_apps': weak,                 # top-10 apps under 1,000 ratings
        'median_ratings': int(statistics.median(ratings)) if ratings else 0,
        # 0..100: higher = more room. Weak apps and missing title matches both
        # mean the term is not yet owned by strong, targeted listings.
        'openness': round(100 * (0.6 * weak / 10 + 0.4 * (10 - in_title) / 10)) if results else 100,
    }


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('seed', nargs='+', help='one or more seed terms')
    ap.add_argument('--store', choices=['both', 'apple', 'play'], default='both')
    ap.add_argument('--country', default='us', help='two-letter storefront, e.g. us, vn, jp')
    ap.add_argument('--lang', default='en', help='Google Play UI language, e.g. en, vi, ja')
    ap.add_argument('--az', action='store_true', help='also query "<seed> a" .. "<seed> z"')
    ap.add_argument('--competition', action='store_true', help='score top-10 App Store results per term')
    ap.add_argument('--format', choices=['md', 'csv', 'json'], default='md')
    a = ap.parse_args()
    country = a.country.lower()

    # term -> {'apple': best position, 'play': best position}
    found: dict[str, dict[str, int]] = {}
    queries = []
    for seed in a.seed:
        seed = seed.strip().lower()
        queries.append(seed)
        if a.az:
            queries += [f'{seed} {c}' for c in 'abcdefghijklmnopqrstuvwxyz']

    stores = ['apple', 'play'] if a.store == 'both' else [a.store]
    failures = 0
    for q in queries:
        for store in stores:
            try:
                terms = apple_hints(q, country) if store == 'apple' else play_suggest(q, country, a.lang)
            except Exception as e:  # network hiccup or endpoint change: keep going
                failures += 1
                print(f'! {store} "{q}": {e}', file=sys.stderr)
                terms = []
            for pos, t in enumerate(terms, 1):
                t = t.strip().lower()
                slot = found.setdefault(t, {})
                slot[store] = min(slot.get(store, 99), pos)
            time.sleep(PAUSE)

    rows = []
    for term, pos in found.items():
        row = {'term': term, 'apple_pos': pos.get('apple', ''), 'play_pos': pos.get('play', ''),
               'stores': len(pos), 'words': len(term.split()),
               # Hints like "habit tracker: coolio habits" are app names, not searches to target.
               'app_name': 'yes' if re.search(r':| - | – ', term) else ''}
        rows.append(row)
    # Terms both stores suggest first, then by best position.
    rows.sort(key=lambda r: (-r['stores'], min(p for p in (r['apple_pos'], r['play_pos']) if p != '')))

    if a.competition:
        for r in rows:
            try:
                r.update(apple_competition(r['term'], country))
            except Exception as e:
                print(f'! competition "{r["term"]}": {e}', file=sys.stderr)
            time.sleep(3.1)  # iTunes Search API allows ~20 calls/minute

    if a.format == 'json':
        json.dump(rows, sys.stdout, ensure_ascii=False, indent=2)
        print()
    elif a.format == 'csv':
        if rows:
            w = csv.DictWriter(sys.stdout, fieldnames=list(rows[0].keys()))
            w.writeheader()
            w.writerows(rows)
    else:
        cols = list(rows[0].keys()) if rows else ['term']
        print(f'# Keyword ideas · {", ".join(a.seed)} · {country.upper()} · {len(rows)} terms\n')
        print('| ' + ' | '.join(cols) + ' |')
        print('|' + '---|' * len(cols))
        for r in rows:
            print('| ' + ' | '.join(str(r.get(c, '')) for c in cols) + ' |')
        print('\napple_pos / play_pos: position in that store\'s autocomplete (1 = suggested first).')
        if a.competition:
            print('openness: 0-100 from the App Store top 10; higher = weaker or less targeted competitors.')
    if failures:
        print(f'\n{failures} requests failed (see stderr).', file=sys.stderr)


if __name__ == '__main__':
    main()
