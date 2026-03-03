import 'dart:convert';

class EventModel {
  final String id;
  final String title;
  final DateTime startDateTime;
  final String colorHex;
  final int? goalDays;
  final String timeFormat;
  final List<DateTime> resetHistory;
  final bool isStopped;
  final int? stoppedElapsedSeconds;

  EventModel({
    required this.id,
    required this.title,
    required this.startDateTime,
    required this.colorHex,
    this.goalDays,
    this.timeFormat = 'Days',
    List<DateTime>? resetHistory,
    this.isStopped = false,
    this.stoppedElapsedSeconds,
  }) : resetHistory = resetHistory ?? [];

  EventModel copyWith({
    String? id,
    String? title,
    DateTime? startDateTime,
    String? colorHex,
    int? goalDays,
    bool clearGoal = false,
    String? timeFormat,
    List<DateTime>? resetHistory,
    bool? isStopped,
    int? stoppedElapsedSeconds,
    bool clearStoppedElapsed = false,
  }) => EventModel(
    id: id ?? this.id,
    title: title ?? this.title,
    startDateTime: startDateTime ?? this.startDateTime,
    colorHex: colorHex ?? this.colorHex,
    goalDays: clearGoal ? null : (goalDays ?? this.goalDays),
    timeFormat: timeFormat ?? this.timeFormat,
    resetHistory: resetHistory ?? this.resetHistory,
    isStopped: isStopped ?? this.isStopped,
    stoppedElapsedSeconds: clearStoppedElapsed
        ? null
        : (stoppedElapsedSeconds ?? this.stoppedElapsedSeconds),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startDateTime': startDateTime.toIso8601String(),
    'colorHex': colorHex,
    if (goalDays != null) 'goalDays': goalDays,
    'timeFormat': timeFormat,
    'resetHistory': resetHistory.map((d) => d.toIso8601String()).toList(),
    'isStopped': isStopped,
    if (stoppedElapsedSeconds != null)
      'stoppedElapsedSeconds': stoppedElapsedSeconds,
  };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json['id'] as String,
    title: json['title'] as String,
    startDateTime: DateTime.parse(json['startDateTime'] as String),
    colorHex: json['colorHex'] as String,
    goalDays: json['goalDays'] as int?,
    timeFormat: json['timeFormat'] as String? ?? 'Days',
    resetHistory:
        (json['resetHistory'] as List<dynamic>?)
            ?.map((e) => DateTime.parse(e as String))
            .toList() ??
        [],
    isStopped: json['isStopped'] as bool? ?? false,
    stoppedElapsedSeconds: json['stoppedElapsedSeconds'] as int?,
  );

  static String encodeList(List<EventModel> events) =>
      jsonEncode(events.map((e) => e.toJson()).toList());

  static List<EventModel> decodeList(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
