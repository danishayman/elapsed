package com.example.Elapsed

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit

class TimeSinceMediumWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateMediumWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private data class RowIds(
            val rowId: Int,
            val accentId: Int,
            val titleId: Int,
            val elapsedId: Int
        )

        fun updateMediumWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_medium)

            val rows = listOf(
                RowIds(R.id.row1, R.id.accent1, R.id.title1, R.id.elapsed1),
                RowIds(R.id.row2, R.id.accent2, R.id.title2, R.id.elapsed2),
                RowIds(R.id.row3, R.id.accent3, R.id.title3, R.id.elapsed3),
            )

            // Hide all rows initially
            for (row in rows) {
                views.setViewVisibility(row.rowId, View.GONE)
            }
            views.setViewVisibility(R.id.empty_text, View.GONE)

            try {
                val prefs = context.getSharedPreferences(
                    "HomeWidgetPreferences", Context.MODE_PRIVATE
                )
                val json = prefs.getString("events_json", null)

                if (json != null) {
                    val events = JSONArray(json)
                    val count = minOf(events.length(), 3)

                    if (count == 0) {
                        views.setViewVisibility(R.id.empty_text, View.VISIBLE)
                    } else {
                        val now = LocalDateTime.now()
                        for (i in 0 until count) {
                            val event = events.getJSONObject(i)
                            val title = event.getString("title")
                            val startStr = event.getString("startDateTime")
                            val colorHex = event.optString("colorHex", "#7C3AED")

                            val start = LocalDateTime.parse(startStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
                            val days = ChronoUnit.DAYS.between(start, now)

                            val row = rows[i]
                            views.setViewVisibility(row.rowId, View.VISIBLE)
                            views.setTextViewText(row.titleId, title)
                            views.setTextViewText(row.elapsedId, "${days}d")

                            val color = Color.parseColor(colorHex)
                            views.setInt(row.accentId, "setBackgroundColor", color)
                        }
                    }
                } else {
                    views.setViewVisibility(R.id.empty_text, View.VISIBLE)
                }
            } catch (e: Exception) {
                views.setViewVisibility(R.id.empty_text, View.VISIBLE)
                views.setTextViewText(R.id.empty_text, "Error loading events")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
