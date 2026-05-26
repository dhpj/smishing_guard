package com.dhn.smishing

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView

object OverlayWarningWindow {
    private var currentView: View? = null
    private val handler = Handler(Looper.getMainLooper())
    private var autoDismissRunnable: Runnable? = null

    data class MessageContext(
        val messageBody: String? = null,
        val senderTitle: String? = null,
        val appLabel: String? = null,
        val detectedAtMillis: Long = System.currentTimeMillis(),
    )

    fun show(
        context: Context,
        url: String,
        serverMessage: String?,
        sticky: Boolean,
        source: String = "browser",
        messageContext: MessageContext? = null,
        detectedAtMillis: Long = System.currentTimeMillis(),
    ) {
        val appCtx = context.applicationContext
        handler.post {
            dismissImmediate(appCtx)

            val overlayOk =
                Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                    android.provider.Settings.canDrawOverlays(appCtx)
            if (!overlayOk) {
                DetectionAlertNotifier.notifyDanger(
                    appCtx,
                    url,
                    serverMessage,
                    source,
                    messageContext?.appLabel,
                )
                return@post
            }

            val wm = appCtx.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val useMessageStyle = source != "browser" && messageContext != null
            val view = if (useMessageStyle) {
                bindMessageStyle(appCtx, url, source, messageContext!!)
            } else {
                bindBrowserStyle(appCtx, url, detectedAtMillis)
            }

            val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            }

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                type,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                y = 24
            }

            try {
                wm.addView(view, params)
                currentView = view
                DetectionVibrator.pulse(appCtx)
            } catch (e: Exception) {
                DetectionAlertNotifier.notifyDanger(
                    appCtx,
                    url,
                    serverMessage,
                    source,
                    messageContext?.appLabel,
                )
                return@post
            }

            autoDismissRunnable?.let { handler.removeCallbacks(it) }
            autoDismissRunnable = null

            if (!sticky) {
                val r = Runnable { dismiss(appCtx) }
                autoDismissRunnable = r
                handler.postDelayed(r, 26_000L)
            }
        }
    }

    /** 메시지 알림과 동일 카드 UI — 본문 미리보기만 없음 */
    private fun bindBrowserStyle(
        appCtx: Context,
        url: String,
        detectedAtMillis: Long,
    ): View {
        val view = LayoutInflater.from(appCtx).inflate(R.layout.overlay_warning_message, null)
        val detectedAt = TimeFormatters.formatKoreanDateTime(detectedAtMillis)

        bindAppIcon(view, source = "browser")
        view.findViewById<TextView>(R.id.overlay_sender).text = "웹 브라우저"
        view.findViewById<TextView>(R.id.overlay_app_time).text = "브라우저 · 지금"
        view.findViewById<TextView>(R.id.overlay_warning_line).text = WarningCopy.browserWarningLine()
        view.findViewById<TextView>(R.id.overlay_message_preview).visibility = View.GONE
        view.findViewById<TextView>(R.id.overlay_url).text = url
        view.findViewById<TextView>(R.id.overlay_detected_at).text = "탐지 시각  $detectedAt"
        view.findViewById<TextView>(R.id.overlay_quip).text = DetectionQuips.random()
        loadOverlayAd(appCtx, view)

        val dismiss = { dismiss(appCtx) }
        view.findViewById<TextView>(R.id.overlay_dismiss).setOnClickListener { dismiss() }
        view.findViewById<ImageButton>(R.id.overlay_close).setOnClickListener { dismiss() }
        view.findViewById<TextView>(R.id.overlay_open_app).setOnClickListener {
            val launch = appCtx.packageManager.getLaunchIntentForPackage(appCtx.packageName)
            launch?.putExtra(MainActivity.EXTRA_OPEN_TIMELINE, true)
            launch?.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP,
            )
            if (launch != null) appCtx.startActivity(launch)
            dismiss()
        }
        return view
    }

    private fun bindMessageStyle(
        appCtx: Context,
        url: String,
        source: String,
        ctx: MessageContext,
    ): View {
        val view = LayoutInflater.from(appCtx).inflate(R.layout.overlay_warning_message, null)
        val body = ctx.messageBody?.trim().orEmpty()
        val sender = ctx.senderTitle?.trim().orEmpty().ifEmpty { appLabelForSource(source) }
        val appLabel = ctx.appLabel?.trim().orEmpty().ifEmpty { appLabelForSource(source) }
        val nowMillis = System.currentTimeMillis()
        val detectedAt = TimeFormatters.formatKoreanDateTime(nowMillis)

        bindAppIcon(view, source = source)
        view.findViewById<TextView>(R.id.overlay_sender).text = sender
        view.findViewById<TextView>(R.id.overlay_app_time).text = "$appLabel · 지금"
        view.findViewById<TextView>(R.id.overlay_warning_line).text =
            WarningCopy.notificationWarningLine()
        view.findViewById<TextView>(R.id.overlay_message_preview).apply {
            visibility = if (body.isNotEmpty()) View.VISIBLE else View.GONE
            text = if (body.isNotEmpty()) TimeFormatters.truncatePreview(body) else ""
        }
        view.findViewById<TextView>(R.id.overlay_url).text = url
        view.findViewById<TextView>(R.id.overlay_detected_at).text = "탐지 시각  $detectedAt"
        view.findViewById<TextView>(R.id.overlay_quip).text = DetectionQuips.random()
        loadOverlayAd(appCtx, view)

        val dismiss = { dismiss(appCtx) }
        view.findViewById<TextView>(R.id.overlay_dismiss).setOnClickListener { dismiss() }
        view.findViewById<ImageButton>(R.id.overlay_close).setOnClickListener { dismiss() }
        view.findViewById<TextView>(R.id.overlay_open_app).setOnClickListener {
            val launch = appCtx.packageManager.getLaunchIntentForPackage(appCtx.packageName)
            launch?.putExtra(MainActivity.EXTRA_OPEN_TIMELINE, true)
            launch?.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP,
            )
            if (launch != null) appCtx.startActivity(launch)
            dismiss()
        }
        return view
    }

    private fun loadOverlayAd(appCtx: Context, view: View) {
        val container = view.findViewById<View>(R.id.overlay_ad_container) ?: return
        val image = view.findViewById<ImageView>(R.id.overlay_ad_image) ?: return
        OverlayAdLoader.loadInto(appCtx, container, image)
    }

    /**
     * 좌상단 앱 아이콘 배지.
     * - 카카오/텔레그램/LINE/문자: 자체 trademark 회피용 Material-style vector
     *   (drawable/ic_app_*) 를 ImageView 로 표시.
     * - 그 외(browser·unknown): 한글 라벨을 TextView 로 표시 ("웹" 등).
     */
    private fun bindAppIcon(view: View, source: String) {
        val text = view.findViewById<TextView>(R.id.overlay_app_icon)
        val image = view.findViewById<ImageView>(R.id.overlay_app_icon_image)
        val bg = circleDrawable(iconColorForSource(source))
        val iconRes = iconResForSource(source)
        if (iconRes != null) {
            text.visibility = View.GONE
            image.apply {
                visibility = View.VISIBLE
                setImageResource(iconRes)
                background = bg
            }
        } else {
            image.visibility = View.GONE
            text.apply {
                visibility = View.VISIBLE
                this.text = iconLetterForSource(source)
                background = bg
            }
        }
    }

    private fun iconResForSource(source: String): Int? = when (source) {
        "kakao" -> R.drawable.ic_app_kakao
        "telegram" -> R.drawable.ic_app_telegram
        "line" -> R.drawable.ic_app_line
        "sms", "sms_notif", "sms_db" -> R.drawable.ic_app_sms
        else -> null
    }

    private fun circleDrawable(color: Int): GradientDrawable =
        GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(color)
        }

    private fun appLabelForSource(source: String): String = when (source) {
        "kakao" -> "카카오톡"
        "telegram" -> "텔레그램"
        "line" -> "LINE"
        "sms", "sms_notif", "sms_db" -> "문자"
        else -> "알림"
    }

    private fun iconLetterForSource(source: String): String = when (source) {
        "browser" -> "웹"
        else -> "!"
    }

    private fun iconColorForSource(source: String): Int = when (source) {
        "kakao" -> Color.parseColor("#FEE500")
        "telegram" -> Color.parseColor("#29B6F6")
        "line" -> Color.parseColor("#06C755")
        "sms", "sms_notif", "sms_db" -> Color.parseColor("#BBDEFB")
        "browser" -> Color.parseColor("#81C784")
        else -> Color.parseColor("#FFE082")
    }

    private fun dismissImmediate(context: Context) {
        val view = currentView ?: return
        try {
            (context.applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager)
                .removeView(view)
        } catch (_: Exception) {
        }
        currentView = null
    }

    fun dismiss(context: Context) {
        val ctx = context.applicationContext
        autoDismissRunnable?.let {
            handler.removeCallbacks(it)
            autoDismissRunnable = null
        }
        dismissImmediate(ctx)
    }
}
