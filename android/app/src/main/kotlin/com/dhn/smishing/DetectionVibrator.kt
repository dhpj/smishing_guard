package com.dhn.smishing

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/**
 * 스미싱 탐지 시 짧게 1회 진동.
 *
 * 사용자가 설정에서 진동 토글을 OFF로 두면 동작하지 않는다.
 * Flutter `shared_preferences`는 키 앞에 `flutter.` 접두사를 붙이므로, 네이티브에서는
 * `flutter.vibrate_on_detect`로 읽는다. 기본값 true.
 */
object DetectionVibrator {
    private const val PREF_KEY = "flutter.vibrate_on_detect"
    private const val PATTERN_MILLIS = 60L

    fun pulse(context: Context) {
        val appCtx = context.applicationContext
        if (!isEnabled(appCtx)) return
        if (DetectionUserPrefs.isQuietHours(appCtx)) return
        val vibrator = obtainVibrator(appCtx) ?: return
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(
                    VibrationEffect.createOneShot(
                        PATTERN_MILLIS,
                        VibrationEffect.DEFAULT_AMPLITUDE,
                    ),
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(PATTERN_MILLIS)
            }
        } catch (_: SecurityException) {
        }
    }

    private fun isEnabled(context: Context): Boolean {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE,
        )
        return prefs.getBoolean(PREF_KEY, true)
    }

    private fun obtainVibrator(context: Context): Vibrator? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val mgr = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE)
                as? VibratorManager
            mgr?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
    }
}
