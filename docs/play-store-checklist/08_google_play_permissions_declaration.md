# Google Play 심사 대응 — 권한·백그라운드·데이터 접근 명세

**앱:** 경남 안심링크 (`com.dhn.smishing`) · **버전:** 0.4.15+33  
**작성 목적:** SMS·알림·접근성 등 민감 권한에 대한 심사·반려 대응  
**코드 기준일:** 2026-07-08

---

## 요약 (심사 담당자용 30초)

| 질문 | 답 |
|------|-----|
| Default SMS 앱인가? | **아니오** |
| 보호 OFF일 때 SMS를 읽나? | **아니오** (모든 검사 경로가 `protection_enabled` 확인 후 중단) |
| 문자 전체를 서버에내나? | **아니오** — URL만 서버 전송 |
| 회원가입·로그인? | **없음** |
| 백그라운드 동작 조건 | 사용자가 메인 화면에서 **「보호 켜기」** 한 경우에만 |

---

## 1. SMS 권한 — 구체적으로 어떻게 동작하나?

### 1.1 선언·요청 권한 (Manifest + 런타임)

| Android 권한 | 선언 위치 | 런타임 요청 | 앱 내 표기명 |
|--------------|-----------|-------------|--------------|
| `RECEIVE_SMS` | AndroidManifest | O (`Permission.sms`) | SMS 수신·읽기 |
| `READ_SMS` | AndroidManifest | O (동일 그룹) | SMS 수신·읽기 |

코드상 `sms` 권한은 **RECEIVE_SMS + READ_SMS 둘 다 허용**되어야 `true`입니다.  
(`PermissionHelper.runtimeStatus` · `PermissionHelper.kt`)

### 1.2 언제 SMS에 접근하나? (보호 켜기 연동)

**전제:** `SharedPreferences` 키 `protection_enabled == true` 이고, 보호 일시 중지(snooze)가 아닐 때만 동작합니다.  
(`ProtectionPrefs.isActive()` · `SmsReceiver.kt` 12행 · `SmsInboxObserver.kt` 30·104행)

| 보호 상태 | SMS 접근 |
|-----------|----------|
| 보호 **OFF** | `SmsReceiver` 즉시 return · inbox 검사 안 함 |
| 보호 **ON** | 아래 두 경로 동작 |
| 보호 **일시 중지** | OFF와 동일 (snooze 시 `isActive` = false) |

### 1.3 SMS 접근 경로 2가지

#### 경로 A — `SmsReceiver` (실시간 수신)

- **트리거:** 시스템 브로드캐스트 `android.provider.Telephony.SMS_RECEIVED`
- **읽는 데이터:** 수신 직후 Intent에 담긴 **해당 메시지 본문** (`messageBody` 합침)
- **처리:** `UrlNormalizer.extractAllFromText()` 로 **URL만 추출** → 서버 `/check_uri` · 위험 시 경고 UI
- **서버 전송:** URL 문자열만 (본문 전체 미전송)
- **백그라운드:** 예 — BroadcastReceiver는 앱이 백그라운드여도 수신 가능 (보호 ON일 때만)

#### 경로 B — `SmsInboxObserver` (수신 누락 보완)

- **목적:** RCS·일부 단말에서 `SMS_RECEIVED`가 누락·지연될 때 inbox 변경 감지
- **트리거:** `Telephony.Sms.CONTENT_URI` ContentObserver (보호 ON 시 `startProtection`에서 등록)
- **읽는 데이터:** inbox에서 **가장 최근 1건**만 조회 — 컬럼 `_ID`, `BODY` (`SmsInboxObserver.newestInboxRow`)
- **처리:** 이전에 처리한 ID보다 큰 새 메시지만 · URL 추출 후 경로 A와 동일
- **READ_SMS 필요 이유:** inbox Provider 쿼리에 필요 (권한 없으면 SecurityException)

> **중요:** 과거 문자함 전체를 스캔·업로드하지 않습니다. 커서는 **마지막 처리 ID**만 저장하고, **신규 1건**만 확인합니다.

### 1.4 사용자 제어

| 방법 | 효과 |
|------|------|
| 메인 「보호 끄기」 | SMS 수신·inbox 검사 **즉시 중단**, FGS 종료, inbox observer 해제 |
| 설정 → 보호 일시 중지 | 동일하게 검사 중단 (스위치는 ON 유지) |
| Android 설정 → 앱 → 권한 → SMS 거부 | 수신·읽기 불가 (보호 ON이어도 SMS 경로 비활성) |
| 앱 삭제 | 모든 접근 종료 |

---

## 2. 보호 켜기 시 필수 권한·설정 (5종)

`PermissionHelper.fullStatus()` 의 `allReady`는 아래 **5개가 모두 true**여야 합니다.  
메인 화면 「보호 켜기」 전 `runSetupWizard`로 안내합니다.

| # | 키 | 사용자에게 보이는 이름 | Android/API | 필수 여부 | 보호 OFF 시 |
|---|-----|------------------------|-------------|-----------|-------------|
| 1 | `sms` | SMS 수신·읽기 | RECEIVE_SMS + READ_SMS | **필수** | 코드상 미처리 |
| 2 | `postNotifications` | 앱 알림 (Android 13+) | POST_NOTIFICATIONS | **필수** | FGS 알림만 해당 시 |
| 3 | `overlay` | 다른 앱 위에 표시 | SYSTEM_ALERT_WINDOW | **필수** | 경고 창 미표시 |
| 4 | `notificationListener` | 알림 접근 | NotificationListenerService | **필수** | 코드상 미처리* |
| 5 | `accessibility` | 접근성 (브라우저) | AccessibilityService | **필수** | 코드상 미처리* |

\* OS 설정은 켜져 있을 수 있으나, `ProtectionPrefs.isActive()` 가 false면 **알림·접근성 핸들러 모두 즉시 return** 합니다.

### 2.1 권장 (필수 아님)

| 키 | 이름 | 목적 |
|----|------|------|
| `batteryOptimization` | 배터리 최적화 제외 | 일부 기기에서 백그라운드 FGS·리시버 유지. **없어도 앱 동작** (`requiredForProtection: false`) |

---

## 3. 권한별 — 왜 필요한지 · 무엇을 읽나 · 서버 전송

### 3.1 SMS (RECEIVE_SMS + READ_SMS)

| 항목 | 내용 |
|------|------|
| **왜 필요** | 문자에 포함된 스미싱 URL을 탐지 (핵심 기능) |
| **읽는 범위** | 수신 문자 본문 / inbox 최신 1건 본문 |
| **저장** | 서버 미저장 · 로컬은 URL 검사 결과·경고 UI용 본문 일부만 |
| **서버 전송** | 추출된 **URL만** |
| **Default SMS** | **해당 없음** |

### 3.2 알림 접근 (Notification Listener)

| 항목 | 내용 |
|------|------|
| **왜 필요** | 카카오톡·텔레그램·LINE 등 **메신저 API 없이** 알림에 노출된 링크 검사 |
| **대상 패키지** | 카카오톡, 텔레그램, LINE, WhatsApp, 일부 SMS 앱 알림 등 (화이트리스트) |
| **읽는 범위** | 알림 `title` + `EXTRA_TEXT` 등에서 URL 추출용 텍스트 |
| **서버 전송** | URL만 |
| **미전송** | 대화 전체·연락처 |

### 3.3 접근성 (Accessibility)

| 항목 | 내용 |
|------|------|
| **왜 필요** | 브라우저 **주소창 URL**만 읽어 현재 방문 페이지 검사 |
| **설정** | `accessibility_service_config.xml` — `typeWindowContentChanged` 등, **브라우저 패키지 한정 처리** (`BrowserAccessibilityService`) |
| **미수집** | 페이지 본문·입력 필드·비밀번호 |
| **서버 전송** | URL만 |
| **시스템 설명문** | `브라우저 주소창 URL을 검사해 스미싱 위험을 경고합니다. 탐색은 차단하지 않습니다.` |

### 3.4 다른 앱 위에 표시 (Overlay)

| 항목 | 내용 |
|------|------|
| **왜 필요** | 메신저·브라우저 사용 중 위험 링크 **즉시 경고** |
| **데이터** | UI 표시만 · 추가 수집 없음 |

### 3.5 앱 알림 (POST_NOTIFICATIONS)

| 항목 | 내용 |
|------|------|
| **왜 필요** | 보호 실행 중 **Foreground Service** 상시 알림 + 탐지 알림(오버레이 불가 시) |

### 3.6 Foreground Service (백그라운드)

| 항목 | 내용 |
|------|------|
| **시작 조건** | 사용자 「보호 켜기」 → `startProtection()` |
| **종료 조건** | 「보호 끄기」 → `stopProtection()` |
| **타입** | `foregroundServiceType="dataSync"` (Manifest) |
| **알림** | 「URL 보호 실행 중」 — 사용자에게 백그라운드 동작 **가시적 표시** |
| **목적** | OS가 앱 프로세스를 과도하게 종료하지 않도록 · SMS/알림 리스너 유지 보조 |

### 3.7 배터리 최적화 제외 (권장)

| 항목 | 내용 |
|------|------|
| **선언** | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` |
| **필수** | **아니오** — 미설정 시 일부 기기에서 검사 지연 가능 |

---

## 4. Play Console 제출용 문구 (영문)

### SMS Permissions Declaration

```
This app is NOT the default SMS handler.

SMS permissions (RECEIVE_SMS, READ_SMS) are used only when the user 
explicitly enables "Protection" in the app. When Protection is OFF, 
no SMS is read or processed.

RECEIVE_SMS: Detect incoming SMS in real time and extract URLs for 
smishing/phishing risk checking.

READ_SMS: Fallback only — when the SMS_RECEIVED broadcast is missed 
on some devices (RCS/delay), observe the SMS inbox for the single 
newest message and extract URLs. We do not scan or upload the full 
SMS history.

Only extracted URL strings are sent to our server for security 
analysis. Full SMS message bodies are NOT uploaded. Message previews 
shown in warnings are processed on-device only.

Users can disable Protection at any time or revoke SMS permission 
in Android Settings.
```

### Notification Listener

```
Used to read notification text from messaging apps (KakaoTalk, 
Telegram, LINE, etc.) to extract URLs for smishing detection. 
Only whitelisted messaging packages are processed. Full conversations 
are not uploaded; only URLs are sent to the server for checking.
```

### Accessibility Service

```
Used solely to read the browser address bar URL in supported browsers 
(Chrome, Samsung Internet, Firefox, etc.) to check the currently 
visited page for smishing risk. Page content, form fields, and 
passwords are not collected. Navigation is not blocked.
```

### Background / Foreground Service

```
A foreground service runs only while the user has enabled Protection, 
displaying a persistent "URL protection active" notification. 
Background SMS and notification monitoring occur only during active 
Protection and only for URL extraction and user warnings.
```

---

## 5. 스토어 설명·심사 대응 시 주의 (현재 문구 점검)

### ✅ 사실과 일치하게 쓸 것

- 「보호를 **켠 경우에만**」 SMS·알림·브라우저 검사
- 「문자 **전체가 아닌 URL만** 서버 전송」
- 「Default SMS 앱 **아님**」
- 「경고만 제공 · **강제 차단 없음**」

### ⚠️ 심사에서 걸릴 수 있는 표현 (피하거나 수정)

| 표현 | 이유 |
|------|------|
| 「실시간 **차단**」 | 실제로는 차단하지 않고 경고만 표시 |
| 「항상 모든 문자 접근」 | 보호 OFF·권한 거부 시 미접근 — **조건부**로 명시 |
| 「백그라운드 상시 감시」 (무분별) | FGS 알림 + 보호 ON 조건을 함께 기술 |

배너 문구는 이미 「검사 · 즉시 경고」로 수정됨 (`feature_graphic.svg`).

---

## 6. Data safety 폼 (Google Play) — 권장 답변 방향

| 데이터 | 수집 | 공유(서버) | 목적 | 선택/필수 |
|--------|------|------------|------|-----------|
| Device ID (ANDROID_ID) | 예 | 예 | userid 발급 | 필수(서비스) |
| App activity (URL) | 예 | 예 | 스미싱 판정 | 필수(서비스) |
| SMS / Messages | 예(단말) | **아니오**(본문) | URL 추출만 | 사용자가 보호 ON + SMS 권한 허용 시 |
| Notifications | 예(단말) | **아니오**(본문) | URL 추출만 | 사용자가 알림 접근 허용 시 |

---

## 7. 코드 근거 파일

| 기능 | 파일 |
|------|------|
| Manifest 권한 | `android/app/src/main/AndroidManifest.xml` |
| 필수 5종 · allReady | `PermissionHelper.kt` |
| 보호 ON/OFF 게이트 | `ProtectionPrefs.kt` |
| SMS 수신 | `SmsReceiver.kt` |
| SMS inbox 보완 | `SmsInboxObserver.kt` |
| FGS 시작/종료 | `NativeBridgePlugin.kt` (`startProtection` / `stopProtection`) |
| 메신저 알림 | `MessageNotificationListener.kt` |
| 브라우저 URL | `BrowserAccessibilityService.kt` |
| URL만 서버 전송 | `UriCheckBridge.kt` · `UrlNormalizer.kt` |
| UI 권한 안내 | `permission_rationale.dart` · `permission_service.dart` |

---

## 8. 등록 담당자 전달 한 줄

> **경남 안심링크는 Default SMS 앱이 아니며, 사용자가 「보호 켜기」를 활성화한 경우에만 SMS·메신저 알림·브라우저 주소창에서 URL을 추출해 스미싱 여부를 검사합니다. 문자·대화 본문은 서버에 올리지 않고 URL만 전송하며, 보호를 끄거나 SMS 권한을 철회하면 즉시 중단됩니다.**
