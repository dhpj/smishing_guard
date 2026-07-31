# SMS 권한 — Play 반려 대응 (Anti-SMS Phishing 예외)

> **✅ 0.4.22 적용:** Plan B 채택 — `RECEIVE_SMS`/`READ_SMS` 제거, 문자 URL은 **알림 접근**만 사용.  
> Play Console **SMS Permissions Declaration Form 제출 불필요**. 아래 Plan A 내용은 참고용 보관.

**앱:** 경남 안심링크 `com.dhn.smishing`  
**반려 키워드:** SMS 피싱 방지 사용 사례 기준 미충족 · SMS/통화 기록 정책 선언  
**정책:** [Use of SMS or Call Log permission groups](https://support.google.com/googleplay/android-developer/answer/10208820)

---

## 1. 반려가 의미하는 것 (코드만으로는 통과 불가)

Google은 `RECEIVE_SMS` · `READ_SMS` 를 **기본 문자 앱(Default SMS handler)이 아닌 앱**에 허용할 때 **예외(use case)** 로만 승인합니다.

경남 안심링크는 **「Anti-SMS phishing (smishing)」** 예외에 해당하지만, 정책상 아래를 **반드시 제출**해야 합니다.

> **You must have a track record of significant protection for users** — as reflected in **analyst reports, benchmark test results, industry publications**, and other credible sources of information.

즉, 앱 설명·앱 내 고지만으로는 부족하고, **Play Console → Permissions Declaration Form(권한 선언 양식)** 에 **신뢰할 수 있는 실적·근거 자료**를 첨부해야 합니다.

---

## 2. Play Console에서 할 일 (순서)

1. **Play Console** → 해당 앱 → **앱 콘텐츠** (또는 **정책** / **민감한 앱 권한**)
2. **SMS 및 통화 기록 권한** / **Permissions Declaration Form** 열기
3. **Use case:** `Anti-SMS phishing` / `Smishing protection` 선택
4. 아래 **영문 설명** 붙여넣기 (섹션 4)
5. **첨부·링크**에 섹션 3 증빙 자료 업로드
6. **Core functionality** 가 스토어 설명·스크린샷·동영상과 일치하는지 재확인
7. 저장 후 **새 AAB** 와 함께 재심사 요청

양식이 보이지 않으면: **정책 상태** 메일의 「세부정보 수정」 링크 또는 Play Console **고객센터 → 정책 문제** 에서 동일 양식으로 유도됩니다.

---

## 3. 제출용 증빙 자료 체크리스트 (최소 2~3종 권장)

아래 중 **실제로 확보 가능한 것**을 PDF/URL로 제출하세요. 없는 항목은 내부에서라도 작성해 첨부하는 것이 좋습니다.

| # | 유형 | 예시 (대형네트웍스·경남 안심링크) |
|---|------|----------------------------------|
| A | **업계·언론** | 2024 대한민국 SNS 대상, 가족친화 우수기업, 스타기업, 벤처기업 인증 — **수상·보도자료 PDF** |
| B | **공공·사업 실적** | 경남도·지자체 스미싱 예방 사업 MOU, 도입 공문, 보도자료, 서비스 런칭 기사 URL |
| C | **벤치마크·테스트** | 스미싱 URL 샘플 N건 대비 **탐지율·오탐율** 내부 테스트 결과 (표 + 테스트 일자 + 방법론) |
| D | **보안·분석** | 자체 또는 제3자 **스미싱 DB/API** 설명, 악성 URL 차단 사례 (개인정보·URL 마스킹) |
| E | **개인정보·정책** | 공식 개인정보처리방침, 앱 내 명시적 고지(SMS/MMS 섹션) **스크린샷 PDF** |
| F | **앱 동작 증명** | 접근성·SMS 고지 포함 **화면 녹화 URL** (YouTube Unlisted) + SMS 권한 ON 후 문자 URL 검사 장면 |

### 벤치마크 테스트 결과 (내부 작성 템플릿)

없으면 아래 형식으로 1~2페이지 PDF를 만들어 제출:

```
제목: 경남 안심링크 SMS 스미싱 URL 검사 벤치마크 (내부 시험)
일자: YYYY-MM-DD
환경: Android XX, 앱 0.4.21+39, 보호 ON, SMS 권한 허용

샘플: 공개 피싱 테스트 URL / 자체 수집 스미싱 패턴 URL / 정상 URL 각 N건
지표: URL 추출 성공률, 서버 판정 응답률, 오탐(정상→위험), 미탐(위험→안전)

결론: 본 앱은 SMS 본문 전체를 서버에 전송하지 않고 URL만 검사하며,
      스미싱 의심 시 사용자에게 경고 UI를 제공함.
```

### 「실적(track record)」가 없을 때

- **경남 안심링크 이전** 동일/유사 보안 서비스(스미싱 URL 검사 API) 운영 기간·고객 수
- **(주)대형네트웍스** IT/보안 사업 연혁, 타 기관 납품 실적
- **공공기관·언론** 보도 링크 (네이버/구글 뉴스 PDF 캡처)

Google은 「글로벌 AV 벤더 리포트」만 요구하는 것은 아니며, **공공·지역 보안 서비스 + 내부 벤치마크 + 수상/보도** 조합도 검토 대상입니다.

---

## 4. Permissions Declaration Form — 영문 붙여넣기용

### Core functionality (핵심 기능)

```
Gyeongnam Ansim Link is a regional mobile security utility that protects users 
from smishing (SMS phishing) and malicious links. Its core functionality is 
real-time URL risk analysis when users receive links via SMS, messenger 
notifications, and mobile browsers — with on-screen warnings before the user 
opens dangerous links.

The app is NOT the default SMS handler. SMS permissions are used ONLY when the 
user explicitly enables "Real-time Protection" on the main screen.
```

### Why RECEIVE_SMS and READ_SMS are required

```
RECEIVE_SMS: Process incoming SMS broadcasts in real time when Protection is ON, 
extract URLs from the message body, and submit only the URL string to our server 
for smishing risk scoring. Full SMS bodies are never uploaded.

READ_SMS: Fallback only — on some devices (RCS/Samsung) the SMS_RECEIVED broadcast 
may be delayed or missed. We query only the newest inbox row (single latest message) 
to detect URLs we might have missed. We do not scan or export SMS history.

When Protection is OFF, snoozed, or SMS permission is revoked, all SMS access stops 
immediately (BroadcastReceiver returns; ContentObserver unregistered).
```

### Data handling

```
- Collected on device: SMS body text (URL extraction only)
- Sent to server: URL strings only (+ anonymous userid for API)
- NOT sent: full SMS/MMS content, contacts, call logs, OTP codes, financial data
- NOT sold or used for ads
- Prominent in-app disclosure before Protection setup (SMS/MMS section + user consent)
```

### User control

```
Users can disable Protection, revoke SMS permission in Android Settings, or 
uninstall the app at any time. The app requests SMS permission in context during 
the setup wizard after prominent disclosure.
```

### Attachments summary (양식 「추가 정보」란)

```
Attached / linked:
1. Company credentials and awards (2024 Korea SNS Grand Prize, venture certification, etc.)
2. Internal smishing URL detection benchmark test report (DATE)
3. Press / public-sector deployment references for Gyeongnam regional service
4. Privacy policy URL and in-app prominent disclosure screenshots
5. Demo video (Protection ON → SMS permission → disclosure → URL check flow)
```

---

## 5. 스토어·앱과 맞출 것 (재반려 방지)

| 항목 | 확인 |
|------|------|
| 스토어 **자세한 설명** | 「문자(SMS) 링크 자동 검사」가 **첫 번째 핵심 기능**으로 보이는지 |
| **Data safety** | SMS/MMS 수집 → **기기에서 처리**, URL만 서버 전송과 일치 |
| **앱 내 고지** | `데이터 수집 및 접근성 서비스 안내` SMS/MMS 섹션 (0.4.21+) |
| **동영상** | SMS 권한 요청 **직전/직후** 맥락 (보호 켜기 → 고지 → SMS 허용) |
| **Default SMS** | 앱이 기본 문자 앱이 **아님**을 명시 |

---

## 6. Plan B — SMS 권한 제거 (양식 승인이 어려울 때)

Google 예외 승인 없이는 **Manifest에서 SMS 권한 제거**가 유일한 확실한 통과 경로입니다.

| | SMS 권한 유지 | SMS 권한 제거 |
|--|--------------|--------------|
| 실시간 문자 수신 검사 | O (`SmsReceiver`) | X |
| inbox 보완 | O (`SmsInboxObserver`) | X |
| **문자 앱 알림** 경로 | O | **O** (`MessageNotificationListener` — 삼성/구글 메시지 등) |
| Play SMS 양식 | **필수 + 증빙** | **불필요** |

알림 접근만으로 **일부 문자**는 검사 가능(알림에 URL·본문이 노출될 때). 알림이 없거나 본문이 잘리면 검사 누락.

Plan B 적용 시: `RECEIVE_SMS`/`READ_SMS` 제거, setup wizard에서 SMS 필수 해제, 스토어 문구 「문자 알림 경로」로 조정.

---

## 7. 재제출 체크리스트

- [ ] Permissions Declaration Form — **Anti-SMS phishing** + 영문 설명
- [ ] 증빙 PDF/URL **2종 이상** (수상·보도 + 벤치마크 또는 공공 사업)
- [ ] Data safety · 스토어 설명 · 앱 고지 **일치**
- [ ] (선택) SMS 흐름 **30~60초** 데모 영상
- [ ] 새 AAB 업로드 후 재심사

---

## 8. 문의 시 Google에 강조할 한 줄

> Non-default SMS app; smishing-only use case; URL-only server transmission; user-initiated Protection toggle; prominent disclosure; regional public safety service by DHN Corp with documented deployment and test results.

---

**관련 문서:** [`08_google_play_permissions_declaration.md`](08_google_play_permissions_declaration.md) · [`09_permissions_copy_paste.txt`](09_permissions_copy_paste.txt)
