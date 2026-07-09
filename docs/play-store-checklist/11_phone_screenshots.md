# Play Store 스크린샷 — 실제 기기 캡처

연결된 Android 기기/에뮬레이터에서 앱 화면을 캡처합니다.

```bash
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
OUT="docs/play-store-checklist/deliverables"

# 1) 앱 설치 후 실행
flutter install

# 2) 메인 화면
$ADB shell screencap -p /sdcard/ss_main.png
$ADB pull /sdcard/ss_main.png "$OUT/4.screenshot_01_main_1080x1920.png"

# 3) 타임라인 탭 후
$ADB shell input tap 540 1800   # 하단 네비 위치는 기기별 조정
$ADB shell screencap -p /sdcard/ss_timeline.png
$ADB pull /sdcard/ss_timeline.png "$OUT/6.screenshot_03_timeline_1080x1920.png"

# 4) 설정 화면
$ADB shell input tap 1000 180
$ADB shell screencap -p /sdcard/ss_settings.png
$ADB pull /sdcard/ss_settings.png "$OUT/6.screenshot_03_settings_1080x1920.png"
```

Play Console 권장: **1080×1920** (9:16) PNG, 최소 3장.

현재 `deliverables/4~6` PNG는 앱 UI 기반 목업입니다. 기기 캡처본으로 교체하면 심사에 더 유리합니다.
