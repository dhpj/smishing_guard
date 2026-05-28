package com.dhn.smishing

import android.content.Context
import org.json.JSONArray
import java.util.Calendar

/**
 * Flutter [SharedPreferences] 와 동기화된 사용자 설정 (키 접두사 `flutter.`).
 */
object DetectionUserPrefs {
    private const val FLUTTER = "FlutterSharedPreferences"

    private const val VIBRATE = "flutter.vibrate_on_detect"
    private const val SOUND = "flutter.sound_on_detect"
    private const val COMPACT_OVERLAY = "flutter.overlay_compact_mode"
    private const val ALERT_MODE = "flutter.alert_mode"
    private const val QUIET_ENABLED = "flutter.quiet_hours_enabled"
    private const val QUIET_START = "flutter.quiet_hours_start_min"
    private const val QUIET_END = "flutter.quiet_hours_end_min"
    private const val TRUSTED_JSON = "flutter.trusted_domains_json"
    private const val SNOOZE_UNTIL = "flutter.protection_snooze_until_ms"

    private const val ALERT_OVERLAY = "overlay"
    private const val ALERT_NOTIFICATION = "notification"

    private fun prefs(ctx: Context) =
        ctx.applicationContext.getSharedPreferences(FLUTTER, Context.MODE_PRIVATE)

    fun isSnoozed(ctx: Context): Boolean {
        val until = prefs(ctx).getString(SNOOZE_UNTIL, null)?.toLongOrNull() ?: 0L
        return until > System.currentTimeMillis()
    }

    fun isVibrateEnabled(ctx: Context): Boolean =
        prefs(ctx).getBoolean(VIBRATE, true)

    fun isSoundEnabled(ctx: Context): Boolean =
        prefs(ctx).getBoolean(SOUND, false)

    fun compactOverlayMode(ctx: Context): Boolean =
        prefs(ctx).getBoolean(COMPACT_OVERLAY, false)

    fun preferOverlay(ctx: Context): Boolean =
        prefs(ctx).getString(ALERT_MODE, ALERT_OVERLAY) != ALERT_NOTIFICATION

    fun isQuietHours(ctx: Context): Boolean {
        val p = prefs(ctx)
        if (!p.getBoolean(QUIET_ENABLED, false)) return false
        val start = p.getInt(QUIET_START, 23 * 60)
        val end = p.getInt(QUIET_END, 7 * 60)
        val cal = Calendar.getInstance()
        val cur = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
        if (start == end) return false
        return if (start < end) {
            cur in start until end
        } else {
            cur >= start || cur < end
        }
    }

    /** 진동·소리·오버레이·탐지 알림 등 사용자에게 띄우는 피드백 */
    fun shouldNotifyUser(ctx: Context): Boolean =
        !isQuietHours(ctx)

    fun trustedDomains(ctx: Context): List<String> {
        val raw = prefs(ctx).getString(TRUSTED_JSON, null) ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            buildList {
                for (i in 0 until arr.length()) {
                    val s = arr.optString(i, "").trim().lowercase()
                    if (s.isNotEmpty()) add(s)
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun isTrustedUrl(ctx: Context, url: String): Boolean =
        TrustedDomains.matches(url, trustedDomains(ctx))
}
