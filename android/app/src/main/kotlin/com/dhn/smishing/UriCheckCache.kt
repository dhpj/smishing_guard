package com.dhn.smishing

import android.os.SystemClock

/** 동일 URL 재검사·재네트워크 방지 (메모리, LRU) */
object UriCheckCache {
    private const val MAX_ENTRIES = 128
    private const val SAFE_TTL_MS = 60 * 60 * 1000L
    private const val DANGER_TTL_MS = 30 * 60 * 1000L

    data class Entry(val code: String, val message: String, val atElapsed: Long)

    private val lock = Any()
    private val map = object : LinkedHashMap<String, Entry>(32, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, Entry>): Boolean =
            size > MAX_ENTRIES
    }

    fun get(canonicalUri: String): Entry? {
        val now = SystemClock.elapsedRealtime()
        synchronized(lock) {
            val e = map[canonicalUri] ?: return null
            val ttl = if (ApiResultCodes.isSmishing(e.code)) DANGER_TTL_MS else SAFE_TTL_MS
            if (now - e.atElapsed > ttl) {
                map.remove(canonicalUri)
                return null
            }
            return e
        }
    }

    fun put(canonicalUri: String, code: String, message: String) {
        synchronized(lock) {
            map[canonicalUri] =
                Entry(ApiResultCodes.normalize(code), message, SystemClock.elapsedRealtime())
        }
    }

    fun clear() {
        synchronized(lock) { map.clear() }
    }
}
