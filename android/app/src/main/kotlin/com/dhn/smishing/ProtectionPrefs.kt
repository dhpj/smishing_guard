package com.dhn.smishing

import android.content.Context
import android.os.SystemClock

/** Flutter `protection_enabled` — 디스크 읽기 최소화 */
object ProtectionPrefs {
    private const val FLUTTER = "FlutterSharedPreferences"
    private const val KEY = "flutter.protection_enabled"
    private const val CACHE_MS = 2500L

    @Volatile
    private var cached: Boolean? = null

    @Volatile
    private var cachedAt = 0L

    fun isActive(ctx: Context): Boolean {
        val now = SystemClock.elapsedRealtime()
        cached?.let { if (now - cachedAt < CACHE_MS) return it }
        val appCtx = ctx.applicationContext
        if (DetectionUserPrefs.isSnoozed(appCtx)) {
            cached = false
            cachedAt = now
            return false
        }
        val on =
            appCtx
                .getSharedPreferences(FLUTTER, Context.MODE_PRIVATE)
                .getBoolean(KEY, false)
        cached = on
        cachedAt = now
        return on
    }

    fun invalidate() {
        cached = null
    }
}
