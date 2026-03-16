package com.example.Elapsed

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.net.Uri
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit
import kotlin.math.roundToInt

object ElapsedWidgetRenderer {
    private const val prefsName = "HomeWidgetPreferences"
    private const val eventsJsonKey = "events_json"

    fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        spec: WidgetSpec,
    ) {
        val layoutRes = when (spec.shape) {
            WidgetShape.SIMPLE -> R.layout.widget_small
            WidgetShape.WIDE -> R.layout.widget_medium
        }

        val views = RemoteViews(context.packageName, layoutRes)
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val event = loadAssignedEvent(prefs, appWidgetId)

        if (event != null) {
            bindEventState(context, views, spec, event)
            val eventId = event.optString("id", "")
            if (eventId.isNotBlank()) {
                views.setOnClickPendingIntent(
                    R.id.widget_root,
                    buildEventPendingIntent(context, appWidgetId, eventId),
                )
            } else {
                views.setOnClickPendingIntent(
                    R.id.widget_root,
                    buildConfigPendingIntent(context, appWidgetId),
                )
            }

            if (spec.variant == WidgetVariant.RESTART) {
                views.setOnClickPendingIntent(
                    R.id.widget_icon_right,
                    buildRestartPendingIntent(context, appWidgetId),
                )
            }
        } else {
            bindUnassignedState(context, views, spec)
            views.setOnClickPendingIntent(
                R.id.widget_root,
                buildConfigPendingIntent(context, appWidgetId),
            )

            if (spec.variant == WidgetVariant.RESTART) {
                views.setOnClickPendingIntent(
                    R.id.widget_icon_right,
                    buildConfigPendingIntent(context, appWidgetId),
                )
            }
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    fun updateWidgetById(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        val className = appWidgetManager.getAppWidgetInfo(appWidgetId)?.provider?.className
        val spec = WidgetSpecs.fromProviderClassName(className) ?: return
        updateWidget(context, appWidgetManager, appWidgetId, spec)
    }

    fun clearSelection(context: Context, appWidgetId: Int) {
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        prefs.edit().remove(selectionKey(appWidgetId)).apply()
    }

    fun restartAssignedEventForWidget(context: Context, appWidgetId: Int): Boolean {
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val selectedEventId = prefs.getString(selectionKey(appWidgetId), null) ?: return false
        val json = prefs.getString(eventsJsonKey, null) ?: return false

        return try {
            val events = JSONArray(json)
            var changed = false
            for (i in 0 until events.length()) {
                val event = events.getJSONObject(i)
                if (event.optString("id") == selectedEventId) {
                    val oldStart = event.optString("startDateTime", "")
                    val history = event.optJSONArray("resetHistory") ?: JSONArray()
                    if (oldStart.isNotBlank()) {
                        history.put(oldStart)
                    }

                    event.put(
                        "startDateTime",
                        LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
                    )
                    event.put("resetHistory", history)
                    event.put("isStopped", false)
                    event.remove("stoppedElapsedSeconds")
                    changed = true
                    break
                }
            }

            if (changed) {
                prefs.edit().putString(eventsJsonKey, events.toString()).apply()
            }
            changed
        } catch (_: Exception) {
            false
        }
    }

    private fun loadAssignedEvent(
        prefs: android.content.SharedPreferences,
        appWidgetId: Int,
    ): JSONObject? {
        val selectedEventId = prefs.getString(selectionKey(appWidgetId), null) ?: return null
        val json = prefs.getString(eventsJsonKey, null) ?: return null

        return try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                val event = arr.getJSONObject(i)
                if (event.optString("id") == selectedEventId) {
                    return event
                }
            }
            null
        } catch (_: Exception) {
            null
        }
    }

    private fun bindEventState(
        context: Context,
        views: RemoteViews,
        spec: WidgetSpec,
        event: JSONObject,
    ) {
        val title = event.optString("title", "An unnamed timer").ifBlank { "An unnamed timer" }
        val color = parseColor(event.optString("colorHex", "#66A8FF"), Color.parseColor("#66A8FF"))
        val elapsedSeconds = computeElapsedSeconds(event)
        val selectedFormat = event.optString("timeFormat", "Hours, minutes and seconds")
        val isStopped = event.optBoolean("isStopped", false)
        val display = buildElapsedDisplay(elapsedSeconds, selectedFormat, !isStopped)

        val style = styleFor(spec, color)
        applyStyle(context, views, spec, style)

        if (display.useChronometer) {
            views.setViewVisibility(R.id.event_elapsed, View.GONE)
            views.setViewVisibility(R.id.event_chronometer, View.VISIBLE)
            views.setChronometer(
                R.id.event_chronometer,
                display.chronometerBaseMs,
                display.chronometerFormat,
                display.chronometerRunning,
            )
        } else {
            views.setViewVisibility(R.id.event_chronometer, View.GONE)
            views.setViewVisibility(R.id.event_elapsed, View.VISIBLE)
            views.setTextViewText(R.id.event_elapsed, display.text)
        }

        views.setTextViewText(R.id.event_title, title)
    }

    private fun bindUnassignedState(
        context: Context,
        views: RemoteViews,
        spec: WidgetSpec,
    ) {
        val style = styleFor(spec, Color.parseColor("#3A3A3A"), unassigned = true)
        applyStyle(context, views, spec, style)

        views.setViewVisibility(R.id.event_chronometer, View.GONE)
        views.setViewVisibility(R.id.event_elapsed, View.VISIBLE)
        views.setTextViewText(R.id.event_elapsed, "Select timer")
        views.setTextViewText(R.id.event_title, "Tap to choose")
    }

    private fun applyStyle(
        context: Context,
        views: RemoteViews,
        spec: WidgetSpec,
        style: WidgetStyle,
    ) {
        views.setImageViewBitmap(
            R.id.widget_container_bg,
            createRoundedBackgroundBitmap(context, spec.shape, style.containerColor),
        )

        views.setViewVisibility(R.id.widget_icon_left, if (style.showLeftIcon) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_icon_right, if (style.showRightIcon) View.VISIBLE else View.GONE)

        views.setImageViewResource(R.id.widget_icon_left, R.drawable.ic_widget_timer)
        views.setImageViewResource(R.id.widget_icon_right, R.drawable.ic_widget_restart)
        views.setInt(R.id.widget_icon_left, "setColorFilter", style.iconColor)
        views.setInt(R.id.widget_icon_right, "setColorFilter", style.iconColor)

        views.setTextColor(R.id.event_elapsed, style.elapsedTextColor)
        views.setTextColor(R.id.event_chronometer, style.elapsedTextColor)
        views.setTextColor(R.id.event_title, style.titleTextColor)
        views.setInt(R.id.event_elapsed, "setBackgroundResource", style.badgeRes)
        views.setInt(R.id.event_chronometer, "setBackgroundResource", style.badgeRes)

        val horizontalPadding = dp(context, style.badgeHorizontalPaddingDp)
        val verticalPadding = dp(context, style.badgeVerticalPaddingDp)
        views.setViewPadding(
            R.id.event_elapsed,
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
        )
        views.setViewPadding(
            R.id.event_chronometer,
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
        )
    }

    private fun styleFor(
        spec: WidgetSpec,
        eventColor: Int,
        unassigned: Boolean = false,
    ): WidgetStyle {
        val textOnColor = contrastColor(eventColor)
        val titleOnColor = withAlpha(textOnColor, 0.92f)

        return when (spec.variant) {
            WidgetVariant.SIMPLE -> {
                val color = if (unassigned) Color.parseColor("#3A3A3A") else eventColor
                val text = if (unassigned) Color.WHITE else contrastColor(color)
                WidgetStyle(
                    containerColor = color,
                    showLeftIcon = false,
                    showRightIcon = false,
                    iconColor = text,
                    elapsedTextColor = text,
                    titleTextColor = withAlpha(text, 0.92f),
                    badgeRes = R.drawable.widget_badge_clear,
                    badgeHorizontalPaddingDp = 0,
                    badgeVerticalPaddingDp = 0,
                )
            }

            WidgetVariant.RESTART -> {
                val color = if (unassigned) Color.parseColor("#2F2F2F") else eventColor
                val text = if (unassigned) Color.WHITE else contrastColor(color)
                WidgetStyle(
                    containerColor = color,
                    showLeftIcon = false,
                    showRightIcon = true,
                    iconColor = text,
                    elapsedTextColor = text,
                    titleTextColor = withAlpha(text, 0.92f),
                    badgeRes = R.drawable.widget_badge_clear,
                    badgeHorizontalPaddingDp = 0,
                    badgeVerticalPaddingDp = 0,
                )
            }

            WidgetVariant.STANDARD -> {
                val color = if (unassigned) Color.parseColor("#2F2F2F") else eventColor
                val text = if (unassigned) Color.WHITE else textOnColor
                WidgetStyle(
                    containerColor = color,
                    showLeftIcon = true,
                    showRightIcon = false,
                    iconColor = text,
                    elapsedTextColor = text,
                    titleTextColor = if (unassigned) withAlpha(text, 0.92f) else titleOnColor,
                    badgeRes = R.drawable.widget_badge_clear,
                    badgeHorizontalPaddingDp = 0,
                    badgeVerticalPaddingDp = 0,
                )
            }

            WidgetVariant.TRANSPARENT_BLACK -> {
                WidgetStyle(
                    containerColor = Color.argb(176, 24, 24, 24),
                    showLeftIcon = true,
                    showRightIcon = false,
                    iconColor = Color.WHITE,
                    elapsedTextColor = Color.BLACK,
                    titleTextColor = Color.WHITE,
                    badgeRes = R.drawable.widget_badge_light,
                    badgeHorizontalPaddingDp = 6,
                    badgeVerticalPaddingDp = 2,
                )
            }

            WidgetVariant.TRANSPARENT_WHITE -> {
                WidgetStyle(
                    containerColor = Color.argb(180, 230, 230, 230),
                    showLeftIcon = true,
                    showRightIcon = false,
                    iconColor = Color.BLACK,
                    elapsedTextColor = Color.WHITE,
                    titleTextColor = Color.BLACK,
                    badgeRes = R.drawable.widget_badge_dark,
                    badgeHorizontalPaddingDp = 6,
                    badgeVerticalPaddingDp = 2,
                )
            }
        }
    }

    private fun createRoundedBackgroundBitmap(
        context: Context,
        shape: WidgetShape,
        color: Int,
    ): Bitmap {
        val (widthDp, heightDp, radiusDp) = when (shape) {
            WidgetShape.SIMPLE -> Triple(144, 82, 22f)
            WidgetShape.WIDE -> Triple(304, 70, 22f)
        }

        val width = dp(context, widthDp)
        val height = dp(context, heightDp)
        val radius = dpFloat(context, radiusDp)

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
        }
        val rect = RectF(0f, 0f, width.toFloat(), height.toFloat())
        canvas.drawRoundRect(rect, radius, radius, paint)
        return bitmap
    }

    private fun computeElapsedSeconds(event: JSONObject): Long {
        val isStopped = event.optBoolean("isStopped", false)
        val stopped = if (event.has("stoppedElapsedSeconds")) event.optLong("stoppedElapsedSeconds") else null

        if (isStopped && stopped != null) {
            return stopped.coerceAtLeast(0L)
        }

        val startString = event.optString("startDateTime", "")
        if (startString.isBlank()) return 0L

        return try {
            val start = LocalDateTime.parse(startString, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
            ChronoUnit.SECONDS.between(start, LocalDateTime.now()).coerceAtLeast(0L)
        } catch (_: Exception) {
            0L
        }
    }

    private fun buildElapsedDisplay(
        elapsedSeconds: Long,
        selectedFormat: String,
        isRunning: Boolean,
    ): ElapsedDisplay {
        val totalMinutes = elapsedSeconds / 60
        val days = totalMinutes / 1440
        val hoursInDay = (totalMinutes % 1440) / 60
        val minutesInHour = totalMinutes % 60
        val seconds = elapsedSeconds % 60

        return when (selectedFormat) {
            "Years" -> {
                val years = days / 365
                val remainingDays = days % 365
                ElapsedDisplay(text = "${years}y ${remainingDays}d")
            }

            "Months" -> {
                val months = days / 30
                val remainingDays = days % 30
                ElapsedDisplay(text = "${months}m ${remainingDays}d")
            }

            "Weeks" -> {
                val weeks = days / 7
                val remainingDays = days % 7
                ElapsedDisplay(text = "${weeks}w ${remainingDays}d")
            }

            "Hours, minutes and seconds" -> {
                ElapsedDisplay(
                    useChronometer = true,
                    chronometerBaseMs = SystemClock.elapsedRealtime() - (elapsedSeconds * 1000),
                    chronometerFormat = "%s",
                    chronometerRunning = isRunning,
                )
            }

            "Days" -> {
                val secondsInCurrentDay = elapsedSeconds % (24 * 3600)
                ElapsedDisplay(
                    useChronometer = true,
                    chronometerBaseMs = SystemClock.elapsedRealtime() - (secondsInCurrentDay * 1000),
                    chronometerFormat = "${days}d %s",
                    chronometerRunning = isRunning,
                )
            }

            else -> {
                val hh = hoursInDay.toString().padStart(2, '0')
                val mm = minutesInHour.toString().padStart(2, '0')
                val ss = seconds.toString().padStart(2, '0')
                ElapsedDisplay(text = if (days > 0) "${days}d $hh:$mm:$ss" else "$hh:$mm:$ss")
            }
        }
    }

    private fun buildEventPendingIntent(
        context: Context,
        appWidgetId: Int,
        eventId: String,
    ): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = Uri.parse("elapsed://event/$eventId")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            context,
            appWidgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun buildConfigPendingIntent(context: Context, appWidgetId: Int): PendingIntent {
        val intent = Intent(context, WidgetConfigActivity::class.java).apply {
            action = "com.example.Elapsed.CONFIGURE_WIDGET.$appWidgetId"
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }

        return PendingIntent.getActivity(
            context,
            appWidgetId + 100000,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun buildRestartPendingIntent(context: Context, appWidgetId: Int): PendingIntent {
        val intent = Intent(context, WidgetRestartProvider::class.java).apply {
            action = ElapsedBaseWidgetProvider.ACTION_WIDGET_RESTART
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }

        return PendingIntent.getBroadcast(
            context,
            appWidgetId + 200000,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun contrastColor(color: Int): Int {
        val r = Color.red(color) / 255.0
        val g = Color.green(color) / 255.0
        val b = Color.blue(color) / 255.0
        val luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return if (luminance > 0.5) Color.BLACK else Color.WHITE
    }

    private fun withAlpha(color: Int, alpha: Float): Int {
        val a = (255 * alpha.coerceIn(0f, 1f)).roundToInt()
        return Color.argb(a, Color.red(color), Color.green(color), Color.blue(color))
    }

    private fun parseColor(hex: String, fallback: Int): Int {
        return try {
            Color.parseColor(hex)
        } catch (_: Exception) {
            fallback
        }
    }

    private fun dp(context: Context, value: Int): Int {
        return (value * context.resources.displayMetrics.density).roundToInt()
    }

    private fun dpFloat(context: Context, value: Float): Float {
        return value * context.resources.displayMetrics.density
    }

    private fun selectionKey(appWidgetId: Int): String {
        return "widget_${appWidgetId}_event_id"
    }

    private data class WidgetStyle(
        val containerColor: Int,
        val showLeftIcon: Boolean,
        val showRightIcon: Boolean,
        val iconColor: Int,
        val elapsedTextColor: Int,
        val titleTextColor: Int,
        val badgeRes: Int,
        val badgeHorizontalPaddingDp: Int,
        val badgeVerticalPaddingDp: Int,
    )

    private data class ElapsedDisplay(
        val text: String = "",
        val useChronometer: Boolean = false,
        val chronometerBaseMs: Long = 0L,
        val chronometerFormat: String? = null,
        val chronometerRunning: Boolean = false,
    )
}
