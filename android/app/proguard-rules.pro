# =============================================================
# Smishing Guard ProGuard / R8 rules
# =============================================================
# R8(release) 미니파이 시 누락 클래스 경고를 무시하고, 런타임 리플렉션이
# 필요한 클래스를 보존한다.
#
# 주요 원인: flutter_secure_storage 9.x 는 내부적으로 Google Tink 를 사용한다.
# Tink 는 컴파일 타임에만 쓰이는 어노테이션(errorprone, javax.annotation)을
# 참조하기 때문에, R8 이 그 어노테이션 클래스를 찾지 못해 빌드가 깨진다.
# Google Tink 공식 README/GitHub Issue 1041 에서 권장하는 keep / dontwarn 규칙.
# -------------------------------------------------------------

# --- Google Tink (flutter_secure_storage 9.x 의존성) ---
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# --- Tink 가 참조하지만 런타임엔 필요 없는 컴파일 타임 어노테이션 ---
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.**

# --- Protobuf (Tink 내부에서 사용) ---
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# --- flutter_secure_storage 본체 ---
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# --- Flutter / Kotlin 표준 보존 (안전 가드) ---
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keepclasseswithmembers class * {
    @kotlin.Metadata *;
}

# --- Google Play Core (Deferred Components) ---
# Flutter 임베딩(`io.flutter.embedding.engine.deferredcomponents.*`,
# `FlutterPlayStoreSplitApplication`)이 동적 모듈 설치용 Play Core 클래스를 참조하지만,
# 본 앱은 dynamic feature / deferred component 를 사용하지 않으므로 의존성을
# 추가하지 않고 R8 경고만 무시한다. Flutter 3.19 공식 가이드 권장 규칙.
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.**
