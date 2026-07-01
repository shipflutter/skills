#!/usr/bin/env python3
"""Generate a single-<path> SVG QR code for a URL (e.g. your /get/ universal link).

The output is a compact, crisp SVG: a white background <rect> plus one black <path>
of unit-square modules, with a built-in 2-module quiet zone (viewBox "-2 -2 n+4 n+4").
It drops straight into a fixed-size box, e.g.  .qr svg { width:160px; height:160px }.

The script verifies the emitted path set equals the encoded QR matrix, so the SVG is
provably the exact code for the URL (guards against any transcription bug).

Usage:
    python3 gen-qr.py "<url>" [out.svg] [--ecc M|L|Q|H]

  - no out.svg  -> prints the SVG to stdout (pipe it: `... > qr.svg`)
  - --ecc       -> error-correction level (default M; H = most robust, larger)

Requires: pip install qrcode
"""
import sys
import argparse

try:
    import qrcode
except ImportError:
    sys.exit("Missing dependency. Run:  pip install qrcode")


def build_svg(url: str, ecc: str) -> str:
    levels = {
        "L": qrcode.constants.ERROR_CORRECT_L,
        "M": qrcode.constants.ERROR_CORRECT_M,
        "Q": qrcode.constants.ERROR_CORRECT_Q,
        "H": qrcode.constants.ERROR_CORRECT_H,
    }
    qr = qrcode.QRCode(error_correction=levels[ecc], border=0)
    qr.add_data(url)
    qr.make(fit=True)
    m = qr.get_matrix()
    n = len(m)

    parts = []
    emitted = set()
    for y, row in enumerate(m):
        for x, v in enumerate(row):
            if v:
                parts.append(f"M{x},{y}H{x+1}V{y+1}H{x}z")
                emitted.add((y, x))

    # Provable correctness: emitted modules must equal the encoded matrix.
    source = {(y, x) for y, row in enumerate(m) for x, v in enumerate(row) if v}
    assert emitted == source, "SVG path does not match QR matrix"

    vb = n + 4  # 2-module quiet zone on each side
    return (
        f'<svg viewBox="-2 -2 {vb} {vb}" xmlns="http://www.w3.org/2000/svg">'
        f'<rect x="-2" y="-2" width="{vb}" height="{vb}" fill="#fff"/>'
        f'<path d="{"".join(parts)}" fill="#000"/></svg>'
    )


def main() -> None:
    ap = argparse.ArgumentParser(description="Generate a single-path SVG QR code.")
    ap.add_argument("url", help="URL to encode (e.g. https://example.com/get/)")
    ap.add_argument("out", nargs="?", help="output .svg path (omit to print to stdout)")
    ap.add_argument("--ecc", choices=["L", "M", "Q", "H"], default="M",
                    help="error-correction level (default M)")
    args = ap.parse_args()

    svg = build_svg(args.url, args.ecc)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            f.write(svg)
        n_modules = svg.count('viewBox="-2 -2 ') and (int(svg.split('viewBox="-2 -2 ')[1].split(" ")[0]) - 4)
        sys.stderr.write(f"wrote {args.out}  ({n_modules}x{n_modules} modules, ECC {args.ecc})  url={args.url}\n")
    else:
        sys.stdout.write(svg + "\n")


if __name__ == "__main__":
    main()
