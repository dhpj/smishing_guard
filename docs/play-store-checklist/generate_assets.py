#!/usr/bin/env python3
"""
Google Play Store 등록용 그래픽 자산을 SVG → PNG 로 렌더링합니다.

사전 준비:
    python3 -m venv /tmp/smishing_assets_venv
    source /tmp/smishing_assets_venv/bin/activate
    pip install resvg-py

실행:
    cd docs/play-store-checklist
    python3 generate_assets.py

산출물:
    assets/app_icon_1024.png           — 1024x1024  (Play Console hi-res)
    assets/app_icon_512.png            —  512x512   (참고용 미리보기)
    assets/feature_graphic_1024x500.png — 1024x500  (Feature Graphic, 필수)
    assets/screenshot_01_main_1080x1920.png        — 9:16, 메인 화면 mockup
    assets/screenshot_02_overlay_1080x1920.png     — 9:16, 위험 오버레이 mockup
"""
from __future__ import annotations

import os
import sys

try:
    import resvg_py
except ImportError:
    sys.stderr.write(
        "resvg_py 모듈을 찾을 수 없습니다.\n"
        "  source /tmp/smishing_assets_venv/bin/activate\n"
        "  pip install resvg-py\n"
    )
    sys.exit(1)


HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "assets", "source")
OUT = os.path.join(HERE, "assets")
os.makedirs(OUT, exist_ok=True)


def render(svg_filename: str, png_filename: str, width: int, height: int) -> None:
    svg_path = os.path.join(SRC, svg_filename)
    png_path = os.path.join(OUT, png_filename)
    with open(svg_path, "r", encoding="utf-8") as f:
        svg = f.read()

    data = resvg_py.svg_to_bytes(
        svg_string=svg,
        width=width,
        height=height,
    )

    with open(png_path, "wb") as f:
        f.write(bytes(data))

    size_kb = os.path.getsize(png_path) / 1024
    print(f"  -> {png_filename}  ({width}x{height}, {size_kb:.0f} KB)")


def main() -> None:
    jobs = [
        ("app_icon.svg",            "app_icon_1024.png",                1024, 1024),
        ("app_icon.svg",            "app_icon_512.png",                  512,  512),
        ("feature_graphic.svg",     "feature_graphic_1024x500.png",     1024,  500),
        ("screenshot_01_main.svg",  "screenshot_01_main_1080x1920.png", 1080, 1920),
        ("screenshot_02_overlay.svg","screenshot_02_overlay_1080x1920.png",1080,1920),
    ]
    for i, (svg, png, w, h) in enumerate(jobs, 1):
        print(f"[{i}/{len(jobs)}] {png}")
        render(svg, png, w, h)
    print("\nDone. Output dir:", OUT)


if __name__ == "__main__":
    main()
