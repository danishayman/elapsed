package com.example.Elapsed

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context

abstract class ElapsedBaseWidgetProvider(
    private val spec: WidgetSpec,
) : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            ElapsedWidgetRenderer.updateWidget(context, appWidgetManager, appWidgetId, spec)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        ElapsedWidgetRenderer.updateWidget(context, appWidgetManager, appWidgetId, spec)
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        for (appWidgetId in appWidgetIds) {
            ElapsedWidgetRenderer.clearSelection(context, appWidgetId)
        }
    }
}

class WidgetSmallRestartProvider : ElapsedBaseWidgetProvider(WidgetSpecs.smallRestart)
class WidgetSmallStandardProvider : ElapsedBaseWidgetProvider(WidgetSpecs.smallStandard)
class WidgetSmallTransparentBlackProvider : ElapsedBaseWidgetProvider(WidgetSpecs.smallTransparentBlack)
class WidgetSmallTransparentWhiteProvider : ElapsedBaseWidgetProvider(WidgetSpecs.smallTransparentWhite)

class WidgetMediumRestartProvider : ElapsedBaseWidgetProvider(WidgetSpecs.mediumRestart)
class WidgetMediumStandardProvider : ElapsedBaseWidgetProvider(WidgetSpecs.mediumStandard)
class WidgetMediumTransparentBlackProvider : ElapsedBaseWidgetProvider(WidgetSpecs.mediumTransparentBlack)
class WidgetMediumTransparentWhiteProvider : ElapsedBaseWidgetProvider(WidgetSpecs.mediumTransparentWhite)

class WidgetLargeRestartProvider : ElapsedBaseWidgetProvider(WidgetSpecs.largeRestart)
class WidgetLargeStandardProvider : ElapsedBaseWidgetProvider(WidgetSpecs.largeStandard)
class WidgetLargeTransparentBlackProvider : ElapsedBaseWidgetProvider(WidgetSpecs.largeTransparentBlack)
class WidgetLargeTransparentWhiteProvider : ElapsedBaseWidgetProvider(WidgetSpecs.largeTransparentWhite)
