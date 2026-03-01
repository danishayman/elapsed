import 'dart:convert';

class EventModel {
  final String id;
  final String title;
  final DateTime startDateTime;
  final String colorHex;

  EventModel({
    required this.id,
    required this.title,
    required this.startDateTime,
    required this.colorHex,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startDateTime': startDateTime.toIso8601String(),
    'colorHex': colorHex,
  };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json['id'] as String,
    title: json['title'] as String,
    startDateTime: DateTime.parse(json['startDateTime'] as String),
    colorHex: json['colorHex'] as String,
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
