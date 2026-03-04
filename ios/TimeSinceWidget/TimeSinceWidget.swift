import WidgetKit
import SwiftUI

// MARK: - Data Model
struct TimeSinceEvent: Codable {
    let id: String
    let title: String
    let startDateTime: String
    let colorHex: String

    var start: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: startDateTime) { return date }
        // Fallback without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: startDateTime)
    }

    var color: Color {
        let hex = colorHex.replacingOccurrences(of: "#", with: "")
        guard let int = UInt64(hex, radix: 16) else { return .purple }
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Timeline Entry
struct TimeSinceEntry: TimelineEntry {
    let date: Date
    let events: [TimeSinceEvent]
}

// MARK: - Timeline Provider
struct TimeSinceProvider: TimelineProvider {
    private let suiteName = "group.com.example.Elapsed"
    private let key = "events_json"

    func placeholder(in context: Context) -> TimeSinceEntry {
        TimeSinceEntry(date: Date(), events: [
            TimeSinceEvent(id: "1", title: "Sample Event", startDateTime: "2024-01-01T00:00:00.000Z", colorHex: "#7C3AED")
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (TimeSinceEntry) -> Void) {
        completion(TimeSinceEntry(date: Date(), events: loadEvents()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeSinceEntry>) -> Void) {
        let entry = TimeSinceEntry(date: Date(), events: loadEvents())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEvents() -> [TimeSinceEvent] {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let jsonString = defaults.string(forKey: key),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([TimeSinceEvent].self, from: data)) ?? []
    }
}

// MARK: - Helper
func elapsedString(from start: Date) -> (days: Int, hours: Int, minutes: Int) {
    let interval = Date().timeIntervalSince(start)
    let totalMinutes = Int(interval) / 60
    let days = totalMinutes / 1440
    let hours = (totalMinutes % 1440) / 60
    let minutes = totalMinutes % 60
    return (days, hours, minutes)
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: TimeSinceEntry

    var body: some View {
        let event = entry.events.first

        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.12)

            if let event = event, let start = event.start {
                let e = elapsedString(from: start)
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(event.color)
                        .frame(width: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text("\(e.days)d \(e.hours)h")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 10)
                    Spacer()
                }
                .padding(12)
            } else {
                Text("No events")
                    .foregroundColor(.gray)
                    .font(.system(size: 13))
            }
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: TimeSinceEntry

    var body: some View {
        let events = Array(entry.events.prefix(3))

        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.12)

            VStack(alignment: .leading, spacing: 0) {
                Text("Elapsed")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)

                if events.isEmpty {
                    Spacer()
                    Text("No events yet")
                        .foregroundColor(.gray)
                        .font(.system(size: 13))
                    Spacer()
                } else {
                    ForEach(events, id: \.id) { event in
                        if let start = event.start {
                            let e = elapsedString(from: start)
                            HStack {
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(event.color)
                                    .frame(width: 3, height: 18)
                                Text(event.title)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Spacer()
                                Text("\(e.days)d")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 3)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(12)
        }
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: TimeSinceEntry

    var body: some View {
        let event = entry.events.first

        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.12)

            if let event = event, let start = event.start {
                let e = elapsedString(from: start)
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(event.color)
                        .frame(width: 5)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        Text("\(e.days)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text(e.days == 1 ? "day" : "days")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        Text("\(e.days)d \(e.hours)h \(e.minutes)m")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.45))
                            .padding(.top, 2)
                    }
                    .padding(.leading, 16)
                    Spacer()
                }
                .padding(16)
            } else {
                VStack(spacing: 6) {
                    Text("No events")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add events in the app")
                        .foregroundColor(.gray)
                        .font(.system(size: 13))
                }
            }
        }
    }
}

// MARK: - Widget Definitions
struct SmallTimeSinceWidget: Widget {
    let kind = "SmallTimeSinceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeSinceProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Elapsed – Small")
        .description("Shows your most recent event countdown.")
        .supportedFamilies([.systemSmall])
    }
}

struct MediumTimeSinceWidget: Widget {
    let kind = "MediumTimeSinceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeSinceProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Elapsed – Medium")
        .description("Shows up to 3 event countdowns.")
        .supportedFamilies([.systemMedium])
    }
}

struct LargeTimeSinceWidget: Widget {
    let kind = "LargeTimeSinceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeSinceProvider()) { entry in
            LargeWidgetView(entry: entry)
        }
        .configurationDisplayName("Elapsed – Large")
        .description("Shows a featured event with a large day count.")
        .supportedFamilies([.systemLarge])
    }
}
