package com.dhn.smishing

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val appCtx = context.applicationContext
        if (!ProtectionPrefs.isActive(appCtx)) return
        SmsInboxObserver.install(appCtx)
        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION != intent.action) return

        val pending = goAsync()
        try {
            val body =
                Telephony.Sms.Intents.getMessagesFromIntent(intent).joinToString("") { it.messageBody ?: "" }
            if (body.isBlank()) return
            Log.d(TAG, "SMS_RECEIVED len=${body.length} preview=${body.take(120)}…")
            UriCheckBridge.checkText(
                appCtx,
                body,
                "sms",
                senderTitle = null,
                appLabel = "문자",
            )
        } finally {
            pending.finish()
        }
    }

    companion object {
        private const val TAG = "SmishingSms"
    }
}
