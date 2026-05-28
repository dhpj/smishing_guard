package com.dhn.smishing

import android.content.Context
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Handler
import android.os.Looper

/** 스미싱 탐지 시 짧은 알림음 (설정 ON + 방해 금지 시간 아님). */
object DetectionSoundPlayer {
    private const val TONE_MS = 180

    fun play(context: Context) {
        val appCtx = context.applicationContext
        if (!DetectionUserPrefs.isSoundEnabled(appCtx)) return
        if (DetectionUserPrefs.isQuietHours(appCtx)) return
        try {
            val tone = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 75)
            tone.startTone(ToneGenerator.TONE_PROP_ACK, TONE_MS)
            Handler(Looper.getMainLooper()).postDelayed({ tone.release() }, (TONE_MS + 80).toLong())
        } catch (_: Exception) {
        }
    }
}
