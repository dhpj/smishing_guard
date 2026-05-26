# Changelog

형식: [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/) · 버전: [Semantic Versioning](https://semver.org/lang/ko/) (`MAJOR.MINOR.PATCH`)

| 구분 | 버전 올리는 기준 | 예 |
|------|------------------|-----|
| **PATCH** | 버그 수정, 동작 회귀 복구 | `0.1.2 → 0.1.3` |
| **MINOR** | 기능 추가 (하위 호환) | `0.1.x → 0.2.0` |
| **MAJOR** | 호환 깨짐·대규모 구조 변경 | `0.x → 1.0.0` |

**Git 브랜치:** 통합 테스트는 `v0.1.2` · 안정 반영 후 `main` 머지 ([VERSIONING.md](VERSIONING.md))

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
- 서버 v1: `POST /set_userid`, `/check_uri`, `/get_ad_img` (기본 `http://210.114.225.58:8087`)
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
