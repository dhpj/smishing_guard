# Changelog

형식: [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/) · 버전: [Semantic Versioning](https://semver.org/lang/ko/) (`MAJOR.MINOR.PATCH`)

| 구분 | 버전 올리는 기준 | 예 |
|------|------------------|-----|
| **PATCH** | 버그 수정, 동작 회귀 복구 | `0.1.2 → 0.1.3` |
| **MINOR** | 기능 추가 (하위 호환) | `0.1.x → 0.2.0` |
| **MAJOR** | 호환 깨짐·대규모 구조 변경 | `0.x → 1.0.0` |

**Git 브랜치:** 통합 테스트는 `v0.1.2` · 안정 반영 후 `main` 머지 ([VERSIONING.md](VERSIONING.md))

---

## [0.4.22] — 2026-07-31 (Play SMS 정책 — 알림 경로 전환)

**앱 버전:** `0.4.22+40` · **브랜치:** `v0.1.2`

### Changed
- **RECEIVE_SMS / READ_SMS 제거** — Play SMS 예외·증빙 없이 심사 통과 목적
- 문자 URL 검사: **알림 접근**으로 삼성/구글 문자 앱 알림 처리 (`MessageNotificationListener`)
- `SmsReceiver` · `SmsInboxObserver` 삭제 · setup wizard SMS 필수 항목 제거
- 명시적 고지: SMS는 알림 경로·SMS 권한 미사용 명시 (`disclosure v3`)

---

## [0.4.21] — 2026-07-24 (Play 접근성·명시적 공개 대응)

**앱 버전:** `0.4.21+39` · **브랜치:** `v0.1.2`

### Changed
- **명시적 고지 다이얼로그 확장** — AccessibilityService API, SMS/MMS, 기타 인앱 메시지(알림 접근) 수집·목적·서버 전송 범위 명시
- 「보호 켜기」 직전 고지 표시 (`runSetupWizard`)
- Play **자세한 설명**에 AccessibilityService API 사용 섹션 추가 (`07_store_listing_copy.txt`)
- 접근성 동영상 촬영 가이드 갱신 (`12_accessibility_video_script.md`)

---

## [0.4.20] — 2026-07-14 (Play 데이터 보안 — HTTPS API 전환)

**앱 버전:** `0.4.20+38` · **브랜치:** `v0.1.2`

### Changed
- API 기본 주소 `https://smishing.dhn.kr` (443) — cleartext `http://210.127.253.95:3098` 제거
- Flutter·네이티브(`UriCheckBridge`, `OverlayAdLoader`) 폴백 URL 동일 적용
- 앱 기동 시 `api_base_url` prefs를 HTTPS 기본값으로 강제 동기화
- `android:usesCleartextTraffic="false"` — 앱 프로세스 cleartext HTTP 차단

---

## [0.4.19] — 2026-07-10 (Play 심사 대응 — API 35·접근성 고지)

**앱 버전:** `0.4.19+37` · **브랜치:** `v0.1.2`

### Changed
- **targetSdk / compileSdk 35** — Play API 수준 요건
- **16KB 메모리 페이지** 대응 — AGP 8.5.2, Gradle 8.7, NDK r27
- **접근성 API 명시적 고지** — 앱 내 동의 다이얼로그 (`AccessibilityDisclosure`)
- `accessibility_service_config.xml` — `isAccessibilityTool="false"` 선언

### Added
- Play Console 접근성 **동영상 촬영 가이드** (`12_accessibility_video_script.md`)

---

## [0.4.18] — 2026-07-09 (Play minSdk 21 · 스토어 스크린샷)

**앱 버전:** `0.4.18+36` · **브랜치:** `v0.1.2`

### Changed
- **minSdkVersion 21** 고정 (Play 보안 검사 요건 — 기존 19)
- Play Store 제출용 **폰 스크린샷 3장** deliverables 추가 (메인·경고 오버레이·타임라인)

---

## [0.4.17] — 2026-07-09 (Play Console 출시 서명)

**앱 버전:** `0.4.17+35` · **브랜치:** `v0.1.2`

### Changed
- **release AAB 출시 서명** 적용 — debug 서명 제거
  - `android/app/upload-keystore.jks` 업로드 키 발급
  - `android/key.properties` + `signingConfigs.release` 연결

---

## [0.4.16] — 2026-07-08 (최초 실행 권한 안내 UX)

**앱 버전:** `0.4.16+34` · **브랜치:** `v0.1.2`

### Changed
- **최초 실행 시 권한 설정 팝업 자동 표시 제거**
  - 앱 실행 → 메인 화면을 먼저 보여 준 뒤, 사용자가 **「보호 켜기」** 를 눌렀을 때만 설정 마법사 표시
  - 권한 미완료 상태에서 보호 켜기를 취소·중단하면 보호는 켜지지 않음

---

## [0.4.15] — 2026-06-12 (개인정보처리방침 공식 URL 고정)

**앱 버전:** `0.4.15+33` · **브랜치:** `v0.1.2`

### Changed
- 개인정보처리방침 공식 URL 고정: `http://dhncorp.co.kr/sub/service/privacy.php`
  - `AppUserSettings.defaultPrivacyPolicyUrl` · 설정 화면 탭 시 브라우저로 열기
  - 수동 URL 입력 UI 제거

---

## [0.4.14] — 2026-06-12 (개인정보 보호 책임자 지정)

**앱 버전:** `0.4.14+32` · **브랜치:** `v0.1.2`

### Changed
- 개인정보 보호 책임자: 송도휘 (`legal_document_sections.dart`, `docs/privacy.html`)

---

## [0.4.13] — 2026-06-12 (약관 운영 주체 정보 반영)

**앱 버전:** `0.4.13+31` · **브랜치:** `v0.1.2`

### Changed
- 이용약관·개인정보처리방침에 (주)대형네트웍스 운영 정보 반영:
  - 주소: 경상남도 창원시 의창구 평산로 33 신화더플렉스시티 715, 716, 717호
  - 연락처: 055-713-7985 · 이메일: dhn@dhncorp.co.kr
  - 서버·인프라: (주)대형네트웍스 자체 운영(외부 위탁 없음)
- 개인정보 보호 책임자: 성명 미정 — 「개인정보 보호 담당 부서」로 표기

---

## [0.4.12] — 2026-06-12 (이용약관 · 개인정보처리방침)

**앱 버전:** `0.4.12+30` · **브랜치:** `v0.1.2`

### Added
- 이용약관·개인정보처리방침 초안:
  - 앱 내 화면: `TermsOfServicePage`, `PrivacyPolicyPage`
  - Play Store·GitHub Pages용: `docs/terms.html`, `docs/privacy.html`
  - 스미싱 차단 모바의 권한 안내·PIPA 조항 구조를 참고, 경남 안심링크 실제 수집 항목(URL·userid·로컬 타임라인)에 맞게 작성.
- 설정 **정보·지원**에 이용약관·개인정보처리방침 메뉴 추가.

### Changed
- 개인정보처리방침 공개 URL 입력은 Play Store용 접이식 항목으로 이동.

---

## [0.4.11] — 2026-06-12 (API 서버 이전 · 고급 설정 정리)

**앱 버전:** `0.4.11+29` · **브랜치:** `v0.1.2`

### Changed
- API 서버 기본 주소 변경:
  - `http://210.114.225.58:8087` → `http://210.127.253.95:3098`
  - Flutter `SmishingApiClient.defaultBaseUrl`, Android `UriCheckBridge`·`OverlayAdLoader` 폴백 동기화.
  - 앱 기동 시 `api_base_url`·`mock_mode` prefs를 새 기본값으로 강제 동기화(구 주소 잔존 방지).
- 설정 화면 **고급 설정** 제거:
  - API 서버 주소 입력, Mock 모드, userid 표시, 개발자용 오버레이 테스트 버튼 삭제.
  - 개인정보처리방침 URL 편집은 **정보·지원** 섹션으로 이동.

### Removed
- 설정에서 사용자가 API 주소·Mock 모드를 바꾸는 UI 및 `UserSession` Mock 부트스트랩 분기.

---

## [0.4.10] — 2026-05-28 (설정 UX 정리 · 권한 플로우 자동화 · 오버레이 간단 모드 · 신뢰 도메인 정규화)

**앱 버전:** `0.4.10+28` · **브랜치:** `v0.1.2`

### Added
- 설정 화면 편의 기능 확장:
  - 야간·무음 시간 선택 UI를 branded bottom-sheet 시간 선택기로 교체.
  - 보호 일시 중지(1시간 / 오늘 하루), 탐지 소리 토글, 데이터 관리 액션(통계 초기화·캐시 비우기) 추가.
  - 오버레이 간단 모드(`overlay_compact_mode`) 추가.
- 신뢰 도메인 정규화/매칭 엔진 추가:
  - Flutter: `lib/core/trusted_domain_matcher.dart`
  - Android: `android/.../TrustedDomains.kt`
  - URL·쿼리 포함 입력도 저장 시 정규화(`host` 또는 `host/path`) 후 매칭.
- 테스트 추가: `test/trusted_domain_matcher_test.dart`.

### Changed
- 권한 UX 개편:
  - 메인/설정 권한 영역은 한 줄 요약 중심으로 간소화.
  - 보호 시작 권한 팝업은 항목별 상세 설명을 제거하고 `설정 열기` 중심으로 정리.
  - 권한 상세는 하단 `권한이 왜 필요한지 보기`에서만 확인하도록 분리.
  - 권한 팝업은 1초 주기 자동 상태 확인으로, 모든 필수 권한 완료 시 자동 닫힘.
- 오버레이 간단 모드 동작 강화(광고 유지):
  - 메시지 미리보기·한 줄 진단·탐지 시각·보조 라벨을 숨겨 카드 높이 압축.
  - URL/버튼/여백 크기 축소로 세로 길이 추가 압축.
- 신뢰 도메인 저장 UX 개선:
  - 저장 시 정규화된 값으로 입력창 재표시.
  - 저장 완료 스낵바 제공.
- 설정 정책 정리:
  - 오버레이/알림 선택 UI 임시 비활성화, 오버레이 우선 모드 고정(광고 노출 정책).
  - 설정 화면 권한 항목 순서를 메인 화면 순서와 통일.

### Fixed
- 신뢰 도메인 매칭 실패 케이스 수정:
  - `https://domain/path?x=1` 형태 등록 시 쿼리 제거 후 매칭되도록 수정.
  - 네이티브/Flutter 양쪽에서 동일 규칙으로 위험 알림·타임라인 스킵 일치.
- `showBrandedTimePicker` 호출 시 named argument 시그니처 불일치로 릴리스 빌드 실패하던 문제 수정.

---

## [0.4.9] — 2026-05-27 (Critical Fix — 페이지 본문 링크가 검사되던 false positive 제거)

**앱 버전:** `0.4.9+27` · **브랜치:** `v0.1.2`

> 사용자 보고: "구글 검색했더니 결과 안에 나무위키가 떴는데, 클릭하지 않았는데도 API 이력에 나무위키가 들어와 있다." → 0.4.7/0.4.8 에서 추가한 공격적 fallback 들이 페이지 본문의 링크 노드를 URL bar 로 잘못 인식하던 critical bug. 신뢰도가 신호의 양보다 훨씬 중요해서 0.4.7 이전의 보수적 동작으로 롤백.

### Root Cause — `flagRequestEnhancedWebAccessibility` + 공격적 fallback 의 결합
- 0.4.7 에서 Firefox 대응으로 추가한 `flagRequestEnhancedWebAccessibility` 와 `flagIncludeNotImportantViews` 가 **웹 페이지 본문의 모든 링크/텍스트를 a11y 트리에 노출**시킴.
- 동시에 추가한 3차 TextView fallback / 4차 위치 fallback 이 본문 노드 안에서 URL 형태 텍스트(`https://namu.wiki/...`)를 발견하면 그것을 URL bar 로 인식해 검사 발사.
- 결과: 사용자가 **클릭하지 않은 검색 결과 내 링크**가 자동으로 검사되고 (`/check_uri` 호출 이력에 남음), 위험 판정 시 잘못된 경고 오버레이까지 띄울 수 있는 상태.

### Fix — 0.4.7 이전의 보수적 휴리스틱만 유지
- `android/.../res/xml/accessibility_service_config.xml`
  - `flagIncludeNotImportantViews` 제거.
  - `flagRequestEnhancedWebAccessibility` 제거 — 페이지 본문 a11y 노출 차단.
- `android/.../BrowserAccessibilityService.kt`
  - **`findUrlBarByTextViewFallback` 제거** (3차) — 페이지 본문의 링크 TextView 가 잡힘.
  - **`findUrlBarByToolbarZone` / `findInToolbarZone` 제거** (4차) — 좁은 toolbar zone 도 페이지 본문이 침범 가능.
  - `looksLikeStrictUrlText` 제거 — 위 두 함수에서만 사용.
  - `dumpNodeTreeOnce` / `diagnosticDumpedPackages` 제거 — 진단용 일회성 코드.
  - 유지: 1차 ID 매칭(`isUrlBarId`) + `parseFromText` 임베드 URL 추출 → Firefox 의 `ADDRESSBAR_URL_BOX` 같은 표준 ID 노드는 그대로 잡힘.
  - 유지: 2차 EditText fallback → EditText 는 거의 URL bar 전용이라 false positive 거의 없음.

### 트레이드오프
- **회복:** false positive 0 — 본문 링크가 자동 검사되는 문제 완전 차단.
- **희생:** Firefox 일부 빌드 / UC Browser 처럼 URL bar 가 `android.view.View` (Compose) + 비표준 ID 인 케이스는 다시 미인식될 수 있음. 그러나 이는 신뢰도를 깨뜨리지 않으므로 안전한 방향.
- 사용자가 명시적으로 입력한 URL 만 검사된다는 핵심 약속을 우선.

---

## [0.4.8] — 2026-05-27 (Firefox 인식 — desc 임베드 URL 추출 / 실측 데이터 기반 픽스)

**앱 버전:** `0.4.8+26` · **브랜치:** `v0.1.2`

> 0.4.7 의 진단 덤프로 사용자 디바이스 Firefox 의 실제 URL bar 노드 구조를 확인. 단 한 가지
> 문제가 두 가지 동시에 걸려있었음. 추측이 아닌 실측 데이터로 정확히 픽스.

### Diagnosis — Firefox(Fenix) URL bar 실측 결과
```
id=ADDRESSBAR_URL_BOX  cls=android.view.View
text=''
desc=' google.com. 검색어 또는 주소 입력'
```

- ID 매칭은 통과 (`addressbar` 패턴이 `addressbar_url_box` 와 매칭).
- 그러나 `text` 가 비어있고, `contentDescription` 이 **URL + 한글 placeholder 안내문구가 혼합**
  된 형태(`google.com. 검색어 또는 주소 입력`).
- `looksLikeBarText` 는 공백 포함 텍스트를 거부 → URL bar 인식 실패 → 다음 노드로 진행 →
  결국 URL bar 못 찾음.
- 클래스가 `android.view.View` (Compose) 라 EditText / TextView fallback 도 모두 미스.

### Fix — `parseFromText` 로 desc 안의 URL 추출
- `android/.../BrowserAccessibilityService.kt`
  - `findUrlBarByMatchedId`: ID 매칭이 성공한 노드에 한해, `looksLikeBarText` 실패 시
    `UrlNormalizer.parseFromText(s)` 로 텍스트 안의 URL 부분만 추출해 반환.
  - `findInToolbarZone` (4차 위치 fallback): 위치 조건이 이미 false positive 를 충분히
    막아주므로 동일하게 `parseFromText` 추출 추가. 다른 마이너 브라우저의 placeholder 혼합
    desc 케이스 대비.
- 1·2·3차 fallback 순서·로직은 유지. ID 매칭 외 fallback 들은 클래스 strict 조건 + 텍스트
  strict prefix 검사 그대로.

### Behavior
- Firefox 페이지 보기 모드: `ADDRESSBAR_URL_BOX` 의 desc 에서 도메인 추출 → URL bar 로 인정.
- 페이지 이동·새 URL 입력: 동일하게 추출 동작.
- 기존에 잡히던 다른 브라우저(Chrome/Whale/Samsung/Opera/Edge/Brave/Yandex 등): 1차 ID 매칭
  + looksLikeBarText 통과로 그대로 동작 (parseFromText 경로 진입 안 함).
- 진단 덤프(`dumpNodeTreeOnce`) 는 그대로 유지 — 추후 다른 마이너 브라우저 디버깅용 자산.

### Files touched
- `android/app/src/main/kotlin/com/dhn/smishing/BrowserAccessibilityService.kt`
  (`findUrlBarByMatchedId` / `findInToolbarZone` 에 `parseFromText` 추출 경로 추가)
- `pubspec.yaml` `0.4.7+25 → 0.4.8+26`
- `CHANGELOG.md`, `README.md`

---

## [0.4.7] — 2026-05-27 (Firefox 대응 강화 — a11y flag 보강 · 위치 기반 4차 fallback · 진단 덤프)

**앱 버전:** `0.4.7+25` · **브랜치:** `v0.1.2`

> 0.4.6 의 TextView fallback 으로도 Firefox 가 여전히 잡히지 않는 사용자 보고. Mozilla 특유의
> a11y 노출 제한(important=false 노드, Compose 위젯 등) 을 함께 풀기 위해 세 가지 추가 시도.
> 동작 회귀 없이 인식 경로만 확장하므로 PATCH bump.

### Added — accessibility service flag 확장
- `android/app/src/main/res/xml/accessibility_service_config.xml`
  - `accessibilityFlags` 에 두 플래그 추가:
    - `flagIncludeNotImportantViews` — `isImportantForAccessibility="no"` 로 가려진 노드까지
      a11y tree 에 노출. Firefox 가 보안상 URL bar 를 important=false 로 표기하는 케이스 대응.
    - `flagRequestEnhancedWebAccessibility` — Firefox Gecko 의 web content 접근성 활성화 요청.

### Added — 4차 위치 기반 fallback (`findUrlBarByToolbarZone`)
- 화면 상단 ~280dp 또는 하단 ~180dp 영역 안의 노드 중 텍스트가 strict URL prefix
  (`http://` · `https://` · `www.`) 로 시작하는 첫 노드를 URL bar 로 인정.
- 클래스 제한(EditText / TextView) 없이 동작 → Compose 위젯·비표준 위젯으로 렌더링된 URL bar 도 인식.
- 페이지 본문 영역(가운데)은 위치 조건에서 자연 제외돼 false positive 위험 낮음.
- 호출 순서: 1차(ID 매칭) → 2차(EditText) → 3차(TextView) → **4차(위치 zone)**.

### Added — Firefox 패키지 진단 덤프 (`dumpNodeTreeOnce`)
- `org.mozilla.*` 패키지 첫 진입 시 a11y 트리의 노드 30개를 logcat 으로 1회 출력.
  - 각 노드의 `id` · `class` · `text` · `contentDescription` 표시.
  - 다음 빌드에서 정확한 ID/패턴을 추가할 수 있도록 사용자가 logcat 으로 확인 가능.
- 패키지당 한 번만 출력 (set 으로 중복 차단). 운영 빌드에서도 한 줄 분량 노이즈만 발생.

### Behavior
- Firefox 가 URL bar 노드를 important=false 로 가린 경우 → flag 추가로 보임 → 1~3차 fallback 으로 잡힘.
- 그래도 클래스가 Compose/비표준 → 4차 위치 fallback 으로 잡힘.
- 그래도 안 잡히면 logcat 의 진단 덤프로 실제 ID 확인 → 다음 빌드에 추가.

### Files touched
- `android/app/src/main/res/xml/accessibility_service_config.xml`
- `android/app/src/main/kotlin/com/dhn/smishing/BrowserAccessibilityService.kt`
  (import `Rect` / `scrapeFromUrlBarNodes` 4단계화 / `findUrlBarByToolbarZone` 신규 /
   `dumpNodeTreeOnce` 신규 / Mozilla 패키지 첫 진입 훅)
- `pubspec.yaml` `0.4.6+24 → 0.4.7+25`
- `CHANGELOG.md`, `README.md`

---

## [0.4.6] — 2026-05-27 (Firefox / UC Browser 인식 — TextView fallback + UC 변형 ID 보강)

**앱 버전:** `0.4.6+24` · **브랜치:** `v0.1.2`

> 사용자 보고: 0.4.5 의 동적 발견·EditText fallback 적용 후 대부분 브라우저는 잘 잡히는데
> Firefox 와 UC Browser 두 개만 여전히 누락. 두 브라우저는 URL bar 가 `EditText` 가 아닌
> `TextView` 로 렌더링되거나 빌드별로 ID 가 매번 달라지는 케이스. 휴리스틱을 한 단계 더 추가.
> 동작 회귀 없이 인식 범위만 넓히므로 PATCH bump.

### Root cause
- **Firefox / Fenix**: `mozac_browser_toolbar_url_view` 는 페이지 보기 모드에서 `TextView` 로
  렌더링됨 (입력 모드에서만 EditText). 0.4.5 의 2차 EditText fallback 이 클래스 불일치로 실패.
- **UC Browser**: 빌드마다 URL bar resource ID 가 다름 — `address_bar_address_input`,
  `search_text`, `multi_window_titlebar_search_text` 등. 일부 빌드는 EditText 가 아닌 TextView.
  0.4.5 의 ID 패턴 매칭이 일부 변형을 못 잡고, EditText fallback 도 클래스 불일치로 실패.

### Added — 3차 TextView fallback (`findUrlBarByTextViewFallback`)
- `android/.../BrowserAccessibilityService.kt`
  - `scrapeFromUrlBarNodes` 가 1차(ID 매칭) → 2차(EditText) → **3차(TextView)** 순으로 시도.
  - 3차는 `looksLikeStrictUrlText` 로 엄격하게 검사: 텍스트가 `http://` · `https://` · `www.`
    중 하나로 **시작** 하는 경우만 인정 (도메인-only 는 거절 — false positive 위험).
  - 공백 / `@` 포함 텍스트는 거절.
  - 호출 경로가 [BrowserPackages.all] 화이트리스트 통과 이벤트에서만 진입하므로 일반 앱
    페이지 본문은 잡히지 않음 (브라우저 안의 페이지 본문도 단독 TextView 가 아니라 본문 흐름에
    포함된 inline 텍스트라 거의 잡히지 않음).

### Added — `isUrlBarId` 변형 ID 보강
- UC Browser 변형: `address_input`, `search_text`, `titlebar_search`
- Firefox Mozac 일반화: `(id.contains("mozac") && id.contains("url"))`
  - 기존 `mozac_browser_toolbar_url_view` 외에 `mozac_browser_toolbar_url`,
    `mozac_toolbar_url_view` 같은 변형까지 한 번에 커버.

### Behavior
- Firefox / Fenix / Focus: 페이지 보기 모드에서도 TextView fallback 으로 인식.
- UC Browser intl / x86: 변형 ID + TextView fallback 으로 인식.
- 기존에 잘 잡히던 Chrome / Whale / Samsung / Opera / Edge / Brave / Yandex 등은 1차 ID 매칭
  으로 그대로 동작 (변경 없음).

### Files touched
- `android/app/src/main/kotlin/com/dhn/smishing/BrowserAccessibilityService.kt`
  (`scrapeFromUrlBarNodes` 3단계화 / `findUrlBarByTextViewFallback` 신규 /
   `looksLikeStrictUrlText` 신규 / `isUrlBarId` 패턴 보강)
- `pubspec.yaml` `0.4.5+23 → 0.4.6+24`
- `CHANGELOG.md`, `README.md`

---

## [0.4.5] — 2026-05-27 (브라우저 자동 발견 · URL bar 휴리스틱 대폭 확장)

**앱 버전:** `0.4.5+23` · **브랜치:** `v0.1.2`

> 사용자 보고: Chrome / Whale 은 정상 감지되는데 Opera 가 잡히지 않고, Samsung Internet
> 도 동작이 불확실하다는 이슈. 패키지 화이트리스트 누락 + URL bar View ID 패턴 미스 두 가지가
> 원인. 새 브라우저가 나와도 코드 수정 없이 자동 인식되도록 동적 발견 경로까지 같이 추가.
> 동작 회귀 없이 감지 범위만 넓히므로 PATCH bump.

### Added — 디바이스 브라우저 동적 발견
- `android/.../BrowserPackages.kt` 개편
  - 기존 `val all = setOf(...)` (정적) → `baseSet` (하드코딩 fallback) + `dynamicSet`
    (런타임 발견) 의 union 으로 동작하는 `val all` 로 전환.
  - `refresh(context)`:
    `PackageManager.queryIntentActivities(VIEW + CATEGORY_BROWSABLE, "https://www.example.com")`
    와 `"https://nonexistent-host.test/path"` 두 호출의 **교집합** 으로 디바이스에 설치된
    모든 브라우저를 자동 식별 (일반 deep link 앱은 자기 도메인만 받아 자연 제외됨).
- `android/.../BrowserAccessibilityService.kt`
  - `onServiceConnected()` 에서 `BrowserPackages.refresh(applicationContext)` 호출.
  - manifest 의 `<queries>` 에 http/https VIEW intent 가 이미 등록되어 Android 11+
    패키지 가시성 제한 하에서도 정상 조회됨.

### Added — baseSet 누락 패키지 보강
- 0.4.4 까지의 정적 목록에 없던 식별자 추가:
  - Chrome: `com.chrome.dev`, `com.chrome.canary`, `org.chromium.chrome`
  - Whale: `com.naver.whale.beta`
  - Samsung Internet: `com.sec.android.app.sbrowser.lite`
  - Firefox: `org.mozilla.fennec_fdroid`, `org.mozilla.focus`, `org.mozilla.klar`
  - Edge: `com.microsoft.emmx.beta/dev/canary`
  - Opera: `com.opera.browser.beta`, `com.opera.mini.native.beta`, `com.opera.gx`
  - Brave: `com.brave.browser_beta`, `com.brave.browser_nightly`
  - Vivaldi: `com.vivaldi.browser.snapshot`
  - DuckDuckGo: `com.duckduckgo.mobile.android.debug`
  - Chinese / Asian: `com.mi.globalbrowser.mini`, `com.UCMobile.x86`, `com.tencent.mtt`,
    `com.baidu.browser.inter`, `com.qihoo.contents`
  - Niche / privacy: `org.bromite.bromite`, `org.lineageos.jelly`,
    `acr.browser.lightning/barebones`, `org.adblockplus.browser`, `com.cake.browser`,
    `com.cloudmosa.puffinFree`, `mark.via.gp`, `mark.via`, `com.androidbull.incognito.browser`,
    `com.startpage.app`, `org.torproject.torbrowser`, `info.guardianproject.orfox`

### Added — `isUrlBarId` 매칭 패턴 확장
- `android/.../BrowserAccessibilityService.kt`
  - 추가된 패턴: `urlbar`, `url_field`(Opera), `url_view`/`mozac_browser_toolbar_url_view`(Firefox Fenix),
    `url_input`, `url_text`, `url_edit`, `omnibar`(Yandex), `addressbar`, `address_field`,
    suffix `:id/url`.
  - 기존 패턴(`url_bar`, `omnibox`, `location_bar`, `address_bar`, `search_box`,
    `toolbar+url`, `line_1`-whale/chrome) 은 유지.

### Added — `EditText` + URL 형태 텍스트 fallback
- ID 매칭이 실패해도 노드 클래스가 `android.widget.EditText` (또는 `.EditText` 로 끝나는
  Chromium 의 커스텀 클래스) 이고 텍스트가 URL 패턴이면 URL bar 로 인정.
- 호출 경로가 이미 `BrowserPackages.all` 화이트리스트를 통과한 브라우저 이벤트에서만 진입하므로
  일반 앱의 검색 입력창은 잡히지 않음.
- `scrapeFromUrlBarNodes` 를 `findUrlBarByMatchedId` (1차) + `findUrlBarByEditTextFallback`
  (2차) 두 단계로 분리. 1차 신뢰도 높은 매칭이 먼저 시도되고, 실패 시에만 2차로 fallback.
- `isUrlBarEvent` (typing 분기 진입 판정) 도 동일한 EditText fallback 적용.

### Behavior
- Chrome / Whale: 기존과 동일 (1차 ID 매칭으로 즉시 인식).
- Samsung Internet: `location_bar_edit_text` 가 1차 ID 매칭으로 인식 + lite 빌드도 baseSet 에 추가.
- Opera: `url_field` 가 추가된 ID 패턴에 매칭됨 (이전엔 ID 매칭 실패 → 통째로 누락).
- Firefox / Focus: `mozac_browser_toolbar_url_view` 매칭 + EditText fallback 보강.
- Yandex: `omnibar` 매칭 추가.
- 디바이스에만 설치된 마이너 브라우저: `BrowserPackages.refresh` 가 자동 인식.

### Files touched
- `android/app/src/main/kotlin/com/dhn/smishing/BrowserPackages.kt` (전면 개편)
- `android/app/src/main/kotlin/com/dhn/smishing/BrowserAccessibilityService.kt`
  (`onServiceConnected` / `scrapeFromUrlBarNodes` / `isUrlBarEvent` / `isUrlBarId`)
- `pubspec.yaml` `0.4.4+22 → 0.4.5+23`
- `CHANGELOG.md`, `README.md`

---

## [0.4.4] — 2026-05-27 (Android Auto Backup · Device Transfer 전면 비활성화)

**앱 버전:** `0.4.4+22` · **브랜치:** `v0.1.2`

> **버그/보안 회귀 수정.** 사용자가 앱을 삭제·재설치하거나 단말을 교체해도 이전의 위험
> 검사 이력(타임라인)·검사 통계·userid·설정값이 Google Auto Backup → 자동 복원
> 경로로 부활하던 문제를 차단. 동작 흐름 변경뿐이라 PATCH bump.

### Reported
- 사용자가 `타임라인 비우기` → `앱 삭제` → `최신 빌드(0.4.3) 재설치` 를 했는데도 5월 23일
  9시 18분 위험 검사 항목 2건이 그대로 살아 돌아오는 현상 보고.

### Root cause
- `AndroidManifest.xml` 의 `<application>` 에 `android:allowBackup` 가 미명시 →
  Android 기본값 `true` 로 동작. `dataExtractionRules` 도 없어 Android 12+ 의 D2D 전송도 활성.
- 결과적으로 `SharedPreferences` 의 `timeline_dangerous_v1`, scan stats, userid 등이
  Wi-Fi + 충전 + idle 상태에서 24시간 주기로 Google 서버에 자동 백업되고,
  재설치 시 OS 가 그 백업본을 자동 복원해 클라이언트 측 "비우기" 가 무력화됨.

### Fix
- `android/app/src/main/AndroidManifest.xml` 의 `<application>` 에 세 속성 추가:
  - `android:allowBackup="false"` — Android 11 이하 Auto Backup 비활성.
  - `android:fullBackupContent="false"` — 명시적으로 full backup 거부.
  - `android:dataExtractionRules="@xml/data_extraction_rules"` — Android 12+ 표준 규칙 적용.
- **신규** `android/app/src/main/res/xml/data_extraction_rules.xml`
  - `<cloud-backup>` 과 `<device-transfer>` 모두에서
    `root / file / database / sharedpref / external` 다섯 도메인 전부 `<exclude>`.
  - 즉 Google Drive 자동 백업 · 새 단말 D2D 이전 양쪽에서 이 앱의 어떤 데이터도 전송되지 않음.

### Operational note — 기존 백업본 잔존
- 이번 변경은 **앞으로의 백업/복원만 차단**한다. 이전에 이미 클라우드에 올라간 백업본은
  Google 서버에 남아있을 수 있고, **이 빌드를 처음 깔 때 한 번까지는 OS 가 복원을 시도**할 수 있음.
- 깨끗하게 비우려면 사용자가 다음 중 하나를 한 번 수행해야 한다:
  - 앱 안에서 `타임라인` → 하단 `타임라인 비우기` 버튼 (0.4.2 에서 추가됨)
  - 설정 → 앱 → 경남 안심링크 → 저장공간 → **데이터 삭제**
  - 설정 → Google → 백업 → 앱 데이터에서 이 앱 항목 삭제 후 재설치

### Side effects (의도된 동작 변경)
- 사용자가 단말을 교체하거나 앱을 재설치하면 `userid`(secure storage), `api_base_url`,
  mock 모드, `vibrate_on_detect` 같은 설정값이 자동 계승되지 않음. 첫 실행 시 새로 발급/설정됨.
- 스미싱 검사 이력(타임라인)·일일 검사 통계도 클라우드에 남지 않아 PIPA · Play Data Safety 관점에서 더 깨끗해짐.

### Why
- 검사 이력은 본인이 어떤 메시지를 받았는지 추론할 수 있는 **민감 정보**. 클라우드 백업까지
  들어가는 건 PIPA 의 '수집 최소화' 원칙과 Google Play 데이터 보안 정책 모두에서 권장되지 않음.
- 사용자가 명시적으로 `비우기 + 삭제` 행동을 했을 때 그 의도가 OS 백업으로 무력화되는 건
  심각한 신뢰성 문제.

### Files touched
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/xml/data_extraction_rules.xml` (신규)
- `pubspec.yaml` `0.4.3+21 → 0.4.4+22`
- `CHANGELOG.md`, `README.md`

---

## [0.4.3] — 2026-05-27 (testsafebrowsing 하드코딩·QA 우회 전면 제거)

**앱 버전:** `0.4.3+21` · **브랜치:** `v0.1.2`

> 데모/QA 단계에서 박아뒀던 `testsafebrowsing.appspot.com` 강제 위험 처리, 설정 화면의
> '스미싱 테스트 링크 검사' 버튼, 네이티브 측 `runTestSmishingCheck` 핸들러를 모두 제거.
> 이제 동일 URL 도 다른 URL 들과 똑같이 백엔드 `/check_uri` 응답을 그대로 따른다.
> 기능 회귀 없이 우회 경로만 제거하므로 PATCH bump.

### Removed — Flutter
- `lib/core/smishing_api_client.dart`
  - `static bool isKnownTestDangerUrl(String uri)` helper 삭제.
  - `checkUri()` 의 분기를 `if (mockMode || isKnownTestDangerUrl(normalized))`
    → `if (mockMode)` 로 단순화. 운영 모드는 어떤 URL 이든 서버 응답 그대로.
  - `_mockCheck()` 안의 `|| lower.contains('testsafebrowsing.appspot.com')` 제거.
    mock 키워드 매칭은 `phish/evil/fake/scam/malware/virus` 만 유지 (mock 모드 한정).
- `lib/services/native_bridge.dart`
  - `runTestSmishingCheck()` wrapper + 관련 주석 제거.
- `lib/features/settings/settings_page.dart`
  - `스미싱 테스트 링크 검사 (앱 내부)` `FilledButton.tonal` 과 그 아래 SizedBox 제거.
  - 검증은 외부에서 실제 메시지로 testsafebrowsing URL 을 보내 서버 응답을 확인하는 방식으로 전환.

### Removed — Kotlin
- `android/.../UriCheckBridge.kt`
  - `private fun isKnownTestDangerUrl(uri: String)` 메서드 삭제.
  - `checkText()` 시작부의 `if (!urls.any { isKnownTestDangerUrl(it) } && inboundSmsDedup(...))`
    → `if (inboundSmsDedup(...))` 로 정리. 더 이상 특정 도메인 우회 없음.
  - `checkAndWarn()` 의 `val useLocalTestRules = mock || isKnownTestDangerUrl(...)`
    → `mock` 단일 플래그로 단순화. 시그니처 `localDangerCheck(uri, mockEnabled)`
    → `localDangerCheck(uri)` (mock 모드 안에서만 호출되므로 인자 불필요).
  - `localDangerCheck()` 안의 `|| isKnownTestDangerUrl(uri)` 와 메시지 분기에서
    `isKnownTestDangerUrl(uri) -> "Google Safe Browsing 테스트 URL..."` case 제거.
- `android/.../NativeBridgePlugin.kt`
  - `"runTestSmishingCheck" -> { ... UriCheckBridge.checkText(... testsafebrowsing ...) }`
    MethodChannel 핸들러 블록 완전 제거.

### Changed — Test fixture
- `test/url_extractor_test.dart`
  - 멀티라인 한국어 본문 안의 fixture URL 을
    `https://testsafebrowsing.appspot.com/s/malware.html` → `https://example.com/path/to/page.html`
    로 교체. URL 추출 기능 검증은 그대로 유지.

### Why
- 시연·회귀 테스트 단계에서 의도적으로 서버 응답을 우회해 항상 위험 알람을 띄우던 코드였음.
- API 연동이 완료된 시점에서 같은 URL 도 실제 서버가 어떻게 판정하는지(0000/0001/그 외)를
  확인해야 운영 환경 동작이 정확해짐. 우회가 남아있으면 그 검증이 막힘.
- 5월 23일 9시 18분 등에 보였던 타임라인 자동 항목은 이 핸들러를 통한 테스트 흔적이었음.

### Files touched
- `lib/core/smishing_api_client.dart`
- `lib/services/native_bridge.dart`
- `lib/features/settings/settings_page.dart`
- `android/app/src/main/kotlin/com/dhn/smishing/UriCheckBridge.kt`
- `android/app/src/main/kotlin/com/dhn/smishing/NativeBridgePlugin.kt`
- `test/url_extractor_test.dart`
- `pubspec.yaml` (`0.4.2+20 → 0.4.3+21`)
- `CHANGELOG.md`, `README.md`

---

## [0.4.2] — 2026-05-27 (타임라인 비우기 액션 · 설정 페이지 정책 항목 정리)

**앱 버전:** `0.4.2+20` · **브랜치:** `v0.1.2`

> 사용자가 직접 검사 이력을 비울 수 있는 액션을 타임라인 하단에 추가하고, 메인 화면 푸터와 중복되던
> 설정 화면의 `오탐·면책 안내` 항목을 제거. 동작 회귀는 없고 UI/엔트리 포인트 정리 중심이라 PATCH bump.

### Added — 타임라인 비우기 (PIPA 사용자 권리: 삭제 요청)
- `TimelineStore.clear()` 추가
  - 메모리 `entries` 와 `SharedPreferences` 의 `timeline.v1` 키 모두 제거.
- `lib/features/history/history_page.dart`
  - `Scaffold.bottomNavigationBar` 슬롯에 **하단 고정 액션** 으로 비우기 버튼 배치.
  - `FilledButton.tonalIcon` + `Icons.delete_sweep_outlined` · 빨간 톤(`#FEE2E2 / #B91C1C`) ·
    높이 50dp · 라운드 14dp · 라벨에 현재 건수 표기 (`타임라인 비우기 (N건)`).
  - 비어있을 때는 `비울 이력 없음` 으로 자동 비활성화.
  - `_confirmClear(count)` AlertDialog 로 두 번 확인:
    - 제목 `타임라인을 비울까요?`
    - 본문 `저장된 N건의 위험 검사 이력이 모두 삭제됩니다. 이 작업은 되돌릴 수 없어요.`
    - 액션 `취소` / `비우기` (빨간 톤).
  - 확정 시 `TimelineStore.clear()` 호출 후 `setState` + SnackBar `타임라인을 비웠습니다`.

### Removed — 설정 화면의 중복 `오탐·면책 안내` 항목
- `lib/features/settings/settings_page.dart`
  - 하단의 `오탐·면책 안내` `ListTile` 과 그 위 `Divider` 제거.
  - 동반 unused `LegalNoticePage` import / `final theme = Theme.of(context)` 도 같이 정리.
- 정책 페이지 진입점은 **메인 화면 푸터의 `오탐·면책 안내 보기` 텍스트 버튼** 하나로 단일화.

### Why
- 0.4.0 의 30일 보존 정책 (`TimelineStore._retention`) 하에서 mock·테스트 기록이 30일간 잔존했고,
  사용자가 본인 의지로 즉시 정리할 수단이 없었음.
- 정책 진입점이 메인/설정 두 곳에 중복되어 있었던 부분도 함께 정리.

### Files touched
- Added action: `lib/core/timeline_store.dart`, `lib/features/history/history_page.dart`
- Removed entry: `lib/features/settings/settings_page.dart`
- Version: `pubspec.yaml` `0.4.1+19 → 0.4.2+20`
- Docs: `CHANGELOG.md`, `README.md`

---

## [0.4.1] — 2026-05-27 ('오늘 검사' 카운트 정상화 · 서버 전송 시 쿼리스트링 제거)

**앱 버전:** `0.4.1+19` · **브랜치:** `v0.1.2`

> 0.4.0 의 두 가지 회귀/누락을 보정. 동작/숫자 변경뿐이라 PATCH bump.

### Fixed
- **메인 화면 `오늘 검사` 카운트가 `차단` 과 동일하게만 증가하던 문제 수정**
  - 0.4.0 흐름: 네이티브(`UriCheckBridge`) 가 안전·위험 결과를 모두 `NativeBridgePlugin.emit()`
    으로 push 했지만, Flutter 의 `NativeBridge.startListening` 이 **위험일 때만**
    `ScanPipeline.recordResult` 를 호출. 그 안에서 `recordScan + recordBlocked` 동시에 +1
    하다 보니 두 카운트가 사실상 같은 숫자가 됨.
  - 수정: `NativeBridge.startListening` 가 code 가 있는 모든 결과(안전·위험)에 대해
    `ScanStats.recordScan()` 을 호출하도록 변경. `ScanPipeline.recordResult` 에서는
    중복되던 `recordScan()` 호출을 제거하고 `recordBlocked()` 만 유지.
  - 결과: 네이티브가 검사한 모든 시도가 `오늘 검사`, 그중 위험만 `차단` 에 합산.

### Changed — 서버 전송 시 쿼리스트링·프래그먼트 제거
- `lib/core/url_extractor.dart` · `android/.../UrlNormalizer.kt` 양쪽에 `stripQueryAndFragment(url)` helper 추가.
  - `?` 또는 `#` 위치를 찾아 그 뒤를 잘라낸 path-까지의 URL 만 반환.
- `SmishingApiClient.checkUri` (Flutter) · `UriCheckBridge.postCheck` 호출 직전 (Kotlin)
  에서 `displayUri` 가 아닌 `stripQueryAndFragment(displayUri)` 를 body 의 `uri` 로 전송.
- **오버레이·타임라인·캐시 키 등 UI 와 내부 상태는 여전히 원본 URL** 을 그대로 사용
  (사용자가 본 그대로의 URL 을 표시·기록).

### Why query strip
- 쿼리스트링에는 사용자 식별자 / 광고 트래킹 / 세션 토큰 등이 자주 섞임 — 우리 서버가
  탐지에 쓸 필요 없는 데이터까지 전송되는 것을 막아 **수집 데이터 최소화** (PIPA·Play Data
  Safety 와 일치).
- 같은 도메인·path 의 URL 은 쿼리만 달라도 동일 사이트이므로 탐지 정확도에는 영향 없음.

### Notes
- 캐시 키(`UrlNormalizer.canonicalBrowserKey`) 는 이미 path 까지만 사용했으므로 캐시 적중에는 영향 없음.
- 로그도 `display=… server=…` 두 형태를 모두 출력하도록 보강(디버깅 편의).

---

## [0.4.0] — 2026-05-26 (메인 화면 · 오버레이 알림 풀 리뉴얼 — Play Store mockup → 실제 UI 반영)

**앱 버전:** `0.4.0+18` · **브랜치:** `v0.1.2`

> Play Store 등록용 mockup 으로 만들어 본 화면이 실제 앱보다 훨씬 깔끔하다는 피드백에서 출발.
> mockup 의 디자인 의도를 두 핵심 화면에 그대로 옮기고, 사용자 통계(오늘 검사·차단) 카드를 신설.
> 시각 변경 폭이 커서 MINOR bump.

### Added — 메인 화면(`guard_status_page.dart`)
- **Hero status card** — 보호 ON 일 때 `#3B82F6 → #1D4ED8` 파란 그라데이션 + 8dp drop shadow.
  좌측에 런처 아이콘 PNG (`assets/icon/guard_shield.png`), 우측에 "현재 상태 / 보호 활성화됨 /
  SMS · 카카오톡 · 텔레그램 · 브라우저 / [실시간 감지중 칩]". OFF 는 회색 톤으로 자동 전환.
- **Protection toggle card** — 화이트 카드 + 큰 `Switch.adaptive` + 보조 문구.
- **Today stats** — 가로 2분할 카드 (`오늘 검사 / 차단`). 큰 30sp 숫자 + 단위.
- **Permissions card** — 점(●) 으로 상태 색을 표시(`#22C55E 허용 / #DC2626 필요 / #F59E0B 선택`)
  + 우측에 `허용됨 / 필요 / 선택` 라벨 + chevron.
- **Open history tile** — `colorScheme.primary` 의 6%/16% 톤 filled tonal 박스 + chevron.
- 푸터에 `경남 안심링크 · v0.4.0` 표시.

### Added — 오버레이 알림(`overlay_warning_message.xml` 전면 재설계)
- **빨간 그라데이션 헤더**(기존 `overlay_header_gradient` 재활용) + 큰 알림 아이콘
  (`overlay_header_icon_bg.xml` 반투명 흰 원 + 32sp `!`) + 작은 라벨 "경남 안심링크" + 큰 제목
  "스미싱 의심 링크 감지" 로 통일.
- **출처 칩** — `overlay_source_chip_bg.xml` (옐로우 `#FEF3C7` pill) + 28dp 원형 아이콘
  (`overlay_source_check_bg.xml` 골드 fallback, 코드는 source 별 brand color 로 override).
  카카오/텔레그램/LINE/SMS 는 Material-style 추상 아이콘, 브라우저는 "웹" 한글 글자.
- **의심 URL 박스** — `overlay_url_box_bg.xml` (`#FEF2F2` + `#FCA5A5` outline + 12dp radius)
  안에 `#991B1B` 굵은 텍스트, `textIsSelectable` 유지.
- **메시지 미리보기** — body 가 있을 때만 label + 카드 함께 표시(이전엔 카드만 보였음).
- **한 줄 진단** — 라벨 + 14sp bold `#0F172A`.
- **광고 영역** — `overlay_panel_soft` 패널 + 좌상단 검정 반투명 "광고" 배지 + 클릭 가능.
- **버튼 페어** — `앱 열기` (파란 `#1D4ED8` solid, `overlay_btn_open_app.xml`) +
  `무시` (white + `#CBD5E1` outline, `overlay_btn_ignore.xml`). 두 버튼이 weight=1 로 균등 배분.
- 푸터에 `탐지 시각 yyyy-MM-dd HH:mm:ss` (`overlay_detected_at`).

### Added — 통계 인프라
- `lib/core/scan_stats.dart` — `recordScan()` / `recordBlocked()` / `read()` 만 노출하는
  가벼운 카운터 (`SharedPreferences` 기반). 오늘 날짜 키가 바뀌면 `_ensureToday` 가 자동 리셋.
- `ScanPipeline.checkUrl` — API 호출 성공 직후 `recordScan()`, `isDangerous` 면 `recordBlocked()`.
- `ScanPipeline.recordResult` — 네이티브가 push 한 위험 결과에도 `recordScan/Blocked` 적용.

### Added — drawable 리소스
- `overlay_header_icon_bg.xml` — 헤더 큰 `!` 원 (반투명 흰)
- `overlay_source_chip_bg.xml` — 출처 칩 옐로우 pill
- `overlay_source_check_bg.xml` — 출처 칩 안 골드 원
- `overlay_url_box_bg.xml` — 의심 URL 박스 (red soft + outline)
- `overlay_ad_panel_blue.xml` — 광고 영역 파란 그라데이션 (mockup 의 광고 카드 톤)
- `overlay_btn_open_app.xml` — 앱 열기 버튼 (blue solid)
- `overlay_btn_ignore.xml` — 무시 버튼 (white + neutral outline)
- `overlay_ad_label_bg.xml`, `overlay_ad_cta_bg.xml` — 광고 영역 부속 배지/CTA pill

### Changed
- `pubspec.yaml` — `version: 0.4.0+18`. `flutter.assets` 에 `assets/icon/guard_shield.png` 등록
  (Hero card 용. Play Store hi-res icon 과 동일 PNG 재사용).
- `OverlayWarningWindow.kt`:
  - `bindBrowserStyle / bindMessageStyle` 의 공통 버튼 핸들러를 `bindButtons()` 로 추출.
  - `overlay_app_time` / `overlay_badge` 참조 제거(레이아웃에서 삭제됨).
  - 헤더 문구를 두 스타일 모두 "스미싱 의심 링크 감지" 로 통일.
  - 출처 칩의 발신자 텍스트 포맷:
    - 브라우저 → `"브라우저 주소창"`
    - 그 외 → `"$appLabel 메시지"` (예: `카카오톡 메시지`)
- `guard_status_page.dart` 전체 재작성 (위 Hero/Toggle/Stat/Permissions/History 위젯 분해).

### Removed
- 메인 화면에서 단일 큰 `FilledButton.icon (보호 시작/중지)` — 토글 카드의 `Switch` 가 대체.
- 오버레이 레이아웃의 `overlay_app_time` / `overlay_badge` 필드 (새 헤더 디자인에서 불필요).

### Notes
- 메인 화면 PNG hero 아이콘은 512x512 한 장만 들어가며 Flutter 가 디바이스 dpi 에 맞춰 resample.
  Play Console 의 hi-res 아이콘과 단일 자산이라 디자인 변경 시 동기화 자연스럽게 유지.
- 통계는 의도적으로 client-side only — 서버로 전송 안 함 (Privacy Policy 와 일관).
- `withValues(alpha:)` (Flutter 3.27+) 가 아닌 `withOpacity()` 로 작성해 3.19 호환 유지.

---

## [0.3.0] — 2026-05-26 (오버레이 발신처 아이콘 — Material-style 추상 아이콘으로 교체)

**앱 버전:** `0.3.0+17` · **브랜치:** `v0.1.2`

> 발신처 식별 UI 가 글자 → 아이콘으로 바뀌어 사용자 가시 변경이 큼. MINOR bump.

### Why
- 카카오톡/텔레그램/LINE 등 **공식 로고를 그대로 카피해 박는 것은 trademark/저작권**
  분쟁 여지 (특히 한국 KakaoCorp 매우 엄격). 공공/안전 성격 앱이라 risk 완전 차단이 우선.
- 다행히 식별의 핵심은 brand color (이미 #FEE500 / #29B6F6 / #06C755 등 적용 중)이고
  여기에 generic 아이콘만 다르게 두면 사용자 인지에 손해 없음.

### Added
- `res/drawable/ic_app_kakao.xml` — 말풍선 + 3 dots (Material `chat`)
- `res/drawable/ic_app_telegram.xml` — 종이비행기 (Material `send`)
- `res/drawable/ic_app_line.xml` — 외곽선 말풍선 (Material `chat_bubble_outline`)
- `res/drawable/ic_app_sms.xml` — 편지 봉투 (Material `email`)
- (모두 Apache 2.0 라이선스 Material Symbols 원본 path 사용 — 상용 OK)

### Changed
- **오버레이 좌상단 발신처 배지**: 기존 `K / T / L / 문 / W` 글자 → 각 플랫폼 추상 아이콘.
  웹은 글자 그대로지만 `W → 웹` (한글) 으로 교체.
- `overlay_warning_message.xml`: 발신처 슬롯을 `FrameLayout` 으로 감싸 `TextView`(웹용)
  + `ImageView`(나머지) stack. 코드에서 source 에 따라 visibility 토글.
- `OverlayWarningWindow.kt`:
  - `bindAppIcon(view, source)` 단일 진입점 추가.
  - `iconResForSource(source)` 신규 — drawable 매핑. 매핑 없으면 글자 fallback.
  - `iconLetterForSource` 는 이제 `browser → "웹"`, 그 외 unknown → `"!"` 로 축약.
  - `iconColorForSource` 에 `browser → #81C784` 명시 추가 (이전엔 fall-through 였음).

### Notes
- 모든 아이콘 `fillColor="#212121"` 단일 톤 + brand color 원형 배경 → 시각 일관성.
- LINE 은 outline 스타일을 일부러 골라 카카오의 filled bubble 과 시각적으로 구분.
- SMS 는 envelope 으로 — 다른 chat-bubble 형 아이콘과 명확히 분리.

---

## [0.2.6] — 2026-05-26 (런처 아이콘: 내부 방패 좌우 split + vertical seam — heraldic 입체감)

**앱 버전:** `0.2.6+16` · **브랜치:** `v0.1.2`

### Added
- **내부 청색 방패에 heraldic per-pale 입체감 추가** — 평면 그라데이션 단일 fill 위에:
  - **좌측 절반:** `#22FFFFFF` (옅은 흰) overlay — 광원이 좌측 위에서 들어오는 듯한 highlight.
  - **우측 절반:** `#22000000` (옅은 검정) overlay — 그늘진 면.
  - **가운데 vertical seam line** — `#AAFFFFFF` stroke 0.6dp, glyph 영역(y 52~63)을 비우고
    위(36~51) / 아래(63~79) 두 segments 로만 그려 GSL 글자와 충돌 회피.
- 결과: 평면이던 inner panel 에 fold/광원 면이 생겨 premium 깊이감 ↑.

### Notes
- alpha 13% 수준의 매우 옅은 overlay 라 강한 split 처럼 보이지 않고
  자연스러운 명암 차이만 줌. 너무 거슬리면 alpha 0x22 → 0x18 로 한 단계 옅게 조정 가능.

---

## [0.2.5] — 2026-05-26 (런처 아이콘 마지막 톤 보정: 하단 여백 · GSL 슬림)

**앱 버전:** `0.2.5+15` · **브랜치:** `v0.1.2`

### Fixed
- **외곽 방패 하단이 background 와 거의 붙어 답답하던 문제** — 방패 bottom
  `89 → 86` (3dp 위로). 사이드 V 끝도 `56 → 54` 로 비례 조정. 원형 mask /
  사각 mask 모두에서 background 와 시각적 여백 확보.
- **inner panel** 도 외곽과의 ring 간격 유지 위해 bottom `82 → 80`, V 끝 `57 → 56`.
- **GSL 글자가 inner panel 안에서 너무 꽉 차 보이던 문제** — box `8×11 → 7×9.5`,
  stroke `3.0 → 2.6` 으로 슬림화. center 간격 `11 → 10.5` 로 미세 좁힘.
  → inner panel 가로(`33~75`) 안에 양쪽 여유 ~5dp.

---

## [0.2.4] — 2026-05-26 (런처 아이콘 비율 보정: 방패 축소 · GSL 통일·인너 정렬)

**앱 버전:** `0.2.4+14` · **브랜치:** `v0.1.2`

### Fixed
- **외곽 방패가 viewport 가득 차 좀 답답해 보이던 문제** — 각 변 약 3dp 축소
  (`24~84 / 22~92` → `27~81 / 25~89`). adaptive icon safe-zone 안에 더 잘 들어옴.
- **GSL 글자 크기가 G/S/L 모두 달랐던 문제** — 세 글자 모두 **8dp × 11dp** 동일
  bounding box 로 다시 그림. center 간격 11dp 균등.
- **GSL 이 내부 청색 패널을 넘어가 보이던 문제** — 글자 가로 범위 `38~70` 으로
  좁혀 inner panel (`33~75`) 안에 양쪽 ~3dp 여유로 정착. 세로도 `52.5~63.5` 로
  inner panel 세로 (`35~82`) 중심에 맞춤.

### Changed
- 그림자 / 상단 광택 / 다이아몬드 / inner panel 좌표 모두 새 외곽 방패에
  비례 재계산.

---

## [0.2.3] — 2026-05-26 (브랜드 컬러 = 신뢰감 청색 · 런처 아이콘 premium · 앱 테마 통일)

**앱 버전:** `0.2.3+13` · **브랜치:** `v0.1.2`

> 사용자 가시 변경 다수 (브랜드 컬러 / 런처 아이콘 / 앱 화면 톤). 그러나 0.2.x
> 안에서 디자인 패치 흐름이므로 PATCH 로 bump.

### Changed
- **브랜드 시드 컬러 = blue-700 (`#1D4ED8`)** 로 확정. `lib/main.dart` 에
  `kBrandSeed` 상수 추가, 앱 전반 `ColorScheme.fromSeed(seedColor: kBrandSeed)`.
- **AppBar / Card / FilledButton 테마 통일** — 메인·설정·이력·법적 안내 화면 모두
  M3 surface tonal 청색 톤. AppBar 는 `primary` 배경 + `onPrimary` 글자 색으로
  브랜드 톤 강조.
- **권한 설정 다이얼로그** 의 OK 상태 색 `Colors.teal` → `kBrandSeed`. 브랜드 톤
  단일 source-of-truth 로 통일.
- **런처 아이콘 디자인 premium 리프레시:**
  - **외곽 방패**: 흰색→슬레이트(`#F8FAFC → #CBD5E1`) 그라데이션.
  - **골드 외곽 ring** (`#F59E0B`, 1.4dp stroke) — premium 포인트.
  - **상단 작은 골드 다이아몬드** — heraldic emblem 느낌.
  - **내부 패널(작은 청색 방패)** — `#3B82F6 → #1E3A8A` 그라데이션 + 옅은 흰 stroke,
    뎁스 살림.
  - **GSL 글자** — stroke 두께 `2.6 → 3.2` 로 더 또렷, 흰색, round cap/join.
  - **Background gradient** = `#3B82F6 → #1D4ED8 → #1E3A8A` (light → mid → deep navy)
    신뢰감 있는 청색 톤.

### Notes
- 상태 의미 색 (보호 ON 녹색 / 위험 빨강 / 경고 주황) 은 UX 명확성 위해 유지.
- AppBar `centerTitle=false` + `letterSpacing=0.2` 로 한국어 가독성 미세 조정.

---

## [0.2.2] — 2026-05-26 (런처 아이콘 디자인 리프레시: GSL · cyan→indigo gradient)

**앱 버전:** `0.2.2+12` · **브랜치:** `v0.1.2`

### Changed
- **런처 아이콘 글자: `G` → `GSL`** (Gyeongnam Safety Link 약자).
  - 표기 정정: 사용자 입력은 'Gyeungnam' 이었지만 국문 로마자 표준은 **Gyeongnam**.
    GSL 약자 자체는 그대로.
- **런처 아이콘 색감 / 디자인 톤 현대화** (단색 → 채도 / 다층 그라데이션):
  - **Background:** 3-stop linear gradient
    `#06B6D4` (cyan-500) → `#2563EB` (blue-600) → `#6366F1` (indigo-500).
    SaaS/핀테크 톤의 vivid + modern.
  - **Shield body:** 단색 흰색 → `#FFFFFF → #E0E7FF` (옅은 인디고로 떨어지는)
    linear gradient (aapt `<gradient>` 사용). 단조로움 제거.
  - **Shield highlight:** 위쪽에 `#44FFFFFF` 옅은 광택 한 줄로 입체감.
  - **GSL 글자:** stroke 방식 (fill 아님). `strokeColor="#312E81"` (indigo-900),
    `strokeWidth="2.6"`, `strokeLineCap="round"`, `strokeLineJoin="round"` —
    현대 산세리프 'clean line' 톤.
- **호환성:** Android 8(API 26)+ adaptive 아이콘만 갱신. PNG fallback 은 그대로.

---

## [0.2.1] — 2026-05-26 (런처 아이콘 신규 + FGS 아이콘 G 위치 보정)

**앱 버전:** `0.2.1+11` · **브랜치:** `v0.1.2`

### Added
- **런처 아이콘(Adaptive Icon)** 신규 — 방패 + 골드 'G' 디자인.
  - `drawable/ic_launcher_foreground.xml`: 108×108 viewport. 흰색 방패 fill +
    위쪽 옅은 highlight + 그림자, 안에 골드(`#F9A825`) G.
  - `drawable/ic_launcher_background.xml`: 청색 linear gradient
    (`#1E88E5` → `#1565C0` → `#0D47A1`, 위→아래).
  - `mipmap-anydpi-v26/ic_launcher.xml`, `ic_launcher_round.xml` 추가.
  - **호환성:** Android 8(API 26)+ 단말은 새 adaptive 아이콘으로 표시. API 25 이하는
    기존 PNG fallback (추후 별도 갱신 권장).

### Fixed
- **FGS 상태바 아이콘의 G 글자가 좌측 하단으로 쏠려 보이던 문제** —
  G path 를 `<group>` 으로 감싸 `translateX="0.55"`, `translateY="-1.25"` 적용해
  방패 시각 중심에 맞춤.

---

## [0.2.0] — 2026-05-26 (브랜딩: '경남 안심링크' · FGS 방패+G 아이콘 · 오버레이 광고)

**앱 버전:** `0.2.0+10` · **브랜치:** `v0.1.2`

> 사용자 가시 변경(앱 이름·아이콘·오버레이 신규 영역)이 함께 들어가 MINOR 로 bump.

### Added
- **오버레이 광고 영역** — 오버레이 노출 시 `/get_ad_img` 1회 호출 → 첫 이미지 다운로드 후
  카드 안 광고 자리에 채워준다. `img_link` 있으면 탭으로 외부 브라우저 열기.
  - 별도 클래스 `OverlayAdLoader` — 백그라운드 스레드에서 fetch/decode, UI 스레드에서 attach
    여부 확인 후 표시. 실패 시 조용히 숨김.
  - mock 모드에서는 광고 호출 skip.
  - 이미지 크기 안전장치(최대 ~2 MB) 적용.
- **FGS 상태바 아이콘** `ic_guard_shield_status` — 방패 outline + 안쪽에 'G' 글자.
  상태바 monochrome 마스크에서도 또렷이 보이게 stroke + fill 조합.

### Changed
- **앱 이름이 '경남 안심링크' 로 확정.** 단일 source-of-truth = `@string/app_name`.
  - `AndroidManifest.application@android:label` → `@string/app_name`
  - `lib/main.dart` `MaterialApp.title`, `guard_status_page.dart` AppBar title 모두 갱신
  - FGS notification title/text 도 strings 로 분리해 일관 노출
- **FGS notification 아이콘** = 새 방패+G vector 로 교체 (이전: `android.R.drawable.ic_dialog_info`).

### Known issues (0.2.0)
- 0.1.2~0.1.9 항목 동일
- 광고 이미지가 큰 경우 첫 노출까지 1~2초 지연될 수 있음 (저성능 단말).

---

## [0.1.9] — 2026-05-26 (브라우저: 탭 닫기 후 같은 URL 알림 회귀 fix)

**앱 버전:** `0.1.9+9` · **브랜치:** `v0.1.2`

### Fixed
- **탭 닫고 책갈피·히스토리에서 같은 URL 다시 열어도 알림이 안 뜨던 회귀 (0.1.8)**
  - 원인 1: `detectVisitChange` 가 사용하던 `readCommittedUrlFromBar` 는 `looksLikeCommittedBrowsingUrl`
    검증을 통과한 URL 만 반환. brave/whale 등의 새 탭 페이지(`brave://newtab/`, `chrome://newtab/`)
    가 검증을 통과 못 해 null → visit 이 안 바뀐 채로 유지 → 같은 URL 다시 열어도 skip
  - 원인 2: 일부 브라우저는 탭 닫기 직후 URL bar 노드를 잠시 detach → raw text 자체가 안 읽힘
- 수정:
  1. `readVisitKeyFromBar()` 분리 — visit 비교용으로는 internal URL 도 키로 인정 (raw 텍스트
     소문자 본을 fallback). `readCommittedUrlFromBar` 는 실제 검사 발사용으로 엄격함 유지.
  2. URL bar 가 **1.5초 이상** 안 읽히면 visit 정보 자동 만료. 메뉴 열기(1초 미만)는 흡수.

### Known issues (0.1.9)
- 0.1.2~0.1.8 항목 동일
- 사용자가 한 페이지에서 메뉴/검색 입력을 1.5초 이상 머문 뒤 같은 페이지로 돌아오면 같은
  URL 알림이 다시 1회 뜰 수 있음 (의도된 trade-off)

---

## [0.1.8] — 2026-05-26 (브라우저: 외부 체류 시간 기반 visit 만료)

**앱 버전:** `0.1.8+8` · **브랜치:** `v0.1.2`

### Fixed
- **브라우저를 종료했다가 다시 실행해 마지막 페이지가 복원될 때 알림이 안 뜨던 문제**
  - 원인: 우리 앱은 FGS 로 계속 살아있어 `BrowserAccessibilityService` 인스턴스가
    유지됨 → 브라우저만 재실행해도 `currentVisitKey` / `firedInCurrentVisit` 가 그대로
    남아 같은 URL 이 skip 됐음
  - 브라우저 외 패키지로 이동한 직후 `scheduleVisitClear()` 로 **1.5초 후 visit 정보를
    클리어**하도록 예약. 브라우저로 다시 돌아오면 `cancelVisitClear()` 가 예약을 취소.
  - 시스템 UI/IME/메뉴 깜빡임(보통 200~500ms)은 1.5초 미만이라 visit 정보 유지 →
    같은 페이지에서 발생하는 노이즈 알림은 그대로 차단
  - 진짜로 브라우저를 종료·다른 앱으로 이동 후 1.5초 이상 머무른 뒤 복귀하면 같은
    URL 도 새 visit 으로 인정 → 알림 1회

### Known issues (0.1.8)
- 다른 앱을 1.5초 이상 보고 브라우저로 돌아오면 **같은 페이지에서도 알림이 다시 1회 뜸**
  (의도된 동작 — 사용자가 잠깐 떠났다 돌아온 경우에도 다시 한 번 경고). 만약 너무
  자주 뜨면 임계값을 늘리거나 정책을 조정한다.
- 0.1.2~0.1.7 항목 동일

---

## [0.1.7] — 2026-05-26 (브라우저: 「현재 visit 1회」 정책)

**앱 버전:** `0.1.7+7` · **브랜치:** `v0.1.2`

### Changed
- **브라우저 알림 정책 재설계 — 「현재 보고 있는 페이지(visit) 안에서만 1회」**
  - 0.1.6 의 process-level `firedUrlKeys` 영구 set 은 **탭 닫고 같은 URL 다시 열기** 도
    차단해버려 사용자 의도에 어긋났음. 이번에 visit 추적 방식으로 교체.
  - URL bar 의 canonical key 변화를 매 접근성 이벤트에서 감지(`detectVisitChange`).
    같은 URL 이라도 그 사이 다른 URL(`about:blank`, 새 탭, 다른 페이지 등) 을
    한 번이라도 경유했다면 새 visit 으로 인정 → `firedInCurrentVisit = false` →
    같은 URL 도 다시 1회 알림 가능.
  - 같은 visit 안에서는 typing/nav 두 분기, 메뉴·허공 터치, 캐시 hit 경로 모두 차단.

### Fixed
- **0.1.6 부작용**: 탭 닫고 같은 스미싱 주소를 다시 열어도 알림이 안 뜨던 문제

### Known issues (0.1.7)
- 0.1.2~0.1.6 항목 동일
- 일부 브라우저에서 메뉴 UI 가 URL bar 를 일시적으로 다른 텍스트로 덮어쓰면 visit 이
  깜빡 변경된 것처럼 보일 수 있음. `readCommittedUrlFromBar` 의 `looksLikeCommittedBrowsingUrl`
  검증과 600ms 캐시로 대부분 흡수되지만, 특정 환경에서 1회 추가 알림이 발생하면 알려주세요.

---

## [0.1.6] — 2026-05-26 (브라우저: 탭 닫기 후 재발사 차단)

**앱 버전:** `0.1.6+6` · **브랜치:** `v0.1.2`

### Fixed
- **브라우저 탭을 닫으면 같은 URL 알림이 다시 뜨던 문제**
  - 원인: 탭 닫기 시 시스템 UI(`com.android.systemui`) / 런처 / IME 가 잠깐
    활성화되면서 `pkg !in BrowserPackages.all` 분기가 발생 → `resetSession("left_browser")`
    가 호출 → `firedUrlKeys` 가 비워짐 → 브라우저로 복귀하면서 같은 URL 재발사
  - `firedUrlKeys` 를 인스턴스 변수에서 **process-level 의 ConcurrentHashMap-backed set**
    으로 이동 — 시스템 UI / 런처 잠깐 활성화에 영향받지 않음
  - `resetSession` 에서 `firedUrlKeys` 클리어 제거 (lastAlertedUrl / 캐시 / 타이머만 클리어)
  - 명시적으로 비우는 시점은 보호 OFF→ON 토글(`NativeBridgePlugin.startProtection`) +
    앱 프로세스 재시작뿐

### Known issues (0.1.6)
- 보호 OFF→ON 토글 또는 앱 강제 종료 후 재실행 시 같은 URL 도 다시 1회 검사·알림 (의도)
- 0.1.2~0.1.5 항목 동일

---

## [0.1.5] — 2026-05-26 (브라우저: URL 1회 정책)

**앱 버전:** `0.1.5+5` · **브랜치:** `v0.1.2`

### Changed
- **브라우저 검사 정책 — 「한 세션 동안 같은 URL은 단 1회 검사·알림」** 로 단순화
  - `BrowserAccessibilityService` 가 검사를 발사한 URL canonical key 를 `firedUrlKeys` set 에 기록
  - 같은 페이지에서 typing 분기(URL 입력 흐름)와 nav 분기(콘텐츠 로드 흐름)가 동시에 발사돼
    페이지 진입 시 알림이 2회 뜨던 현상 해소
  - 알림이 뜬 후 메뉴/스크롤/허공 터치로 발생하는 모든 재검사 요청 차단 — 응답 도착 전/후, 캐시
    hit/miss, 오버레이 권한 유무와 무관하게 같은 URL 은 발사 자체가 금지됨
  - 브라우저 외 패키지로 이동(`resetSession`)하면 set 이 비워져, 새 세션에서는 다시 1회 검사

### Known issues (0.1.5)
- 같은 브라우저 세션 안에서 같은 URL 을 reload 해도 이 정책상 재검사하지 않는다 (의도된 단순화).
  새 검사가 필요하면 다른 앱으로 잠시 나갔다 돌아오거나, 다른 URL 을 한 번 거치면 된다.
- 0.1.2~0.1.4 항목 동일

---

## [0.1.4] — 2026-05-26 (브라우저 알림 반복 버그 fix)

**앱 버전:** `0.1.4+4` · **브랜치:** `v0.1.2`

### Fixed
- **브라우저: 페이지 이동 없이 메뉴/레이아웃/허공 터치만으로 탐지 알림이 반복**되던 결정적 버그
  - `markPageAlerted`가 진행 중이던 nav-retry / typing-verify 타이머를 취소하지 않아,
    알림이 뜬 뒤에도 7회 retry 타이머가 같은 URL로 `fireCheck`를 계속 호출 → `UriCheckCache`
    hit으로 오버레이가 폭주하던 경로 차단 (`cancelNav()` + `cancelTyping()` 추가)
  - `fireCheck` 직전 `lastAlertedUrl == 현재 URL` 가드 추가 — 어떤 경로로든 같은 페이지 재검사 금지
  - `UriCheckBridge.deliverResult`(캐시 hit 분기 포함)에서 `BrowserAccessibilityService.isAlreadyAlertedFor`
    체크로 오버레이 재표시 차단
  - 접근성 이벤트 디바운스(`EVENT_MIN_INTERVAL_MS = 350ms`)를 `lastAlertedUrl` 유무와 무관하게
    항상 적용 — 첫 알림 직전 이벤트 폭주 방지

### Known issues (0.1.4)
- 0.1.2~0.1.3 항목 동일 (서버 등록 URL 일치, Mock OFF 통합 테스트, 법률 자문 권장)
- 브라우저에서 알림 띄운 후 **다른 페이지로 이동**해야 같은 URL이 다시 검사된다 (의도된 동작)

---

## [0.1.3] — 2026-05-26 (사용자 경험 · 안내·진동·랜덤 멘트·보안 보관소)

**앱 버전:** `0.1.3+3` · **브랜치:** `v0.1.2`

### Added
- **오탐·면책 안내 페이지** (`LegalNoticePage`) — 7개 섹션 (탐지 성격·오탐·미탐·차단 범위·면책·데이터 처리·신고)
  - 메인 화면 하단에 작은 「오탐·면책 안내 보기」 텍스트 버튼
  - 설정 페이지 하단에 「오탐·면책 안내」 진입 ListTile
- **스미싱 탐지 시 진동 1회** (`DetectionVibrator`)
  - 약 60ms 짧은 펄스, 무음 환경에서도 인지 가능
  - 설정 「스미싱 탐지 시 진동」 토글로 OFF 가능 (기본 ON)
  - 오버레이 표시 시 + 오버레이 권한 없어 시스템 알림 폴백 시 모두 동작
  - `VIBRATE` 권한 추가 (런타임 요청 불필요)
- **탐지 멘트 100문장** (`DetectionQuips`) — 매 탐지마다 랜덤 1줄을 카드 하단에 표시
  - 직설적 경고 / 사회공학 인식 / 행동 지침 / 금융 보호 / 가족 안전 / 자기진단 등 10개 그룹
  - 연속 동일 멘트 방지, 각 28자 이내, 이모지 없음
- **flutter_secure_storage 9.2.2** 재도입 — userid 보안 보관소(`SecureUserIdStore`)
  - Android Keystore 기반 `encryptedSharedPreferences` 옵션
  - 기존 평문 prefs에서 자동 마이그레이션 (1회)
  - 네이티브 호환을 위해 `FlutterSharedPreferences`에도 동일 값 유지

### Changed
- **설정 — userid 표시 정책**: Mock 모드일 때만 원본 노출, 운영 모드는 마스킹(`ab****yz`)
- 설정에 「스미싱 탐지 시 진동」 SwitchListTile
- 오버레이 카드 하단에 랜덤 멘트 자리(`overlay_quip`) 추가
- 광고 캐러셀: 이미지 없거나 로드 전이면 LinearProgressIndicator를 표시하지 않고 완전히 숨김 — UI 깜빡임 제거

### Fixed
- 광고가 비어 있을 때 잠시 보이던 4dp 프로그레스 바 깜빡임

### Build
- R8(release) 빌드: Google Tink 가 참조하는 컴파일 타임 어노테이션(errorprone, javax.annotation)을
  R8 이 찾지 못해 실패하던 문제 해결 — `android/app/proguard-rules.pro` 추가 + `app/build.gradle`
  release 빌드에 `proguardFiles` 연결

### Known issues (0.1.3)
- 0.1.2 항목과 동일 (Whale 터치 재경고, 서버 등록 URL 일치 필요, Mock OFF 통합 테스트 등)
- 오탐·면책 안내 문구는 일반적인 안티스미싱 서비스 약관을 참고한 초안 — 정식 배포 전 법률 자문으로 운영사 명의 약관·개인정보처리방침 교체 필요

---

## [0.1.2] — 2026-05-23 (통합 테스트 · 안정화)

**앱 버전:** `0.1.2+2` · **브랜치:** `v0.1.2`

### Added
- 서버 응답 `code` 정규화 (`0001` / `1` / 숫자형) — `ApiResultCodes`
- URI 검사 메모리 캐시 (`UriCheckCache`) · 보호 켤 때 캐시 초기화
- 보호 ON/OFF 연동 (`ProtectionPrefs`) — 꺼지면 검사·inbox 관찰 중단
- 알림 본문 4초 중복 스로틀 (`ScanThrottle`)
- 카카오/텔레그램 **MessagingStyle** 알림 본문 파싱 (`android.messages`)
- 오버레이 불가 시 **시스템 알림** 폴백 (`DetectionAlertNotifier`)
- 네이티브 탐지 이벤트 **pending 큐** (Flutter 미기동 시 타임라인 복구)
- 설정: **스미싱 테스트 링크 검사** (앱 내부 파이프라인 확인)
- 부팅 직후 `NativeBridge` 이벤트 수신 시작
- `CHANGELOG.md`, `VERSIONING.md` 문서

### Fixed
- **탐지 전면 중단:** userid 없음 + Mock OFF 시 API 스킵 → `testsafebrowsing` 등 로컬 테스트 URL 예외
- **SMS:** URL 없는 알림 미리보기가 먼저 오면 본문 SMS 검사가 3초간 막히던 문제 → URL 기준 dedup
- **서버 0001인데 알림 없음:** Mock ON이면 humoruniv 등 서버 미호출 · API `code` 파싱 실패 · 캐시된 `0000` · userid/보호 OFF
- **쿼리스트링 제거** 실험 후 **원복** (API에 전체 URL 전송)
- **브라우저:** 터치만으로 알림 반복 (Whale) — `lastNavigation` 조기 잠금·`WINDOW_STATE` 리셋·이벤트 과다
- **브라우저:** 늦게 도착한 검사로 **옛 URL** 오버레이 → 검사 토큰·canonical URL 비교
- **브라우저:** 26초 후 오버레이 자동 닫힘 → 메시지 알림과 동일 **sticky** 유지
- **오버레이:** 과거 알림 문구가 뜨던 문제 → 브라우저는 메시지 스타일 카드·최신 URL/시각
- **타임라인:** 메시지 상세에 서버 안내 문구 제거 (UX)

### Changed
- 브라우저 경고 UI를 메시지 알림과 **동일 카드 레이아웃** (본문 미리보기 없음)
- 브라우저 문구: `주의! 방문 중인 페이지는 스미싱 의심 URL 입니다.`
- 접근성 이벤트 축소·`notificationTimeout` 500ms (배터리)
- 브라우저: **알림 표시한 URL**만 터치 이벤트 무시 (재검사는 캐시/TTL)
- HTTP 타임아웃 8s → 5s · SMS inbox debounce 900ms
- 보호 토글 시 prefs → 네이티브 순서 정리

### Known issues (0.1.2)
- Whale 등 일부 브라우저: 같은 페이지에서 터치 시 알림이 가끔 반복될 수 있음 (이벤트 특성)
- 서버 등록 URL과 앱이 보내는 URL(스킴·경로)이 다르면 `0000` 처리됨 — **등록 URL과 동일**하게 맞출 것
- Mock 모드 ON이면 **서버 `/check_uri`를 호출하지 않음** (통합 테스트 시 OFF 필수)
- iOS 미구현 (Android 전용 프로토타입)
- Play Protect 오탐 가능 (README 설치 가이드 참고)

---

## [0.1.1] — 2025-05 (기능 보강)

**버전:** PATCH 누적 → 릴리스 라인 정리 시 `0.1.1`

### Added
- 패키지 ID `com.dhn.smishing` (기존 `com.dohwi.smishing`에서 변경)
- 타임라인 **초 단위** 표시 · 항목 `entryId` (동일 분·동일 URL도 별도 기록)
- 메시지 **상세 보기** 바텀시트 (본문·URL·복사)
- 메인·타임라인 **광고 배너** 매 방문 reload (`RouteAware`)
- 권한 상태 행 (문자·알림 접근·오버레이·접근성·배터리 권장)
- SMS 권한 행 · 배터리 최적화는 **선택** (필수 아님)
- 텔레그램·LINE 알림 패키지 허용
- 오버레이 **메시지 스타일** (카톡/문자 유사 카드, 탐지 시각, 타임라인 이동)
- `stripQueryForApi` (이후 0.1.2에서 **제거·원복**)

### Fixed
- 타임라인에서 동일 URL·동일 분 **하나로 합쳐지던** 문제
- 오버레이 UI 테스트 시 **과거 알림** 내용이 섞이던 문제 (표시 컨텍스트 분리)
- 메시지 상세 SnackBar가 시트 뒤에 가려지던 문제 → 인시트 배너

### Changed
- 메인 보호 설명 문구 단순화 · 큰 글꼴 대응 스크롤

---

## [0.1.0] — 2025-05 (초기 Android 프로토타입)

**앱 버전:** `0.1.0+1` · **커밋:** `6f77009` 초기 소스

### Added
- Flutter 3.19.6 + Android Kotlin 네이티브 연동
- 서버 v1: `POST /set_userid`, `/check_uri`, `/get_ad_img` (기본 `http://210.127.253.95:3098`)
- **문자** `SMS_RECEIVED` + inbox `ContentObserver` 보완
- **알림 리스너:** 카카오톡·문자 앱·텔레그램(패키지) 등
- **접근성:** Chrome/Whale/Samsung Browser 등 주소창 URL 검사
- **다른 앱 위에 표시** 경고 오버레이 · FGS 보호 토글
- URL 추출: 한글 사이·줄바꿈·스킴 없는 도메인·IPv4 (`UrlNormalizer` / `UrlExtractor`)
- Mock 모드 · 설정(서버 URL·userid) · 타임라인(30일·200건)
- Google `testsafebrowsing.appspot.com` Mock/로컬 위험 처리

### Known issues (초기)
- iOS 미지원
- 카톡 알림 본문이 `EXTRA_TEXT`만으로는 비는 경우多 → 0.1.2에서 MessagingStyle 대응

---

## 삭제·미사용

| 항목 | 버전 | 비고 |
|------|------|------|
| `flutter_secure_storage` | 0.1.0 | D8/AGP 충돌로 제거 |
| `overlay_warning.xml` (구 브라우저 배너) | 0.1.2 | 메시지 카드 레이아웃으로 통합 |
| API 쿼리스트링 제거 (`stripQueryForApi`) | 0.1.1 추가 → **0.1.2 원복** |

---

## 버전·브랜치 대응

| App `pubspec` | Git 브랜치 | 상태 |
|---------------|------------|------|
| 0.1.0+1 | `main` (초기 커밋) | 기준선 |
| 0.1.2+2 | `v0.1.2` | 통합 테스트 진행 |
| 0.1.3+3 | `v0.1.2` | UX·안내·진동·멘트·보안 보관소 |
| 0.1.4+4 | `v0.1.2` | 브라우저 알림 반복 버그 1차 fix |
| 0.1.5+5 | `v0.1.2` | 브라우저: URL 1회 정책 단순화 |
| 0.1.6+6 | `v0.1.2` | 탭 닫기 후 재발사 차단 (process-level) |
| 0.1.7+7 | `v0.1.2` | 「현재 visit 1회」 정책 |
| 0.1.8+8 | `v0.1.2` | 외부 체류 1.5초+ 시 visit 만료 |
| **0.1.9+9** | `v0.1.2` | **현재 — 탭 닫기 후 회귀 fix (internal URL visit 인식)** |
| (예정) 0.1.9+9 | `main` | 통합 테스트 완료 후 머지 |
