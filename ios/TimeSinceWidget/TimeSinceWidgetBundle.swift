import WidgetKit
import SwiftUI

@main
struct TimeSinceWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmallTimeSinceWidget()
        MediumTimeSinceWidget()
        LargeTimeSinceWidget()
    }
}
