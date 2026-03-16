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
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDateTime
import java.time.OffsetDateTime
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
        val layoutRes = when (spec.size) {
            WidgetSize.SMALL -> R.layout.widget_small
            WidgetSize.MEDIUM -> R.layout.widget_medium
            WidgetSize.LARGE -> R.layout.widget_large
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
        } else {
            bindUnassignedState(context, views, spec)
            views.setOnClickPendingIntent(
                R.id.widget_root,
                buildConfigPendingIntent(context, appWidgetId),
            )
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
        val color = parseColor(event.optString("colorHex", "#66A8FF"), fallback = Color.parseColor("#66A8FF"))
        val elapsedSeconds = computeElapsedSeconds(event)
        val elapsedText = formatElapsed(elapsedSeconds, spec.size)

        val style = styleFor(spec, eventColor = color)
        applyStyle(context, views, spec, style)

        views.setTextViewText(R.id.event_elapsed, elapsedText)
        views.setTextViewText(R.id.event_title, title)
    }

    private fun bindUnassignedState(
        context: Context,
        views: RemoteViews,
        spec: WidgetSpec,
    ) {
        val style = styleFor(spec, eventColor = Color.parseColor("#3A3A3A"), unassigned = true)
        applyStyle(context, views, spec, style)

        views.setTextViewText(R.id.event_elapsed, "Select timer")
        views.setTextViewText(R.id.event_title, "Tap to choose a timer")
    }

    private fun applyStyle(
        context: Context,
        views: RemoteViews,
        spec: WidgetSpec,
        style: WidgetStyle,
    ) {
        val backgroundBitmap = createRoundedBackgroundBitmap(context, spec.size, style.containerColor)
        views.setImageViewBitmap(R.id.widget_container_bg, backgroundBitmap)

        views.setViewVisibility(R.id.widget_icon_left, if (style.showLeftIcon) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_icon_right, if (style.showRightIcon) View.VISIBLE else View.GONE)

        views.setImageViewResource(R.id.widget_icon_left, style.leftIconRes)
        views.setImageViewResource(R.id.widget_icon_right, style.rightIconRes)
        views.setInt(R.id.widget_icon_left, "setColorFilter", style.leftIconColor)
        views.setInt(R.id.widget_icon_right, "setColorFilter", style.rightIconColor)

        views.setTextColor(R.id.event_elapsed, style.elapsedTextColor)
        views.setTextColor(R.id.event_title, style.titleTextColor)
        views.setInt(R.id.event_elapsed, "setBackgroundResource", style.elapsedBadgeRes)

        val horizontalPadding = dp(context, style.elapsedHorizontalPaddingDp)
        val verticalPadding = dp(context, style.elapsedVerticalPaddingDp)
        views.setViewPadding(
            R.id.event_elapsed,
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
        val contrastText = contrastColor(eventColor)
        val titleOnColor = withAlpha(contrastText, 0.9f)

        return when (spec.variant) {
            WidgetVariant.RESTART -> {
                val color = if (unassigned) Color.parseColor("#2E2E2E") else eventColor
                val text = if (unassigned) Color.WHITE else contrastColor(color)
                WidgetStyle(
                    containerColor = color,
                    showLeftIcon = false,
                    showRightIcon = true,
                    leftIconRes = R.drawable.ic_widget_timer,
                    rightIconRes = R.drawable.ic_widget_restart,
                    leftIconColor = text,
                    rightIconColor = text,
                    elapsedTextColor = text,
                    titleTextColor = withAlpha(text, 0.9f),
                    elapsedBadgeRes = R.drawable.widget_badge_clear,
                    elapsedHorizontalPaddingDp = 0,
                    elapsedVerticalPaddingDp = 0,
                )
            }

            WidgetVariant.STANDARD -> {
                val color = if (unassigned) Color.parseColor("#2E2E2E") else eventColor
                val text = if (unassigned) Color.WHITE else contrastText
                WidgetStyle(
                    containerColor = color,
                    showLeftIcon = true,
                    showRightIcon = false,
                    leftIconRes = R.drawable.ic_widget_timer,
                    rightIconRes = R.drawable.ic_widget_restart,
                    leftIconColor = text,
                    rightIconColor = text,
                    elapsedTextColor = text,
                    titleTextColor = if (unassigned) withAlpha(text, 0.9f) else titleOnColor,
                    elapsedBadgeRes = R.drawable.widget_badge_clear,
                    elapsedHorizontalPaddingDp = 0,
                    elapsedVerticalPaddingDp = 0,
                )
            }

            WidgetVariant.TRANSPARENT_BLACK -> {
                WidgetStyle(
                    containerColor = Color.argb(176, 20, 20, 20),
                    showLeftIcon = true,
                    showRightIcon = false,
                    leftIconRes = R.drawable.ic_widget_timer,
                    rightIconRes = R.drawable.ic_widget_restart,
                    leftIconColor = Color.WHITE,
                    rightIconColor = Color.WHITE,
                    elapsedTextColor = Color.BLACK,
                    titleTextColor = withAlpha(Color.WHITE, if (unassigned) 0.95f else 1f),
                    elapsedBadgeRes = R.drawable.widget_badge_light,
                    elapsedHorizontalPaddingDp = 8,
                    elapsedVerticalPaddingDp = 3,
                )
            }

            WidgetVariant.TRANSPARENT_WHITE -> {
                WidgetStyle(
                    containerColor = Color.argb(188, 245, 245, 245),
                    showLeftIcon = true,
                    showRightIcon = false,
                    leftIconRes = R.drawable.ic_widget_timer,
                    rightIconRes = R.drawable.ic_widget_restart,
                    leftIconColor = Color.BLACK,
                    rightIconColor = Color.BLACK,
                    elapsedTextColor = Color.WHITE,
                    titleTextColor = withAlpha(Color.BLACK, if (unassigned) 0.9f else 1f),
                    elapsedBadgeRes = R.drawable.widget_badge_dark,
                    elapsedHorizontalPaddingDp = 8,
                    elapsedVerticalPaddingDp = 3,
                )
            }
        }
    }

    private fun createRoundedBackgroundBitmap(
        context: Context,
        size: WidgetSize,
        color: Int,
    ): Bitmap {
        val (widthDp, heightDp, radiusDp) = when (size) {
            WidgetSize.SMALL -> Triple(220, 72, 22f)
            WidgetSize.MEDIUM -> Triple(360, 112, 24f)
            WidgetSize.LARGE -> Triple(500, 148, 28f)
        }

        val width = dp(context, widthDp)
        val height = dp(context, heightDp)
        val radius = dpFloat(context, radiusDp)

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color }
        val rect = RectF(0f, 0f, width.toFloat(), height.toFloat())
        canvas.drawRoundRect(rect, radius, radius, paint)
        return bitmap
    }

    private fun computeElapsedSeconds(event: JSONObject): Long {
        val isStopped = event.optBoolean("isStopped", false)
        val stoppedElapsed = if (event.has("stoppedElapsedSeconds")) {
            event.optLong("stoppedElapsedSeconds", 0)
        } else {
            null
        }

        if (isStopped && stoppedElapsed != null) {
            return stoppedElapsed.coerceAtLeast(0)
        }

        val startString = event.optString("startDateTime", "")
        val start = parseDateTime(startString) ?: return 0L
        val now = LocalDateTime.now()
        return ChronoUnit.SECONDS.between(start, now).coerceAtLeast(0)
    }

    private fun parseDateTime(value: String): LocalDateTime? {
        if (value.isBlank()) return null
        return try {
            LocalDateTime.parse(value, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
        } catch (_: Exception) {
            try {
                OffsetDateTime.parse(value, DateTimeFormatter.ISO_OFFSET_DATE_TIME).toLocalDateTime()
            } catch (_: Exception) {
                null
            }
        }
    }

    private fun formatElapsed(elapsedSeconds: Long, size: WidgetSize): String {
        val totalMinutes = elapsedSeconds / 60
        val days = totalMinutes / 1440
        val hours = (totalMinutes % 1440) / 60
        val minutes = totalMinutes % 60

        return when (size) {
            WidgetSize.SMALL -> "${days}d ${hours}h"
            WidgetSize.MEDIUM,
            WidgetSize.LARGE,
            -> "${days}d ${hours}h ${minutes}m"
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

    private fun buildConfigPendingIntent(
        context: Context,
        appWidgetId: Int,
    ): PendingIntent {
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

    private fun parseColor(hex: String, fallback: Int): Int {
        return try {
            Color.parseColor(hex)
        } catch (_: Exception) {
            fallback
        }
    }

    private fun withAlpha(color: Int, alpha: Float): Int {
        val normalized = alpha.coerceIn(0f, 1f)
        val a = (255 * normalized).roundToInt()
        return Color.argb(a, Color.red(color), Color.green(color), Color.blue(color))
    }

    private fun contrastColor(color: Int): Int {
        val r = Color.red(color) / 255.0
        val g = Color.green(color) / 255.0
        val b = Color.blue(color) / 255.0
        val luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return if (luminance > 0.5) Color.BLACK else Color.WHITE
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
        val leftIconRes: Int,
        val rightIconRes: Int,
        val leftIconColor: Int,
        val rightIconColor: Int,
        val elapsedTextColor: Int,
        val titleTextColor: Int,
        val elapsedBadgeRes: Int,
        val elapsedHorizontalPaddingDp: Int,
        val elapsedVerticalPaddingDp: Int,
    )
}
