package com.dhn.smishing

import android.os.SystemClock

/** 알림·문자 등 동일 payload 반복 처리 방지 */
object ScanThrottle {
    private const val NOTIF_MS = 4000L
    private const val MAX_KEYS = 48

    private val lock = Any()
    private val notifKeys = object : LinkedHashMap<Int, Long>(24, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<Int, Long>): Boolean =
            size > MAX_KEYS
    }

    fun shouldSkipNotification(packageName: String, scanText: String): Boolean {
        val key = (packageName + "\n" + scanText.take(280)).hashCode()
        val now = SystemClock.elapsedRealtime()
        synchronized(lock) {
            val prev = notifKeys[key]
            if (prev != null && now - prev < NOTIF_MS) return true
            notifKeys[key] = now
            return false
        }
    }
}
