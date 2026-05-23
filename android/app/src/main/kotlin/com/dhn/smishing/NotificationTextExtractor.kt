package com.dhn.smishing

import android.app.Notification
import android.os.Build
import android.os.Bundle

/**
 * 알림 extras 파싱: URL 검사용 전체 텍스트 vs 표시용 메시지 본문(발송자명 제외).
 */
object NotificationTextExtractor {
    data class Parsed(
        val scanText: String,
        val messageBody: String,
    )

    fun parse(extras: Bundle, senderTitle: String?, appLabel: String?): Parsed {
        val title = senderTitle?.trim().orEmpty()
        val label = appLabel?.trim().orEmpty()
        val skip = buildSet {
            if (title.isNotEmpty()) add(title)
            if (label.isNotEmpty()) add(label)
        }

        val scanParts = linkedSetOf<String>()
        val bodyParts = linkedSetOf<String>()

        fun addToScan(s: CharSequence?) {
            val t = s?.toString()?.trim().orEmpty()
            if (t.isNotEmpty()) scanParts.add(t)
        }

        fun addToBody(s: CharSequence?) {
            val t = s?.toString()?.trim().orEmpty()
            if (t.isEmpty() || t in skip) return
            bodyParts.add(t)
        }

        addToScan(extras.getCharSequence(Notification.EXTRA_TITLE))
        addToBody(extras.getCharSequence(Notification.EXTRA_TEXT))
        addToBody(extras.getCharSequence(Notification.EXTRA_BIG_TEXT))
        addToBody(extras.getCharSequence(Notification.EXTRA_SUB_TEXT))
        addToBody(extras.getCharSequence(Notification.EXTRA_INFO_TEXT))
        addToBody(extras.getCharSequence(Notification.EXTRA_SUMMARY_TEXT))

        @Suppress("DEPRECATION")
        val lines = extras.getCharSequenceArray(Notification.EXTRA_TEXT_LINES)
        if (lines != null) {
            for (line in lines) {
                addToScan(line)
                addToBody(line)
            }
        }

        // 카카오톡·텔레그램 등 MessagingStyle — 본문이 EXTRA_TEXT 가 비어 있는 경우가 많음
        for (text in extractMessagingStyleTexts(extras)) {
            addToScan(text)
            addToBody(text)
        }

        // URL이 제목에만 있는 경우 대비 — 스캔에는 제목 포함
        if (title.isNotEmpty()) scanParts.add(title)

        val scanText = scanParts.joinToString("\n")
        var messageBody = bodyParts.joinToString("\n").trim()

        if (messageBody.isEmpty() && title.isNotEmpty()) {
            // 본문 필드가 비어 있고 제목만 있을 때 — 제목을 본문으로 쓰지 않음
            messageBody = scanParts
                .filter { it !in skip }
                .joinToString("\n")
                .trim()
        }

        return Parsed(
            scanText = scanText.ifBlank { messageBody },
            messageBody = messageBody.ifBlank { scanText },
        )
    }

    /** MessagingStyle 알림의 개별 메시지 텍스트 (API 24+) */
    private fun extractMessagingStyleTexts(extras: Bundle): List<String> {
        val out = linkedSetOf<String>()
        val keys = listOf("android.messages", Notification.EXTRA_MESSAGES)
        for (key in keys) {
            val arr =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    extras.getParcelableArray(key, Bundle::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    extras.getParcelableArray(key)
                } ?: continue
            for (item in arr) {
                if (item !is Bundle) continue
                item.getCharSequence("text")?.toString()?.trim()?.takeIf { it.isNotEmpty() }
                    ?.let { out.add(it) }
            }
        }
        extras.getCharSequence("android.text")?.toString()?.trim()?.takeIf { it.isNotEmpty() }
            ?.let { out.add(it) }
        return out.toList()
    }
}
