package com.example.Elapsed

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.ImageView
import android.widget.ListView
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject

class WidgetConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private val events = mutableListOf<JSONObject>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.statusBarColor = Color.WHITE
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            )

        // Backing out or closing the screen should cancel widget placement.
        setResult(RESULT_CANCELED)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        setContentView(R.layout.activity_widget_config)

        findViewById<ImageView>(R.id.close_button).setOnClickListener {
            finish()
        }

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
            val eventId = selectedEvent.optString("id", "")
            if (eventId.isBlank()) return@setOnItemClickListener

            val prefs = getSharedPreferences("HomeWidgetPreferences", MODE_PRIVATE)
            prefs.edit().putString("widget_${appWidgetId}_event_id", eventId).apply()

            // Update the widget immediately
            val appWidgetManager = AppWidgetManager.getInstance(this)
            ElapsedWidgetRenderer.updateWidgetById(this, appWidgetManager, appWidgetId)

            val result = Intent()
            result.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            setResult(RESULT_OK, result)
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

    private inner class EventAdapter : BaseAdapter() {
        override fun getCount(): Int = events.size
        override fun getItem(position: Int): Any = events[position]
        override fun getItemId(position: Int): Long = position.toLong()

        override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
            val view = convertView ?: layoutInflater.inflate(
                R.layout.widget_config_item,
                parent,
                false,
            )

            val event = events[position]
            val title = event.optString("title", "An unnamed timer").ifBlank { "An unnamed timer" }
            val colorHex = event.optString("colorHex", "#66A8FF")

            val badgeView = view.findViewById<TextView>(R.id.item_badge)
            badgeView.text = title

            try {
                val color = Color.parseColor(colorHex)
                val pill = GradientDrawable().apply {
                    shape = GradientDrawable.RECTANGLE
                    cornerRadius = 24f * resources.displayMetrics.density
                    setColor(color)
                }
                badgeView.background = pill

                val r = Color.red(color) / 255.0
                val g = Color.green(color) / 255.0
                val b = Color.blue(color) / 255.0
                val luminance = 0.299 * r + 0.587 * g + 0.114 * b
                badgeView.setTextColor(if (luminance > 0.5) Color.BLACK else Color.WHITE)
            } catch (_: Exception) {
                badgeView.setTextColor(Color.BLACK)
            }

            return view
        }
    }
}
