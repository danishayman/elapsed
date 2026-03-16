package com.example.Elapsed

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent

abstract class ElapsedBaseWidgetProvider(
    private val spec: WidgetSpec,
) : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_WIDGET_RESTART) {
            val appWidgetId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID,
            )
            if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return

            val changed = ElapsedWidgetRenderer.restartAssignedEventForWidget(context, appWidgetId)
            if (!changed) return

            val manager = AppWidgetManager.getInstance(context)
            refreshAllWidgets(context, manager)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            ElapsedWidgetRenderer.updateWidget(context, appWidgetManager, appWidgetId, spec)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        for (appWidgetId in appWidgetIds) {
            ElapsedWidgetRenderer.clearSelection(context, appWidgetId)
        }
    }

    companion object {
        const val ACTION_WIDGET_RESTART = "com.example.Elapsed.ACTION_WIDGET_RESTART"

        private fun refreshAllWidgets(context: Context, appWidgetManager: AppWidgetManager) {
            updateByProvider(
                context,
                appWidgetManager,
                WidgetSimpleProvider::class.java,
                WidgetSpecs.simple,
            )
            updateByProvider(
                context,
                appWidgetManager,
                WidgetRestartProvider::class.java,
                WidgetSpecs.restart,
            )
            updateByProvider(
                context,
                appWidgetManager,
                WidgetStandardProvider::class.java,
                WidgetSpecs.standard,
            )
            updateByProvider(
                context,
                appWidgetManager,
                WidgetTransparentBlackProvider::class.java,
                WidgetSpecs.transparentBlack,
            )
            updateByProvider(
                context,
                appWidgetManager,
                WidgetTransparentWhiteProvider::class.java,
                WidgetSpecs.transparentWhite,
            )
        }

        private fun updateByProvider(
            context: Context,
            appWidgetManager: AppWidgetManager,
            providerClass: Class<out AppWidgetProvider>,
            spec: WidgetSpec,
        ) {
            val ids = appWidgetManager.getAppWidgetIds(ComponentName(context, providerClass))
            for (id in ids) {
                ElapsedWidgetRenderer.updateWidget(context, appWidgetManager, id, spec)
            }
        }
    }
}

class WidgetSimpleProvider : ElapsedBaseWidgetProvider(WidgetSpecs.simple)
class WidgetRestartProvider : ElapsedBaseWidgetProvider(WidgetSpecs.restart)
class WidgetStandardProvider : ElapsedBaseWidgetProvider(WidgetSpecs.standard)
class WidgetTransparentBlackProvider : ElapsedBaseWidgetProvider(WidgetSpecs.transparentBlack)
class WidgetTransparentWhiteProvider : ElapsedBaseWidgetProvider(WidgetSpecs.transparentWhite)
