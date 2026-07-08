# Google Play 스토어 등록 제출 패키지

**앱명:** 경남 안심링크  
**버전:** `0.4.15+33` (versionName `0.4.15` · versionCode `33`)  
**작성일:** 2026-07-07  
**배포 주체:** (주)대형네트웍스 · 개인정보 보호 책임자 송도휘

---

## 1. AAB 파일 (앱 번들)

| 항목 | 내용 |
|------|------|
| 빌드 명령 | `flutter build appbundle --release` |
| 출력 경로 | `build/app/outputs/bundle/release/app-release.aab` |
| Play Console 업로드 | **Production / Internal testing** → **새 버전 만들기** → App bundle 업로드 |

> **참고:** 현재 `android/app/build.gradle` 은 **debug 서명**으로 release 빌드됩니다.  
> Play Console **최초 등록**은 Google Play App Signing 사용 시 업로드 키로도 가능하나,  
> **정식 상용 배포 전** 업로드 키(keystore) 발급·`signingConfig` 교체를 권장합니다.

---

## 2. 패키지명 (Application ID)

```
com.dhn.smishing
```

Play Console **앱 만들기** 시 패키지명은 **등록 후 변경 불가**합니다. 위 ID로 생성하세요.

---

## 3. 스토어 등록 문구

### 한 줄 소개 (최대 80자)

```
문자·메신저·브라우저 링크를 실시간 검사해 스미싱·피싱 위험을 알려주는 경남 안심링크
```

(글자 수: 47자)

### 짧은 설명 대안 (80자 안에서 톤 조정용)

```
스미싱 URL을 자동 탐지하고 위험 시 즉시 경고. 문자·카톡·웹 브라우저를 실시간 보호합니다.
```

### 자세한 설명

**전체 문구(복사용):** [`07_store_listing_copy.txt`](07_store_listing_copy.txt) · [`deliverables/07_store_listing_copy.txt`](deliverables/07_store_listing_copy.txt)

Play Console **자세한 설명**란에는 txt 파일 **「자세한 설명 (전체)」** 섹션 전체를 붙여 넣으세요.

### 그래픽 자산 (아이콘 · 배너)

| 용도 | Play Console 사양 | 제출용 파일 |
|------|-------------------|-------------|
| **앱 아이콘** | 512×512 PNG | `deliverables/google_play_icon_512x512.png` |
| **Feature graphic (배너)** | 1024×500 PNG | `deliverables/google_play_feature_graphic_1024x500.png` |

---

## 4. 테스트 계정 (회원가입 / 로그인)

| 항목 | 내용 |
|------|------|
| 회원가입·로그인 | **없음** |
| 계정 체계 | 앱 최초 실행 시 서버가 `ANDROID_ID` 기반으로 **익명 userid** 자동 발급 |
| Google 심사용 계정 | **제공 불필요** — 앱 설치 후 바로 사용 가능 |

Play Console **앱 액세스** 질문 답변 예시:

> 모든 기능이 제한 없이 이용 가능합니다. 별도 로그인·회원가입이 없으며, 앱 설치 후 권한 허용 및 「보호 켜기」만 하면 전체 기능을 테스트할 수 있습니다.

**심사 시 권장 테스트 순서**
1. 앱 설치·실행 (서버 연결 필요 — `http://210.127.253.95:3098`)
2. SMS·알림 접근·접근성·다른 앱 위 표시 권한 허용
3. 메인 화면에서 「보호 켜기」
4. 테스트용 의심 URL이 포함된 문자/알림 수신 또는 브라우저에서 URL 방문

---

## 5. 개인정보처리방침 URL

```
http://dhncorp.co.kr/sub/service/privacy.php
```

| 항목 | 내용 |
|------|------|
| 운영 주체 | (주)대형네트웍스 |
| 주소 | 경상남도 창원시 의창구 평산로 33 신화더플렉스시티 715, 716, 717호 |
| 개인정보 보호 책임자 | 송도휘 |
| 연락처 | 055-713-7985 |
| 이메일 | dhn@dhncorp.co.kr |

---

## 6. 카테고리

| Play Console 항목 | 권장 |
|-------------------|------|
| **앱 카테고리** | **도구 (Tools)** |
| 태그(선택) | 보안, 스미싱, 피싱, URL 검사 |

**도구**를 권장하는 이유: 본 앱의 핵심은 메시징 자체가 아니라 **URL 위험도 검사·경고** 보안 유틸리티입니다.

대안으로 **커뮤니케이션**도 가능하나, 스토어 검색·정책 설명 시 SMS·알림 권한 심사가 더 엄격해질 수 있어 **도구**가 일반적으로 유리합니다.

**콘텐츠 등급:** 전체이용가 (폭력·성적 콘텐츠 없음)  
**대상 연령:** 13세 이상 권장 (개인정보 방침: 만 14세 미만 비대상)

---

## 7. 심사 시 추가로 준비할 항목 (반려 대비)

Play Console 등록 후 **별도 폼·설문**이 필요합니다. 상세는 `03_play_console_checklist.csv` 참고.

| 항목 | 우리 앱 | 대응 요약 |
|------|---------|-----------|
| Data safety | android_id, userid, URL 서버 전송 | `01_collected_data.csv` 와 Privacy Policy 일치하게 입력 |
| SMS 권한 선언 | RECEIVE_SMS, READ_SMS | 스미싱 URL 탐지 목적 — Default SMS 앱 아님 |
| Accessibility | 브라우저 주소창만 읽기 | 페이지 본문·입력 미수집 명시 |
| Notification Listener | 메신저 알림 URL 추출 | 대화 전체 미전송 명시 |
| Foreground Service | specialUse | 백그라운드 링크 감시 목적 |
| 그래픽 자산 | 아이콘·스크린샷·배너 | `docs/play-store-checklist/assets/` |

### SMS 권한 사유서 초안 (영문 제출용 참고)

```
This app is not a default SMS handler. It uses SMS permissions solely to 
extract URLs from incoming text messages for real-time smishing/phishing 
risk analysis. Message bodies are not uploaded to our servers; only 
extracted URL strings are sent for security checking.
```

### Accessibility 사유서 초안

```
The accessibility service reads only the browser address bar URL field 
(registered browsers such as Chrome, Samsung Internet, Firefox) to check 
the currently visited page for smishing/phishing risk. It does not collect 
page content, passwords, or user input from other UI elements.
```

---

## 8. 제출 체크리스트 (담당자용)

- [ ] `app-release.aab` 빌드 완료
- [ ] Play Console 앱 생성 (`com.dhn.smishing`)
- [ ] 스토어 등록: 한 줄 소개 · 자세한 설명 · 아이콘 · 스크린샷
- [ ] 개인정보처리방침 URL 입력
- [ ] Data safety 폼 작성
- [ ] SMS / Accessibility / Notification listener 선언
- [ ] 앱 액세스: 「제한 없음」 (로그인 없음)
- [ ] 내부 테스트 트랙 업로드 후 실기기 검증
- [ ] 프로덕션 심사 제출

---

## 9. 연락처 (등록 담당자 전달용)

| 구분 | 정보 |
|------|------|
| 앱명 | 경남 안심링크 |
| 패키지명 | `com.dhn.smishing` |
| 버전 | 0.4.15 (33) |
| AAB | `build/app/outputs/bundle/release/app-release.aab` |
| 개인정보처리방침 | http://dhncorp.co.kr/sub/service/privacy.php |
| 테스트 계정 | 없음 (설치 즉시 사용) |
| 카테고리 | 도구 (Tools) |
| 배포 주체 | (주)대형네트웍스 / 송도휘 |
