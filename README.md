# Elapsed

A clean, minimal Flutter app for tracking how much time has passed since the moments that matter, whether it's days smoke-free, a gym streak, or any personal milestone.

## Features

- **Live Timers** — real-time counters that tick every second
- **Flexible Formats** — display elapsed time in years, months, weeks, days, or hours/minutes/seconds
- **Stop & Resume** — pause a timer and pick up right where you left off
- **Restart with History** — reset a timer and keep a log of previous streaks, including your longest
- **Drag to Reorder** — arrange your timers in whatever order suits you
- **Color-Coded Events** — pick from a 15-color palette for easy visual distinction
- **Home Screen Widgets** — native Android and iOS widgets so you can see your timers at a glance
- **Deep Linking** — tap a widget to jump straight to the event detail screen
- **Share** — share your progress with a single tap
- **Local Storage** — all data stays on your device via SharedPreferences

## Screens

| Screen | Description |
|---|---|
| **Home** | Main list of live-updating timers with drag-to-reorder and quick-delete |
| **Add / Edit Event** | Set a label, pick a color, and choose a start date or start from now |
| **Event Detail** | Full view with actions (restart, stop/resume), format picker, reset history, and sharing |
| **Format** | Choose the time display format for each individual timer |
| **Settings** | App version and preferences |
| **Info** | About the app with quick-start tips |

## Download

Download the latest APK from the [Releases](../../releases) section.

## Building from Source

This is a standard Flutter project. Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed, then:

```bash
flutter pub get
flutter run
```
