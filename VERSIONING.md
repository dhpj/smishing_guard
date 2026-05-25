# 버전 · 브랜치 정책

## Git 브랜치

| 브랜치 | 용도 |
|--------|------|
| `main` | 통합 테스트 **완료 후** 안정 스냅샷 |
| `v0.1.2` | 일상 개발 · **push 기본 대상** · 현재 통합 테스트 |

```bash
# 작업 시작
git checkout v0.1.2

# push (기본)
git push origin v0.1.2

# main 반영 (테스트 완료 후)
git checkout main && git merge v0.1.2 && git push origin main
```

## 앱 버전 (`pubspec.yaml`)

형식: `MAJOR.MINOR.PATCH+BUILD`

- **PATCH** (`0.1.x`): 버그 수정·안정화 (CHANGELOG의 Fixed)
- **MINOR** (`0.2.0`): 사용자에게 보이는 기능 추가
- **BUILD** (`+N`): 동일 PATCH 내 빌드 번호 (스토어/QA)

현재 개발 중: **`0.1.4+4`** (브랜치 `v0.1.2`에서 계속 작업)

## CHANGELOG와 버전 올리기

1. 작업 내용을 [CHANGELOG.md](CHANGELOG.md)의 `Unreleased` 또는 해당 버전 섹션에 분류
   - `Added` / `Changed` / `Fixed` / `Deprecated` / `Removed`
2. 릴리스 시:
   - Fixed만 → PATCH +1 (예: `0.1.2` → `0.1.3`)
   - Added(기능) → MINOR +1 (예: `0.1.x` → `0.2.0`)
3. `pubspec.yaml`의 `version:` 갱신
4. `v0.1.x` 브랜치에 커밋 · push

## 서버 API 버전 (별도)

앱 버전과 무관. 서버 판정 코드:

| code | 의미 |
|------|------|
| `0000` | 안전 |
| `0001` | 스미싱 주의 |

앱은 `ApiResultCodes`로 `1` / `"0001"` 등도 동일 처리.
