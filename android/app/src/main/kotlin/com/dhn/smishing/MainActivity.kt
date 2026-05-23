package com.dhn.smishing

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (ProtectionPrefs.isActive(applicationContext)) {
            SmsInboxObserver.install(applicationContext)
        }
        handleOpenTimelineIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleOpenTimelineIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        SmsInboxObserver.syncBaselineIfPermitted(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(NativeBridgePlugin())
    }

    private fun handleOpenTimelineIntent(intent: Intent?) {
        if (intent?.getBooleanExtra(EXTRA_OPEN_TIMELINE, false) == true) {
            OpenTimelineRouter.requestOpen()
            intent.removeExtra(EXTRA_OPEN_TIMELINE)
        }
    }

    companion object {
        const val EXTRA_OPEN_TIMELINE = "open_timeline"
    }
}
