package com.example.Elapsed

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
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
                        val colorHex = event.optString("colorHex", "#7C3AED")

                        val start = LocalDateTime.parse(startStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
                        val now = LocalDateTime.now()
                        val totalMinutes = ChronoUnit.MINUTES.between(start, now)
                        val days = totalMinutes / 1440
                        val hours = (totalMinutes % 1440) / 60

                        views.setTextViewText(R.id.event_title, title)
                        views.setTextViewText(R.id.event_elapsed, "${days}d ${hours}h")

                        val color = Color.parseColor(colorHex)
                        views.setInt(R.id.accent_bar, "setBackgroundColor", color)
                    } else {
                        views.setTextViewText(R.id.event_title, "No event selected")
                        views.setTextViewText(R.id.event_elapsed, "—")
                    }
                }
            } catch (e: Exception) {
                views.setTextViewText(R.id.event_title, "No events")
                views.setTextViewText(R.id.event_elapsed, "—")
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
            // Fallback: show first event if no selection saved
            return if (events.length() > 0) events.getJSONObject(0) else null
        }
    }
}
