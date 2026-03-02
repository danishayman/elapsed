package com.example.elapsed

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Color
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
        val emptyMessage = findViewById<TextView>(R.id.empty_message)

        if (events.isEmpty()) {
            emptyMessage.visibility = View.VISIBLE
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
        // Determine the widget provider type from the manager and update accordingly
        // Since we don't know which size, we update all three — only the matching one takes effect
        try {
            TimeSinceSmallWidgetProvider.updateSmallWidget(this, appWidgetManager, widgetId)
        } catch (_: Exception) {}
        try {
            TimeSinceMediumWidgetProvider.updateMediumWidget(this, appWidgetManager, widgetId)
        } catch (_: Exception) {}
        try {
            TimeSinceLargeWidgetProvider.updateLargeWidget(this, appWidgetManager, widgetId)
        } catch (_: Exception) {}
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
            val colorHex = event.optString("colorHex", "#7C3AED")

            view.findViewById<TextView>(R.id.item_title).text = title
            try {
                view.findViewById<View>(R.id.item_accent).setBackgroundColor(
                    Color.parseColor(colorHex)
                )
            } catch (_: Exception) {}

            return view
        }
    }
}
