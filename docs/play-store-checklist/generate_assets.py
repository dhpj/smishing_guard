#!/usr/bin/env python3
"""Play Store 그래픽·스크린샷 PNG 생성 + deliverables 복사."""
from __future__ import annotations

import os
import shutil
import sys

try:
    import resvg_py
except ImportError:
    sys.stderr.write(
        "resvg_py 모듈을 찾을 수 없습니다.\n"
        "  python3 -m venv /tmp/smishing_assets_venv\n"
        "  source /tmp/smishing_assets_venv/bin/activate\n"
        "  pip install resvg-py\n"
    )
    sys.exit(1)

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "assets", "source")
ASSETS = os.path.join(HERE, "assets")
DELIVERABLES = os.path.join(HERE, "deliverables")
os.makedirs(ASSETS, exist_ok=True)
os.makedirs(DELIVERABLES, exist_ok=True)


def render(svg_filename: str, png_filename: str, width: int, height: int, out_dir: str) -> str:
    svg_path = os.path.join(SRC, svg_filename)
    png_path = os.path.join(out_dir, png_filename)
    with open(svg_path, "r", encoding="utf-8") as f:
        svg = f.read()
    data = resvg_py.svg_to_bytes(svg_string=svg, width=width, height=height)
    with open(png_path, "wb") as f:
        f.write(bytes(data))
    size_kb = os.path.getsize(png_path) / 1024
    print(f"  -> {png_path} ({width}x{height}, {size_kb:.0f} KB)")
    return png_path


def main() -> None:
    jobs = [
        ("app_icon.svg", "app_icon_1024.png", 1024, 1024),
        ("app_icon.svg", "app_icon_512.png", 512, 512),
        ("feature_graphic.svg", "feature_graphic_1024x500.png", 1024, 500),
        ("screenshot_01_main.svg", "screenshot_01_main_1080x1920.png", 1080, 1920),
        ("screenshot_02_overlay.svg", "screenshot_02_overlay_1080x1920.png", 1080, 1920),
        ("screenshot_03_timeline.svg", "screenshot_03_timeline_1080x1920.png", 1080, 1920),
    ]
    for i, (svg, png, w, h) in enumerate(jobs, 1):
        print(f"[{i}/{len(jobs)}] {png}")
        render(svg, png, w, h, ASSETS)

    deliverable_map = {
        "screenshot_01_main_1080x1920.png": "4.screenshot_01_main_1080x1920.png",
        "screenshot_02_overlay_1080x1920.png": "5.screenshot_02_overlay_warning_1080x1920.png",
        "screenshot_03_timeline_1080x1920.png": "6.screenshot_03_timeline_1080x1920.png",
    }
    print("\nCopy to deliverables:")
    for src_name, dst_name in deliverable_map.items():
        src = os.path.join(ASSETS, src_name)
        dst = os.path.join(DELIVERABLES, dst_name)
        shutil.copy2(src, dst)
        print(f"  -> {dst}")

    print("\nDone.")


if __name__ == "__main__":
    main()
