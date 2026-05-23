package com.dhn.smishing

import android.Manifest
import android.accessibilityservice.AccessibilityServiceInfo
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

object PermissionHelper {
    private val runtimePermissions: Array<String> = buildList {
        add(Manifest.permission.RECEIVE_SMS)
        add(Manifest.permission.READ_SMS)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            add(Manifest.permission.POST_NOTIFICATIONS)
        }
    }.toTypedArray()

    fun requestRuntime(activity: Activity): Map<String, Boolean> {
        val need = runtimePermissions.filter {
            ContextCompat.checkSelfPermission(activity, it) != PackageManager.PERMISSION_GRANTED
        }
        if (need.isNotEmpty()) {
            ActivityCompat.requestPermissions(activity, need.toTypedArray(), 9001)
        }
        return runtimeStatus(activity)
    }

    fun runtimeStatus(context: Context): Map<String, Boolean> {
        return mapOf(
            "sms" to (
                ContextCompat.checkSelfPermission(context, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(context, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
            ),
            "postNotifications" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
            } else true,
        )
    }

    fun isOverlayGranted(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else true
    }

    fun isNotificationListenerEnabled(context: Context): Boolean {
        val flat = Settings.Secure.getString(
            context.contentResolver,
            "enabled_notification_listeners",
        ) ?: return false
        return flat.contains(context.packageName)
    }

    fun isAccessibilityEnabled(context: Context): Boolean {
        val am = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        if (!am.isEnabled) return false
        val target = BrowserAccessibilityService::class.java.name
        val enabled = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
        return enabled.any { it.resolveInfo.serviceInfo.name == target }
    }

    fun isBatteryOptimizationExcluded(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(context.packageName)
    }

    fun fullStatus(context: Context): Map<String, Boolean> {
        val r = runtimeStatus(context).toMutableMap()
        r["overlay"] = isOverlayGranted(context)
        r["notificationListener"] = isNotificationListenerEnabled(context)
        r["accessibility"] = isAccessibilityEnabled(context)
        r["batteryOptimization"] = isBatteryOptimizationExcluded(context)
        val requiredForProtection = listOf(
            "sms",
            "postNotifications",
            "overlay",
            "notificationListener",
            "accessibility",
        )
        r["allReady"] = requiredForProtection.all { r[it] == true }
        return r
    }
}
