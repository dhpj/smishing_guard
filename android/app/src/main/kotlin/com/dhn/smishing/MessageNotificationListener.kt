package com.dhn.smishing

import android.app.Notification
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

/**
 * 카카오톡·텔레그램·LINE + 기본 문자 앱 알림 본문에서 URL 검사.
 */
class MessageNotificationListener : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn ?: return
        val pkg = sbn.packageName
        if (pkg !in allowedPackages) return
        if (!ProtectionPrefs.isActive(applicationContext)) return

        val extras = sbn.notification.extras
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()?.trim().orEmpty()
        val source = sourceForPackage(pkg)
        val appLabel = appLabelForPackage(pkg)
        val parsed = NotificationTextExtractor.parse(extras, title, appLabel)
        if (parsed.scanText.isBlank()) return
        if (ScanThrottle.shouldSkipNotification(pkg, parsed.scanText)) return

        Log.d(TAG, "notif $pkg ($source) scan=${parsed.scanText.length} body=${parsed.messageBody.length}")
        UriCheckBridge.checkText(
            applicationContext,
            parsed.scanText,
            source,
            senderTitle = title.ifEmpty { null },
            appLabel = appLabel,
            messageBody = parsed.messageBody,
        )
    }

    companion object {
        private const val TAG = "SmishingNotif"

        private val SMS_PACKAGES = setOf(
            "com.samsung.android.messaging",
            "com.samsung.android.app.messages",
            "com.google.android.apps.messaging",
            "com.android.mms",
            "com.android.messaging",
        )

        private val allowedPackages = setOf(
            "com.kakao.talk",
            "org.telegram.messenger",
            "org.telegram.messenger.web",
            "org.thunderdog.challegram",
            "jp.naver.line.android",
            "com.linecorp.linelite",
            "com.whatsapp",
            "com.instagram.android",
            "com.facebook.orca",
        ) + SMS_PACKAGES

        private fun sourceForPackage(pkg: String): String = when (pkg) {
            "com.kakao.talk" -> "kakao"
            "org.telegram.messenger",
            "org.telegram.messenger.web",
            "org.thunderdog.challegram",
            -> "telegram"
            "jp.naver.line.android",
            "com.linecorp.linelite",
            -> "line"
            in SMS_PACKAGES -> "sms_notif"
            else -> "notif"
        }

        private fun appLabelForPackage(pkg: String): String = when (pkg) {
            "com.kakao.talk" -> "카카오톡"
            "org.telegram.messenger",
            "org.telegram.messenger.web",
            "org.thunderdog.challegram",
            -> "텔레그램"
            "jp.naver.line.android",
            "com.linecorp.linelite",
            -> "LINE"
            in SMS_PACKAGES -> "문자"
            else -> "알림"
        }
    }
}
