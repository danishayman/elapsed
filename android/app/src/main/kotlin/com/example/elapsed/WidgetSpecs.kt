package com.example.Elapsed

enum class WidgetSize {
    SMALL,
    MEDIUM,
    LARGE,
}

enum class WidgetVariant {
    RESTART,
    STANDARD,
    TRANSPARENT_BLACK,
    TRANSPARENT_WHITE,
}

data class WidgetSpec(
    val providerName: String,
    val size: WidgetSize,
    val variant: WidgetVariant,
    val displayName: String,
)

object WidgetSpecs {
    val smallRestart = WidgetSpec("WidgetSmallRestartProvider", WidgetSize.SMALL, WidgetVariant.RESTART, "Restart - Small")
    val smallStandard = WidgetSpec("WidgetSmallStandardProvider", WidgetSize.SMALL, WidgetVariant.STANDARD, "Standard - Small")
    val smallTransparentBlack = WidgetSpec("WidgetSmallTransparentBlackProvider", WidgetSize.SMALL, WidgetVariant.TRANSPARENT_BLACK, "Transparent Black - Small")
    val smallTransparentWhite = WidgetSpec("WidgetSmallTransparentWhiteProvider", WidgetSize.SMALL, WidgetVariant.TRANSPARENT_WHITE, "Transparent White - Small")

    val mediumRestart = WidgetSpec("WidgetMediumRestartProvider", WidgetSize.MEDIUM, WidgetVariant.RESTART, "Restart - Medium")
    val mediumStandard = WidgetSpec("WidgetMediumStandardProvider", WidgetSize.MEDIUM, WidgetVariant.STANDARD, "Standard - Medium")
    val mediumTransparentBlack = WidgetSpec("WidgetMediumTransparentBlackProvider", WidgetSize.MEDIUM, WidgetVariant.TRANSPARENT_BLACK, "Transparent Black - Medium")
    val mediumTransparentWhite = WidgetSpec("WidgetMediumTransparentWhiteProvider", WidgetSize.MEDIUM, WidgetVariant.TRANSPARENT_WHITE, "Transparent White - Medium")

    val largeRestart = WidgetSpec("WidgetLargeRestartProvider", WidgetSize.LARGE, WidgetVariant.RESTART, "Restart - Large")
    val largeStandard = WidgetSpec("WidgetLargeStandardProvider", WidgetSize.LARGE, WidgetVariant.STANDARD, "Standard - Large")
    val largeTransparentBlack = WidgetSpec("WidgetLargeTransparentBlackProvider", WidgetSize.LARGE, WidgetVariant.TRANSPARENT_BLACK, "Transparent Black - Large")
    val largeTransparentWhite = WidgetSpec("WidgetLargeTransparentWhiteProvider", WidgetSize.LARGE, WidgetVariant.TRANSPARENT_WHITE, "Transparent White - Large")

    val all = listOf(
        smallRestart,
        smallStandard,
        smallTransparentBlack,
        smallTransparentWhite,
        mediumRestart,
        mediumStandard,
        mediumTransparentBlack,
        mediumTransparentWhite,
        largeRestart,
        largeStandard,
        largeTransparentBlack,
        largeTransparentWhite,
    )

    fun fromProviderClassName(className: String?): WidgetSpec? {
        if (className == null) return null
        return all.firstOrNull { className.endsWith(it.providerName) }
    }
}
