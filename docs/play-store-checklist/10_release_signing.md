# Play Console 출시 서명 (업로드 키)

**앱:** 경남 안심링크 (`com.dhn.smishing`)  
**작성일:** 2026-07-09

---

## 1. 구성 파일 (로컬 전용 — Git 제외)

| 파일 | 용도 |
|------|------|
| `android/app/upload-keystore.jks` | Play Console **업로드 키** keystore |
| `android/key.properties` | Gradle release 서명 비밀번호·alias |
| `android/keystore.credentials.local` | 비밀번호·SHA 지문 백업 메모 (팀 내부 보관) |

> **분실 주의:** 업로드 키를 잃으면 동일 패키지로 업데이트 AAB를 올릴 수 없습니다.  
> `keystore.credentials.local` 과 `upload-keystore.jks` 를 **안전한 곳에 별도 백업**하세요.

---

## 2. release AAB 빌드

```bash
flutter build appbundle --release
```

출력: `build/app/outputs/bundle/release/app-release.aab`

---

## 3. 서명 확인 (debug 아님)

```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
"$JAVA_HOME/bin/jarsigner" -verify -verbose -certs \
  build/app/outputs/bundle/release/app-release.aab
```

- `jar verified` 이고 **CN=Android Debug** 가 아니면 출시 서명 적용됨.

---

## 4. Play Console 업로드

1. [Google Play Console](https://play.google.com/console) → 앱 선택
2. **테스트 / 프로덕션** → **새 버전 만들기**
3. `app-release.aab` 업로드
4. 첫 업로드 시 **Google Play 앱 서명** 사용 권장 (Google이 앱 서명 키 관리)

공식 가이드: https://developer.android.com/studio/publish/app-signing?hl=ko#sign-apk

---

## 5. Gradle 설정 요약

`android/app/build.gradle`:

- `signingConfigs.release` → `key.properties` 참조
- `buildTypes.release.signingConfig` → `signingConfigs.release`

이전(debug 서명) 설정은 제거됨.
