package com.example.elapsed

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews
import org.json.JSONArray
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit

class TimeSinceLargeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateLargeWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateLargeWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_large)

            try {
                val prefs = context.getSharedPreferences(
                    "HomeWidgetPreferences", Context.MODE_PRIVATE
                )
                val json = prefs.getString("events_json", null)

                if (json != null) {
                    val events = JSONArray(json)
                    if (events.length() > 0) {
                        val event = events.getJSONObject(0)
                        val title = event.getString("title")
                        val startStr = event.getString("startDateTime")
                        val colorHex = event.optString("colorHex", "#7C3AED")

                        val start = LocalDateTime.parse(startStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
                        val now = LocalDateTime.now()
                        val totalMinutes = ChronoUnit.MINUTES.between(start, now)
                        val days = totalMinutes / 1440
                        val hours = (totalMinutes % 1440) / 60
                        val minutes = totalMinutes % 60

                        views.setTextViewText(R.id.event_title, title)
                        views.setTextViewText(R.id.days_count, "$days")
                        views.setTextViewText(
                            R.id.days_label,
                            if (days == 1L) "day" else "days"
                        )
                        views.setTextViewText(
                            R.id.event_subtitle,
                            "${days}d ${hours}h ${minutes}m"
                        )

                        val color = Color.parseColor(colorHex)
                        views.setInt(R.id.accent_bar, "setBackgroundColor", color)
                    }
                }
            } catch (e: Exception) {
                views.setTextViewText(R.id.event_title, "No events")
                views.setTextViewText(R.id.days_count, "—")
                views.setTextViewText(R.id.days_label, "")
                views.setTextViewText(R.id.event_subtitle, "Add events in the app")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
