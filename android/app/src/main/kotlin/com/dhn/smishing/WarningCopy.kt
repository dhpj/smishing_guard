package com.dhn.smishing

/** 사용자에게 보여줄 문구 (API 숫자 코드는 노출하지 않음). */
object WarningCopy {
    fun userFacingSubtitle(serverMessage: String?): String {
        val m = serverMessage?.trim().orEmpty()
        if (m.isEmpty()) {
            return defaultBody()
        }
        if (m.matches(Regex("^0+[0-9]{1,10}$"))) {
            return defaultBody()
        }
        if (m.contains("mock", ignoreCase = true)) {
            return "테스트용 판별 결과입니다. 실제 사용 시에는 서버 안내 문구가 표시됩니다."
        }
        val stripped = m
            .replace(Regex("(?i)(코드|code)\\s*[:.]?\\s*0+[0-9]+"), "")
            .replace(Regex("^0+[0-9]+$"), "")
            .trim()
        return if (stripped.isEmpty()) defaultBody() else stripped
    }

    fun bannerTitle(): String = "스미싱 의심 링크"

    fun footnote(sticky: Boolean): String =
        if (sticky) {
            "이동은 차단하지 않습니다 · 확인을 누르기 전까지 이 알림이 유지됩니다"
        } else {
            "이동은 차단하지 않습니다 · 잠시 후 자동으로 닫히거나 버튼으로 닫을 수 있습니다"
        }

    fun defaultBody(): String =
        "이 링크는 스미싱에 악용될 가능성이 있습니다.\n금융·결제 정보 입력 또는 설치 안내 메시지는 특히 각별히 주세요."

    fun notificationWarningLine(): String =
        "주의! 악성 URL이 실시간으로 탐지되었어요."

    fun browserWarningLine(): String =
        "주의! 방문 중인 페이지는 스미싱 의심 URL 입니다."
}
