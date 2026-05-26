# Smishing Guard

**앱 버전:** `0.1.6+6` (개발 브랜치 `v0.1.2`) · **이력:** [CHANGELOG.md](CHANGELOG.md) · **브랜치/버전 규칙:** [VERSIONING.md](VERSIONING.md)

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

| 기능 | 메서드·경로 | 헤더 | 비고 |
|------|-------------|------|------|
| userid 발행 | `POST /set_userid` | `android_id` | 최초 1회, 로컬 저장 |
| URI 검사 | `POST /check_uri` | `userid` + JSON `{"uri":"..."}` | `0000` 안전 · `0001` 스미싱 주의 |
| 광고 배너 | `POST /get_ad_img` | `userid` | JSON 배열 `[{ "img_url", "img_link" }, ...]` — 5초 간격 슬라이드, 탭 시 `img_link` 이동 |

**기동 흐름:** 로딩 → `set_userid` 실패 시 「현재 서비스 이용이 불가능 합니다.」 후 종료 → 메인.

**타임라인:** 스미싱 주의(`0001`)만 로컬 저장, **최대 30일 · 200건**.

설정에서 **Mock 모드**를 켜면 서버 없이 테스트 가능 (`phish`, `evil`, `fake`, `scam` 등 URL은 주의 처리).

**통합 테스트 시:** Mock **OFF** · 메인 **보호 켜기** · 서버 등록 URL과 앱이 보내는 URL 일치 확인.

## 변경 이력 요약

| 버전 | 요약 |
|------|------|
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
