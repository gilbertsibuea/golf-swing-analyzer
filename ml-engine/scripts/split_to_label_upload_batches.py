#!/usr/bin/env python3
"""Copy to_label JPGs into small folders for Label Studio upload limits."""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--src", default="datasets/clubhead/to_label")
    parser.add_argument("--out", default="datasets/clubhead/upload_batches")
    parser.add_argument("--size", type=int, default=50, help="Max files per batch")
    args = parser.parse_args()

    src = Path(args.src)
    out = Path(args.out)
    if not src.is_absolute():
        src = ROOT / src
    if not out.is_absolute():
        out = ROOT / out

    jpgs = sorted(src.glob("*.jpg"))
    if not jpgs:
        print(f"No JPGs in {src}", file=sys.stderr)
        sys.exit(1)

    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)

    n = 0
    batch = 1
    for i, img in enumerate(jpgs):
        if i % args.size == 0 and i > 0:
            batch += 1
        dest = out / f"batch_{batch:02d}"
        dest.mkdir(exist_ok=True)
        shutil.copy2(img, dest / img.name)
        n += 1

    print(f"Copied {n} JPGs into {batch} folders under {out}")
    print("Upload one batch folder at a time in Label Studio Import.")


if __name__ == "__main__":
    main()
