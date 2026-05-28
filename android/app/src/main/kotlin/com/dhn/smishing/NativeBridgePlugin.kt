package com.dhn.smishing

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NativeBridgePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
    private var channel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var context: Context? = null
    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        instance = this
        channel = MethodChannel(binding.binaryMessenger, "smishing_guard/native")
        channel?.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "smishing_guard/events")
        eventChannel?.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        instance = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    override fun onDetachedFromActivity() { activity = null }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val ctx = context ?: return result.error("NO_CTX", "No context", null)
        when (call.method) {
            "getPermissionStatus" -> result.success(PermissionHelper.fullStatus(ctx))
            "requestRuntimePermissions" -> {
                val act = activity
                if (act == null) {
                    result.success(PermissionHelper.runtimeStatus(ctx))
                } else {
                    result.success(PermissionHelper.requestRuntime(act))
                }
            }
            "startProtection" -> {
                ProtectionPrefs.invalidate()
                UriCheckCache.clear()
                BrowserAccessibilityService.clearFiredUrls()
                SmsInboxObserver.install(ctx)
                ContextCompat.startForegroundService(ctx, Intent(ctx, GuardForegroundService::class.java))
                result.success(null)
            }
            "stopProtection" -> {
                ProtectionPrefs.invalidate()
                SmsInboxObserver.uninstall(ctx)
                ctx.stopService(Intent(ctx, GuardForegroundService::class.java))
                result.success(null)
            }
            "invalidateProtectionCache" -> {
                ProtectionPrefs.invalidate()
                result.success(null)
            }
            "clearUriCheckCache" -> {
                UriCheckCache.clear()
                result.success(null)
            }
            "showWarningOverlay" -> {
                val sticky = call.argument<Boolean>("sticky") ?: false
                val source = call.argument<String>("source") ?: "notif"
                val bodyText = call.argument<String>("bodyText")
                val senderTitle = call.argument<String>("senderTitle")
                val appLabel = call.argument<String>("appLabel")
                val msgCtx =
                    if (source != "browser" && !bodyText.isNullOrBlank()) {
                        OverlayWarningWindow.MessageContext(
                            messageBody = bodyText,
                            senderTitle = senderTitle,
                            appLabel = appLabel,
                        )
                    } else {
                        null
                    }
                OverlayWarningWindow.show(
                    ctx,
                    call.argument("url") ?: "",
                    call.argument<String>("reason"),
                    sticky,
                    source,
                    msgCtx,
                )
                result.success(null)
            }
            "openNotificationAccessSettings" -> {
                ctx.startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                result.success(null)
            }
            "openAccessibilitySettings" -> {
                val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                ctx.startActivity(intent)
                result.success(null)
            }
            "openOverlaySettings" -> {
                val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:${ctx.packageName}"))
                } else {
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${ctx.packageName}"))
                }
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                ctx.startActivity(intent)
                result.success(null)
            }
            "openBatterySettings" -> {
                val intent =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Intent(
                            Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                            Uri.parse("package:${ctx.packageName}"),
                        )
                    } else {
                        Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    }
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                try {
                    ctx.startActivity(intent)
                } catch (_: Exception) {
                    val fallback = Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.parse("package:${ctx.packageName}"),
                    ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    ctx.startActivity(fallback)
                }
                result.success(null)
            }
            "getAndroidId" -> {
                val id = Settings.Secure.getString(ctx.contentResolver, Settings.Secure.ANDROID_ID)
                result.success(id ?: "")
            }
            "consumeOpenTimeline" -> result.success(OpenTimelineRouter.consume())
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        events?.let { flushPending(it) }
    }

    override fun onCancel(arguments: Any?) { eventSink = null }

    companion object {
        @Volatile var instance: NativeBridgePlugin? = null

        private val pendingLock = Any()
        private val pendingPayloads = mutableListOf<Map<String, String>>()

        fun emit(payload: Map<String, String>) {
            val sink = instance?.eventSink
            if (sink == null) {
                synchronized(pendingLock) {
                    pendingPayloads.add(payload)
                    if (pendingPayloads.size > 50) pendingPayloads.removeAt(0)
                }
                return
            }
            Handler(Looper.getMainLooper()).post { sink.success(payload) }
        }

        private fun flushPending(sink: EventChannel.EventSink) {
            val batch = synchronized(pendingLock) {
                val copy = pendingPayloads.toList()
                pendingPayloads.clear()
                copy
            }
            for (payload in batch) {
                sink.success(payload)
            }
        }
    }
}
