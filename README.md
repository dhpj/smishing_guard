# Smishing Guard

**앱 버전:** `0.4.10+28` (개발 브랜치 `v0.1.2`) · **이력:** [CHANGELOG.md](CHANGELOG.md) · **브랜치/버전 규칙:** [VERSIONING.md](VERSIONING.md)

**0.4.10 주요 변경 (2026-05-28):**
- 설정 UX 대폭 개선: 권한 바로가기 단순화, 권한 안내는 하단 시트로 분리, 권한 팝업 1초 자동 상태 확인/자동 닫기.
- 오버레이 간단 모드 추가·고도화: 메시지 미리보기/진단/시각 축소 + URL/버튼/여백 압축(광고 노출 유지).
- 신뢰 도메인 정규화 엔진 도입: URL/쿼리 포함 입력도 저장 시 쿼리 제거 후 안정 매칭, 저장 완료 스낵바 제공.
- 설정 정책 정리: 오버레이/알림 선택 UI 임시 비활성화, 오버레이 우선 고정(광고 수익화 방향).

**0.4.9 주요 변경 (2026-05-27, Critical Fix):**
- 페이지 본문 링크가 자동 검사되던 false positive 제거. 0.4.7 에서 추가한 `flagRequestEnhancedWebAccessibility` 가 Firefox/Gecko 의 웹 페이지 본문 링크를 a11y 트리에 노출 → 3차/4차 fallback 이 그 안의 URL 텍스트를 URL bar 로 잘못 인식하던 critical bug.
- a11y config 에서 `flagRequestEnhancedWebAccessibility` · `flagIncludeNotImportantViews` 제거. 3차 TextView fallback / 4차 위치 기반 fallback / 진단 덤프 코드 제거.
- 보수적 1·2차 휴리스틱(ID 매칭 + `parseFromText`, EditText fallback) 만 유지. Firefox `ADDRESSBAR_URL_BOX` 같은 표준 ID 노드는 그대로 인식. UC Browser 같은 Compose UI 의 비표준 빌드는 일부 미인식 가능 — 신뢰도 우선.

**0.4.8 주요 변경 (2026-05-27):**
- Firefox(Fenix) URL bar 실측 데이터 기반 픽스. `ADDRESSBAR_URL_BOX` 의 `contentDescription` 이 `"google.com. 검색어 또는 주소 입력"` 형태로 URL + placeholder 혼합인 케이스 대응.
- ID 매칭 성공 + `looksLikeBarText` 실패 시 `UrlNormalizer.parseFromText` 로 텍스트 내부 URL 만 추출. 4차 위치 fallback 에도 같은 처리 적용.

**0.4.7 주요 변경 (2026-05-27):**
- Firefox 인식 강화. accessibility service flag 에 `flagIncludeNotImportantViews` · `flagRequestEnhancedWebAccessibility` 추가 (important=false 노드 / Gecko web content 노출).
- 4차 위치 기반 fallback `findUrlBarByToolbarZone` 추가 — 화면 상단(~280dp) / 하단(~180dp) toolbar 영역 + strict URL prefix.
- Mozilla 패키지 첫 진입 시 a11y 트리 30개 노드를 logcat 에 1회 덤프 (`SmishingBrowserA11y` 태그) — 안 잡히는 경우 정확한 ID 추적용.

**0.4.6 주요 변경 (2026-05-27):**
- Firefox / UC Browser 인식 보강. URL bar 가 `TextView` 로 렌더링되는 케이스(`mozac_browser_toolbar_url_view`) · UC Browser 의 빌드별 변형 ID 대응.
- 3차 fallback `findUrlBarByTextViewFallback` 추가 — 텍스트가 `http(s)://` / `www.` 로 시작하는 경우만 인정.
- `isUrlBarId` 에 UC Browser 변형(`address_input`, `search_text`, `titlebar_search`) + Firefox Mozac 일반화(`mozac+url`) 패턴 추가.

**0.4.5 주요 변경 (2026-05-27):**
- `BrowserPackages.refresh()` — `PackageManager` 로 디바이스 설치 브라우저 동적 발견 (신규 브라우저도 코드 수정 없이 인식).
- `baseSet` 에 Opera GX/beta, Samsung Internet lite, Whale beta, Edge beta/dev/canary, Firefox Focus, Brave nightly 등 30여 개 변형 패키지 보강.
- `isUrlBarId` 매칭 패턴 확장: Opera `url_field`, Firefox `mozac_browser_toolbar_url_view`, Yandex `omnibar`, suffix `:id/url` 등.
- ID 매칭 실패 시 `EditText` + URL 형태 텍스트 fallback 으로 URL bar 인식 (난독화된 브라우저 빌드 대비).

**0.4.4 주요 변경 (2026-05-27):**
- Android Auto Backup · Device-to-Device Transfer 전면 비활성화 (`allowBackup=false` + `dataExtractionRules` 전체 exclude).
- 앱 삭제·재설치 후 클라우드 백업본에서 타임라인이 복원되던 회귀 수정. PIPA · Play Data Safety 관점에서도 정합.

**0.4.3 주요 변경 (2026-05-27):**
- `testsafebrowsing.appspot.com` 강제 위험 처리 · 설정 화면 '스미싱 테스트 링크 검사' 버튼 · 네이티브 `runTestSmishingCheck` 핸들러 등 QA 우회 경로 전면 제거.
- 운영 빌드는 mock 모드가 아닌 한 어떤 URL 이든 백엔드 `/check_uri` 응답을 그대로 신뢰.

**0.4.2 주요 변경 (2026-05-27):**
- 타임라인 화면 하단에 **비우기** 액션 추가 (`FilledButton.tonal` · 두 단계 확인 다이얼로그). PIPA 의 사용자 삭제권에 대응.
- 설정 화면의 `오탐·면책 안내` 중복 항목 제거 — 정책 진입점을 메인 화면 푸터로 단일화.

**0.4.1 주요 변경 (2026-05-27):**
- 메인 화면 `오늘 검사` 카운트가 `차단` 과 동일하게 증가하던 회귀 수정 (안전 결과도 정상 카운팅).
- 서버 `/check_uri` 전송 시 쿼리스트링·프래그먼트 제거 (수집 데이터 최소화). 표시·이력은 원본 URL 유지.

**0.4.0 주요 변경 (2026-05-26):** Play Store 등록용 mockup 디자인을 실제 앱에 반영.
- 메인 화면: Hero status card (파란 그라데이션 + GSL 아이콘 + 실시간 감지중 칩), 통계 카드(오늘 검사·차단), 권한 카드, 토글 카드 등 재구성.
- 오버레이 알림: 빨간 그라데이션 헤더 + 출처 옐로우 칩 + 의심 URL 박스 + 한 줄 진단 + 광고 + `앱 열기`/`무시` 버튼 페어로 전면 리뉴얼.
- 통계 인프라(`scan_stats.dart`) 신설 — client-side 카운터, 서버 전송 없음.

| Tool | Version |
|------|---------|
| Flutter | 3.19.6 |
| Dart | 3.3.4 |
| Gradle | 8.4 |
| Android Gradle Plugin | 8.2.2 |
| JDK | 21 (Android Studio JBR) |

## Run

```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
flutter pub get
flutter run
```

## Dependencies (pinned for Flutter 3.19.6)

- `http` 1.2.2 — phishing API
- `shared_preferences` 2.2.3 — settings · 네이티브 호환 prefs
- `flutter_secure_storage` 9.2.2 — userid 암호화 보관 (Android Keystore)
- `permission_handler` 11.3.1 — 런타임 권한
- `url_launcher` 6.3.1 — 광고 배너 외부 링크
- `flutter_lints` 3.0.2 — dev

## Java / Gradle

Your Android Studio ships **Java 21**, so this project uses **Gradle 8.4 + AGP 8.2.2** (not Flutter 3.19 defaults of 7.6.3 / 7.3.0).

If Gradle fails, set JDK explicitly:

```bash
flutter config --jdk-dir="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
```

## 서버 API (기본 `http://210.114.225.58:8087`)

| 기능 | 메서드·경로 | 헤더/바디 | 비고 |
|------|-------------|------|------|
| userid 발행 | `POST /set_userid` | `android_id` | 최초 1회, 로컬 저장 |
| URI 검사 | `POST /check_uri` | `userid` + JSON `{"uri":"..."}` | `0000` 안전 · `0001` 스미싱 주의 |
| 광고 배너 | `POST /get_ad_img` | `userid` + JSON `{"type":1}` | JSON 배열 `[{ "img_url", "img_link" }, ...]` — 5초 간격 슬라이드, 탭 시 `img_link` 이동 |

**기동 흐름:** 로딩 → `set_userid` 실패 시 「현재 서비스 이용이 불가능 합니다.」 후 종료 → 메인.

**타임라인:** 스미싱 주의(`0001`)만 로컬 저장, **최대 30일 · 200건**.

설정에서 **Mock 모드**를 켜면 서버 없이 테스트 가능 (`phish`, `evil`, `fake`, `scam` 등 URL은 주의 처리).

**통합 테스트 시:** Mock **OFF** · 메인 **보호 켜기** · 서버 등록 URL과 앱이 보내는 URL 일치 확인.

## 변경 이력 요약

| 버전 | 요약 |
|------|------|
| **0.1.9** | 탭 닫기 후 같은 URL 알림 회귀 fix — internal URL(`brave://newtab/`)도 visit key로 인정 |
| **0.2.0** | 앱 이름 '경남 안심링크' 확정 / FGS 상태바 아이콘 = 방패+G / 오버레이에 광고 영역 + `/get_ad_img` 1회 호출 |
| **0.2.1** | 런처 아이콘(Adaptive Icon) 방패+골드 G 신규 / FGS 상태바 G 글자 시각 중심 보정 |
| **0.2.2** | 런처 아이콘 = 방패 + **GSL**(Gyeongnam Safety Link) / cyan→indigo 그라데이션, 흰 방패 그라데이션, 인디고 stroke 글자 |
| **0.2.3** | 브랜드 컬러 = **blue-700(#1D4ED8)** 확정 / 앱 전체 화면 청색 톤 통일 / 런처 아이콘 premium 업데이트 — 외곽 골드 ring + 상단 다이아몬드 + 내부 청색 패널 + GSL 두께 ↑ |
| **0.2.4** | 런처 아이콘 비율 보정 — 외곽 방패 3dp 축소, GSL 8×11 box 로 크기 통일, inner panel 안에 정착 |
| **0.2.5** | 외곽 방패 하단 3dp 위로(여백) · inner panel 비례 축소 · GSL 7×9.5 + stroke 2.6 로 슬림 |
| **0.2.6** | 내부 청색 방패 heraldic per-pale 입체감 — 좌 highlight / 우 shadow + 가운데 vertical seam(글자 영역 비움) |
| **0.3.0** | 오버레이 발신처 배지 = K/T/L/문/W 글자 → **Material-style 추상 아이콘** (카카오·텔레그램·LINE·문자) + "웹" 한글 / trademark 회피 |
| **0.1.8** | 브라우저 외부 체류 1.5초+ 시 visit 만료 — 브라우저 종료·재실행 후에도 같은 페이지 알림 동작 |
| **0.1.7** | 브라우저 알림 정책: 「현재 보고 있는 페이지에서만 1회」 (탭 닫고 같은 URL 재방문 시 다시 알림) |
| **0.1.6** | 브라우저 탭 닫기·시스템 UI 활성화로 알림이 재발사되던 결함 차단 (process-level) |
| **0.1.5** | 브라우저 검사 정책: 한 세션 동안 같은 URL은 단 1회 검사·알림 |
| **0.1.4** | 브라우저: 메뉴/허공 터치만으로 알림이 반복되던 결정적 버그 fix |
| **0.1.3** | 오탐·면책 안내, 탐지 진동(설정 토글), 랜덤 탐지 멘트 100문장, userid 암호화 보관 |
| **0.1.2** | 탐지 복구, 브라우저/알림 안정화, API code 파싱, 배터리·캐시, 문서화 |
| **0.1.1** | 타임라인·상세·광고·권한 UI, 패키지명 변경, 오버레이 메시지 스타일 |
| **0.1.0** | 초기 Android 프로토타입 — SMS/알림/브라우저/API/FGS/Mock |

자세한 버그·수정 목록은 [CHANGELOG.md](CHANGELOG.md) 참고.

## Git

| 브랜치 | 용도 |
|--------|------|
| `v0.1.2` | 일상 개발 · push |
| `main` | 통합 테스트 완료 후 머지 |

원격: `https://github.com/dhpj/smishing_guard`

## 최신 기기에 APK 설치 (S9+ 말고 Pixel·갤럭시 최신 등)

이 앱은 **문자·알림 읽기 + 다른 앱 위 표시 + 접근성** 조합이라, 서명 없는 APK를 파일로 설치하면 **Play Protect가 “유해/악성”** 으로 막는 경우가 많다. (실제 스미싱 도구와 권한 패턴이 비슷해서 **오탐**에 가깝다.)

### 1) USB로 바로 설치 (가장 쉬움)

개발자 옵션·USB 디버깅 켠 뒤:

```bash
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
# 또는
flutter install
```

PC에서 `adb install` / `flutter install` 은 파일 관리자 설치보다 통과되는 경우가 많다.

### 2) Play Protect 잠시 끄기

**Google Play 스토어** → 프로필 → **Play Protect** → 톱니 →  
**앱을 Play Protect로 검사** 끔 → APK 설치 → 다시 켜도 됨.

설치 화면에서 **“앱이 차단됨”** → **자세히** → **무시하고 설치** / **Install anyway** 가 있으면 그걸 선택.

삼성: **설정 → 보안 및 개인정보 보호 → 앱 보호** 에서 별도 스캔이 켜져 있으면 설치 중에 한 번 더 막을 수 있음.

### 3) Android 13+ 필수: “제한된 설정” 허용

설치만 되고 **접근성·알림 접근** 메뉴가 비활성일 수 있다.

**설정 → 앱 → Smishing Guard** → 우측 상단 **⋮** → **제한된 설정 허용** (Allow restricted settings) 켠 다음, 앱 안에서 접근성·알림 접근·오버레이를 연다.

### 4) 내부 테스트용 release APK

```bash
flutter build apk --release
```

`--release` + (가능하면) **자체 서명 키**로 서명하면 Play Protect 오탐이 줄어드는 경우가 있다. `build.gradle` 의 `signingConfig signingConfigs.debug` 는 스토어/배포용이 아니다.

### 5) 그래도 안 되면

- **에뮬레이터** (API 34 이미지)에서 동일 APK로 기능 검증  
- 팀 배포: **Google Play 내부 테스트** 트랙 (서명 APK, Play가 “알려진 개발 빌드”로 취급)

기능 검증만이면 **S9+ + `flutter install`** 과 **최신폰 USB `adb install`** 조합이면 충분한 경우가 많다.
