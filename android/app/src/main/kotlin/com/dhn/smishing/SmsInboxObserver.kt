package com.dhn.smishing

import android.content.Context
import android.database.ContentObserver
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import android.util.Log
import java.util.concurrent.atomic.AtomicBoolean

/**
 * [SMS_RECEIVED]가 빠진 경우(RCS·기본 문자앱)·지연되는 경우를 보완: inbox Provider 변경 관찰.
 */
object SmsInboxObserver {
    private const val TAG = "SmishingInboxSms"
    private const val PREF = "smishing_inbox_observer"
    private const val KEY_CURSOR = "last_id"
    private const val DEBOUNCE_MS = 900L

    private val handler = Handler(Looper.getMainLooper())
    private val hooked = AtomicBoolean(false)
    private val debounced = Runnable { poke() }

    private var installerCtx: Context? = null
    private var lastSeenId = -1L

    /** 멱등: 앱/리시버에서 각각 불러도 1번만 등록 */
    fun install(appCtx: Context) {
        val ctx = appCtx.applicationContext
        if (!ProtectionPrefs.isActive(ctx)) return
        if (!hooked.compareAndSet(false, true)) return
        installerCtx = ctx
        val prefs = ctx.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        lastSeenId = prefs.getLong(KEY_CURSOR, -1L)

        handler.post {
            try {
                // READ_SMS 없이 inbox 쿼리 시 SecurityException → 첫 기동에서 앱 전체가 죽을 수 있음
                if (PermissionHelper.runtimeStatus(ctx)["sms"] == true) {
                    bootstrapCursor(ctx)
                }
                ctx.contentResolver.registerContentObserver(Telephony.Sms.CONTENT_URI, true, observer)
                Log.i(TAG, "installed, inbox cursor=$lastSeenId (smsPerm=${PermissionHelper.runtimeStatus(ctx)["sms"]})")
            } catch (e: SecurityException) {
                Log.w(TAG, "inbox observer install denied: ${e.message}")
                hooked.set(false)
            } catch (e: Exception) {
                Log.e(TAG, "inbox observer install failed", e)
                hooked.set(false)
            }
        }
    }

    /**
     * SMS 권한을 나중에 허용한 뒤 커서만 맞추고 싶을 때(멱등).
     * install()은 이미 성공했어도 안전하게 다시 baseline 을 잡는다.
     */
    fun syncBaselineIfPermitted(appCtx: Context) {
        val ctx = appCtx.applicationContext
        handler.post {
            try {
                if (PermissionHelper.runtimeStatus(ctx)["sms"] != true) return@post
                bootstrapCursor(ctx)
            } catch (e: SecurityException) {
                Log.w(TAG, "sync baseline denied: ${e.message}")
            } catch (e: Exception) {
                Log.w(TAG, "sync baseline failed", e)
            }
        }
    }

    private val observer =
        object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean) {
                handler.removeCallbacks(debounced)
                handler.postDelayed(debounced, DEBOUNCE_MS)
            }
        }

    private fun bootstrapCursor(ctx: Context) {
        if (PermissionHelper.runtimeStatus(ctx)["sms"] != true) return
        val prefs = ctx.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        newestInboxSmsId(ctx)?.let { id ->
            lastSeenId = id
            prefs.edit().putLong(KEY_CURSOR, id).apply()
        }
    }

    fun uninstall(appCtx: Context) {
        if (!hooked.compareAndSet(true, false)) return
        val ctx = appCtx.applicationContext
        handler.post {
            try {
                ctx.contentResolver.unregisterContentObserver(observer)
            } catch (_: Exception) {
            }
            installerCtx = null
            handler.removeCallbacks(debounced)
        }
    }

    private fun poke() {
        val ctx = installerCtx ?: return
        if (!ProtectionPrefs.isActive(ctx)) return
        if (PermissionHelper.runtimeStatus(ctx)["sms"] != true) return

        val row = newestInboxRow(ctx) ?: return
        val id = row.first
        val body = row.second

        if (id <= lastSeenId) return
        lastSeenId = id
        ctx.getSharedPreferences(PREF, Context.MODE_PRIVATE).edit().putLong(KEY_CURSOR, id).apply()

        if (body.isBlank()) return
        Log.d(TAG, "inbox sms id=$id len=${body.length} preview=${body.take(96)}…")
        UriCheckBridge.checkText(ctx, body, "sms_db", appLabel = "문자")
    }

    private fun newestInboxSmsId(ctx: Context): Long? =
        newestInboxRow(ctx)?.first

    private fun newestInboxRow(ctx: Context): Pair<Long, String>? {
        if (PermissionHelper.runtimeStatus(ctx)["sms"] != true) return null
        ctx.contentResolver
            .query(
                Telephony.Sms.Inbox.CONTENT_URI,
                arrayOf(Telephony.Sms._ID, Telephony.Sms.BODY),
                null,
                null,
                "${Telephony.Sms.DATE} DESC",
            )?.use { c ->
                if (c.moveToFirst()) return c.getLong(0) to (c.getString(1) ?: "")
            }
        return null
    }
}
