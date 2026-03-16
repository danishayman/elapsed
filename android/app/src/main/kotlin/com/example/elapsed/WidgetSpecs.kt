package com.example.Elapsed

enum class WidgetShape {
    SIMPLE,
    WIDE,
}

enum class WidgetVariant {
    SIMPLE,
    RESTART,
    STANDARD,
    TRANSPARENT_BLACK,
    TRANSPARENT_WHITE,
}

data class WidgetSpec(
    val providerName: String,
    val shape: WidgetShape,
    val variant: WidgetVariant,
)

object WidgetSpecs {
    val simple = WidgetSpec("WidgetSimpleProvider", WidgetShape.SIMPLE, WidgetVariant.SIMPLE)
    val restart = WidgetSpec("WidgetRestartProvider", WidgetShape.WIDE, WidgetVariant.RESTART)
    val standard = WidgetSpec("WidgetStandardProvider", WidgetShape.WIDE, WidgetVariant.STANDARD)
    val transparentBlack = WidgetSpec("WidgetTransparentBlackProvider", WidgetShape.WIDE, WidgetVariant.TRANSPARENT_BLACK)
    val transparentWhite = WidgetSpec("WidgetTransparentWhiteProvider", WidgetShape.WIDE, WidgetVariant.TRANSPARENT_WHITE)

    val all = listOf(simple, restart, standard, transparentBlack, transparentWhite)

    fun fromProviderClassName(className: String?): WidgetSpec? {
        if (className == null) return null
        return all.firstOrNull { className.endsWith(it.providerName) }
    }
}
