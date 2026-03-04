package com.example.Elapsed

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit

class TimeSinceSmallWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateSmallWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateSmallWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_small)

            try {
                val prefs = context.getSharedPreferences(
                    "HomeWidgetPreferences", Context.MODE_PRIVATE
                )
                val json = prefs.getString("events_json", null)

                if (json != null) {
                    val events = JSONArray(json)
                    val event = findEventForWidget(prefs, appWidgetId, events)

                    if (event != null) {
                        val title = event.getString("title")
                        val startStr = event.getString("startDateTime")
                        val colorHex = event.optString("colorHex", "#007BFF")
                        val isStopped = event.optBoolean("isStopped", false)
                        val stoppedSecs = if (event.has("stoppedElapsedSeconds"))
                            event.getInt("stoppedElapsedSeconds") else null

                        val elapsed = if (isStopped && stoppedSecs != null) {
                            stoppedSecs.toLong()
                        } else {
                            val start = LocalDateTime.parse(startStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
                            val now = LocalDateTime.now()
                            ChronoUnit.MINUTES.between(start, now) * 60
                        }

                        val totalMinutes = elapsed / 60
                        val days = totalMinutes / 1440
                        val hours = (totalMinutes % 1440) / 60

                        views.setTextViewText(R.id.event_title, title)
                        views.setTextViewText(R.id.event_elapsed, "${days}d ${hours}h")

                        // Set entire widget background to event color
                        val color = Color.parseColor(colorHex)
                        views.setInt(R.id.widget_root, "setBackgroundColor", color)

                        // Determine text color based on luminance
                        val r = Color.red(color) / 255.0
                        val g = Color.green(color) / 255.0
                        val b = Color.blue(color) / 255.0
                        val luminance = 0.299 * r + 0.587 * g + 0.114 * b
                        val textColor = if (luminance > 0.5) Color.BLACK else Color.WHITE
                        val subTextColor = if (luminance > 0.5) 0xDD000000.toInt() else 0xDDFFFFFF.toInt()

                        views.setTextColor(R.id.event_elapsed, textColor)
                        views.setTextColor(R.id.event_title, subTextColor)
                        views.setInt(R.id.widget_icon, "setColorFilter", textColor)
                    } else {
                        views.setTextViewText(R.id.event_title, "No event selected")
                        views.setTextViewText(R.id.event_elapsed, "—")
                    }
                }
            } catch (e: Exception) {
                views.setTextViewText(R.id.event_title, "No events")
                views.setTextViewText(R.id.event_elapsed, "—")
            }

            // Set click intent to open event details
            val eventId = try {
                val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
                val json = prefs.getString("events_json", null)
                if (json != null) {
                    val events = JSONArray(json)
                    findEventForWidget(prefs, appWidgetId, events)?.getString("id")
                } else null
            } catch (_: Exception) { null }

            if (eventId != null) {
                val intent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                    data = Uri.parse("elapsed://event/$eventId")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context, appWidgetId, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun findEventForWidget(
            prefs: android.content.SharedPreferences,
            appWidgetId: Int,
            events: JSONArray
        ): JSONObject? {
            val savedId = prefs.getString("widget_${appWidgetId}_event_id", null)
            if (savedId != null) {
                for (i in 0 until events.length()) {
                    val event = events.getJSONObject(i)
                    if (event.getString("id") == savedId) {
                        return event
                    }
                }
            }
            return if (events.length() > 0) events.getJSONObject(0) else null
        }
    }
}