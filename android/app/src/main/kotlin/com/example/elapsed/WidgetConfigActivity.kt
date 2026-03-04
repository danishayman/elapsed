package com.example.elapsed

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.ListView
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject

class WidgetConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private val events = mutableListOf<JSONObject>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Light status bar with white background
        window.statusBarColor = Color.WHITE
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR or
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        )

        // Default result = CANCELED so backing out cancels widget placement
        setResult(RESULT_CANCELED)

        // Get the widget ID from the intent
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        setContentView(R.layout.activity_widget_config)

        loadEvents()

        val listView = findViewById<ListView>(R.id.events_list)
        val emptyState = findViewById<View>(R.id.empty_state)

        if (events.isEmpty()) {
            emptyState.visibility = View.VISIBLE
            listView.visibility = View.GONE
            return
        }

        listView.adapter = EventAdapter()
        listView.setOnItemClickListener { _, _, position, _ ->
            val selectedEvent = events[position]
            val eventId = selectedEvent.getString("id")

            // Save the selected event ID for this widget instance
            val prefs = getSharedPreferences("HomeWidgetPreferences", MODE_PRIVATE)
            prefs.edit().putString("widget_${appWidgetId}_event_id", eventId).apply()

            // Update the widget immediately
            val appWidgetManager = AppWidgetManager.getInstance(this)
            updateWidgetById(appWidgetManager, appWidgetId)

            // Return success
            val resultValue = Intent()
            resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            setResult(RESULT_OK, resultValue)
            finish()
        }
    }

    private fun loadEvents() {
        val prefs = getSharedPreferences("HomeWidgetPreferences", MODE_PRIVATE)
        val json = prefs.getString("events_json", null) ?: return

        try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                events.add(arr.getJSONObject(i))
            }
        } catch (_: Exception) {}
    }

    private fun updateWidgetById(appWidgetManager: AppWidgetManager, widgetId: Int) {
        val info = appWidgetManager.getAppWidgetInfo(widgetId) ?: return
        val providerName = info.provider?.className ?: return
        when {
            providerName.contains("Small") ->
                TimeSinceSmallWidgetProvider.updateSmallWidget(this, appWidgetManager, widgetId)
            providerName.contains("Medium") ->
                TimeSinceMediumWidgetProvider.updateMediumWidget(this, appWidgetManager, widgetId)
            providerName.contains("Large") ->
                TimeSinceLargeWidgetProvider.updateLargeWidget(this, appWidgetManager, widgetId)
        }
    }

    private inner class EventAdapter : BaseAdapter() {
        override fun getCount(): Int = events.size
        override fun getItem(position: Int): Any = events[position]
        override fun getItemId(position: Int): Long = position.toLong()

        override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
            val view = convertView ?: layoutInflater.inflate(
                R.layout.widget_config_item, parent, false
            )

            val event = events[position]
            val title = event.getString("title")
            val colorHex = event.optString("colorHex", "#007BFF")

            view.findViewById<TextView>(R.id.item_title).text = title

            try {
                val accentView = view.findViewById<TextView>(R.id.item_accent)
                val color = Color.parseColor(colorHex)

                // Create a rounded badge background
                val badge = GradientDrawable()
                badge.shape = GradientDrawable.RECTANGLE
                badge.cornerRadius = 6f * resources.displayMetrics.density
                badge.setColor(color)
                accentView.background = badge

                // Determine text color based on luminance
                val r = Color.red(color) / 255.0
                val g = Color.green(color) / 255.0
                val b = Color.blue(color) / 255.0
                val luminance = 0.299 * r + 0.587 * g + 0.114 * b
                accentView.setTextColor(if (luminance > 0.4) Color.BLACK else Color.WHITE)
            } catch (_: Exception) {}

            return view
        }
    }
}
