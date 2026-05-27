# Google Play Store 등록용 그래픽 자산

`docs/play-store-checklist/assets/` 폴더에 등록 시 필요한 PNG 파일들이 들어있습니다.
모든 PNG 는 `assets/source/*.svg` 에서 `generate_assets.py` 로 자동 렌더된 결과입니다.

## 자산 매핑

| Google Play Console 항목 | 권장 사양 | 파일 | 크기 |
|---|---|---|---|
| 앱 아이콘 (Hi-res icon) | 512x512 PNG, ≤ 1MB, alpha 허용 | `app_icon_512.png` | 47 KB |
| 앱 아이콘 (대형 미리보기) | 1024x1024 PNG (참고용) | `app_icon_1024.png` | 107 KB |
| 그래픽 이미지 (Feature graphic) | 1024x500 PNG/JPEG | `feature_graphic_1024x500.png` | 80 KB |
| 휴대전화 스크린샷 #1 | 9:16, 최소 1080x1920 권장 | `screenshot_01_main_1080x1920.png` | 216 KB |
| 휴대전화 스크린샷 #2 | 9:16, 최소 1080x1920 권장 | `screenshot_02_overlay_1080x1920.png` | 280 KB |

> Play Console 은 휴대전화 스크린샷 **최소 2장 이상** 을 요구합니다 (최대 8장).
> 위 두 장은 mockup 입니다 — 정식 출시 직전에 가능하면 **실제 디바이스 캡처본** 으로 교체하길 권장합니다 (Play 정책상 mockup 도 허용되지만 실제 화면이 더 좋습니다).

## 파일 재생성 방법

런처 아이콘 디자인이 바뀌었거나 텍스트/스크린샷 mockup 을 수정하고 싶으면:

```bash
# 1. 가상환경 활성화 (최초 1회만 venv 생성)
python3 -m venv /tmp/smishing_assets_venv
source /tmp/smishing_assets_venv/bin/activate
pip install resvg-py

# 2. SVG 수정
#    assets/source/app_icon.svg            — 런처/스토어 아이콘
#    assets/source/feature_graphic.svg     — 1024x500 배너
#    assets/source/screenshot_01_main.svg  — 메인 UI mockup
#    assets/source/screenshot_02_overlay.svg — 위험 알림 mockup

# 3. PNG 재생성
cd docs/play-store-checklist
python3 generate_assets.py
```

## 디자인 참고

- 메인 색상: `#1D4ED8` (blue-700) — 앱 전체 테마 시드 색상과 동일
- 보조 색상: `#F59E0B` (amber-500) — 골드 ring · 출처 배지
- 위험 색상: `#DC2626` (red-600) — 스미싱 알림 헤더
- 폰트 (한글): Apple SD Gothic Neo / Pretendard / Noto Sans CJK KR (시스템 폰트 자동 인식)

## 실제 디바이스 스크린샷 교체 가이드

정식 출시 전, 가능한 한 mockup 을 실제 캡처로 교체하세요.

1. 안드로이드 단말에서 `경남 안심링크` 실행
2. 메인 화면 — `전원 + 볼륨↓` 으로 스크린샷 → 갤러리에서 PC 로 전송 → `screenshot_01_main_1080x1920.png` 자리에 동일한 이름으로 저장
3. 모의 스미싱 URL 로 알림 카드 띄운 상태에서 스크린샷 → `screenshot_02_overlay_1080x1920.png` 위치에 저장
4. 추가로 권한 안내 화면 / 검사 이력 화면 등도 캡처하면 좋습니다 (`screenshot_03_*.png` 형식으로 추가)

> Play Console 은 9:16 비율이면 1080x1920 외에도 720x1280, 1440x2560 등 OK 입니다. 짧은 쪽 ≥ 320px, 긴 쪽 ≤ 3840px.
