import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

enum UrgencyLevel {
  urgentImportant("Urgent Important"),
  notUrgentImportant("Not Urgent Important"),
  notImportantUrgent("Not Important Urgent"),
  notImportantNotUrgent("Not Important Not Urgent");

  final String value;
  const UrgencyLevel(this.value);
}

IconData getIconData(String urgencyLevel) {
  switch (urgencyLevel) {
    case 'Urgent Important':
      return Icons.priority_high;
    case 'Not Urgent Important':
      return Icons.check_circle_outline;
    case 'Not Important Urgent':
      return Icons.access_alarm;
    case 'Not Important Not Urgent':
      return Icons.check_circle;
    default:
      return Icons.error;
  }
}

enum Category {
  office("Office"),
  health("Health"),
  finance("Finance"),
  home("Home"),
  personal("Personal"),
  career("Career"),
  self("Self"),
  leisure("Leisure"),
  fun("Fun");

  final String value;
  const Category(this.value);
}

final Map<String, String> categoryImageMap = {
  'Office': 'assets/Office.jpg',
  'Health': 'assets/Health.jpg',
  'Finance': 'assets/finance.jpg',
  'Home': 'assets/Home.jpg',
  'Personal': 'assets/Personal.jpg',
  'Career': 'assets/Career.jpg',
  'Self': 'assets/Self_Development.jpg',
  'Leisure': 'assets/Leisure.jpg',
  'Fun': 'assets/Fun.jpg',
};

class ElementTask {
  final String id;
  final String category;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String urgencyLevel;
  final bool isPending;

  ElementTask({
    String? id,
    required this.category,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.urgencyLevel,
    required this.isPending,
  }) : id = id ?? uuid.v4();

  ElementTask copyWith({
    String? id,
    String? category,
    String? name,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? urgencyLevel,
    bool? isPending,
  }) {
    return ElementTask(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      isPending: isPending ?? this.isPending,
    );
  }

  static String _readString(
    Map<String, Object?> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      final text = value.toString();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  static DateTime _readDateTime(
    Map<String, Object?> json,
    List<String> keys, {
    required DateTime fallback,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value);
      }
    }

    return fallback;
  }

  static bool _readBool(
    Map<String, Object?> json,
    List<String> keys, {
    bool fallback = false,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      if (value is bool) {
        return value;
      }

      if (value is num) {
        return value.toInt() == 1;
      }

      final text = value.toString().toLowerCase();
      if (text == '1' || text == 'true') {
        return true;
      }
      if (text == '0' || text == 'false') {
        return false;
      }
    }

    return fallback;
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'urgency_level': urgencyLevel,
      'is_pending': isPending ? 1 : 0,
    };
  }

  factory ElementTask.fromJson(Map<String, Object?> json) {
    final startTime = _readDateTime(json, [
      'start_time',
    ], fallback: DateTime.now());
    final endTime = _readDateTime(json, ['end_time'], fallback: startTime);

    return ElementTask(
      id: _readString(json, ['id'], fallback: uuid.v4()),
      category: _readString(json, [
        'category',
      ], fallback: Category.personal.value),
      name: _readString(json, ['name'], fallback: 'Untitled task'),
      description: _readString(json, ['description']),
      startTime: startTime,
      endTime: endTime,
      urgencyLevel: _readString(json, [
        'urgency_level',
      ], fallback: UrgencyLevel.notUrgentImportant.value),
      isPending: _readBool(json, ['is_pending'], fallback: true),
    );
  }
}
