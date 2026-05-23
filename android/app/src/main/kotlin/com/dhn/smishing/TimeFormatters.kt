package com.dhn.smishing

import java.util.Calendar
import java.util.Locale

object TimeFormatters {
    fun formatKoreanDateTime(millis: Long = System.currentTimeMillis()): String {
        val cal = Calendar.getInstance(Locale.KOREA)
        cal.timeInMillis = millis
        val year = cal.get(Calendar.YEAR)
        val month = (cal.get(Calendar.MONTH) + 1).toString().padStart(2, '0')
        val day = cal.get(Calendar.DAY_OF_MONTH).toString().padStart(2, '0')
        val hour24 = cal.get(Calendar.HOUR_OF_DAY)
        val minute = cal.get(Calendar.MINUTE).toString().padStart(2, '0')
        val second = cal.get(Calendar.SECOND).toString().padStart(2, '0')
        val period = if (hour24 < 12) "오전" else "오후"
        val hour12 = when {
            hour24 == 0 -> 12
            hour24 > 12 -> hour24 - 12
            else -> hour24
        }
        return "${year}년 ${month}월 ${day}일 $period ${hour12}시 ${minute}분 ${second}초"
    }

    fun truncatePreview(text: String, maxLen: Int = 72): String {
        val compact = text.replace(Regex("\\s+"), " ").trim()
        if (compact.length <= maxLen) return compact
        return compact.take(maxLen).trimEnd() + "…"
    }
}
