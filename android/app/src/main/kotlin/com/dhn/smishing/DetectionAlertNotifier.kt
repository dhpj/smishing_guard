package com.dhn.smishing

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

/**
 * 다른 앱 위에 표시 권한이 없을 때도 탐지 결과를 놓치지 않도록 시스템 알림으로 보여 준다.
 */
object DetectionAlertNotifier {
    private const val CHANNEL_ID = "smishing_detection_alert"
    private const val CHANNEL_NAME = "스미싱 탐지 알림"
    private const val BROWSER_NOTIFY_ID = 41001

    fun notifyDanger(
        context: Context,
        url: String,
        serverMessage: String?,
        source: String,
        appLabel: String?,
    ) {
        val appCtx = context.applicationContext
        ensureChannel(appCtx)
        val nm = appCtx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val title = WarningCopy.bannerTitle()
        val subtitle =
            if (source == "browser") {
                WarningCopy.browserWarningLine()
            } else {
                WarningCopy.notificationWarningLine()
            }
        val from = appLabel?.trim().orEmpty().ifEmpty {
            when (source) {
                "kakao" -> "카카오톡"
                "telegram" -> "텔레그램"
                "line" -> "LINE"
                "sms", "sms_notif", "sms_db" -> "문자"
                "browser" -> "브라우저"
                else -> "메시지"
            }
        }
        val body = "$from · $subtitle\n$url"

        val launch = appCtx.packageManager.getLaunchIntentForPackage(appCtx.packageName)?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra(MainActivity.EXTRA_OPEN_TIMELINE, true)
        }
        val pending = PendingIntent.getActivity(
            appCtx,
            (url.hashCode() and 0x7FFF),
            launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(appCtx, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle(title)
            .setContentText(url)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(pending)
            .build()

        val notifyId =
            if (source == "browser") {
                nm.cancel(BROWSER_NOTIFY_ID)
                BROWSER_NOTIFY_ID
            } else {
                (url.hashCode() xor source.hashCode()) and 0x7FFFFFFF
            }
        nm.notify(notifyId, notification)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = nm.getNotificationChannel(CHANNEL_ID)
        if (existing != null) return
        nm.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "스미싱 의심 URL이 탐지되었을 때 표시됩니다"
                enableVibration(true)
            },
        )
    }
}
