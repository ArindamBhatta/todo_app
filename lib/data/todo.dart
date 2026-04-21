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
  final bool isPending;
  final String urgencyLevel;
  final String category;
  final String name;
  final DateTime startTime;
  final Color color;
  final DateTime absoluteDeadline;
  final DateTime desireDeadline;

  ElementTask({
    String? id,
    required this.isPending,
    required this.urgencyLevel,
    required this.category,
    required this.name,
    required this.color,
    required this.startTime,
    required this.absoluteDeadline,
    required this.desireDeadline,
  }) : id = id ?? uuid.v4();

  ElementTask copyWith({
    String? id,
    bool? isPending,
    String? urgencyLevel,
    String? category,
    String? name,
    DateTime? startTime,
    Color? color,
    DateTime? absoluteDeadline,
    DateTime? desireDeadline,
  }) {
    return ElementTask(
      id: id ?? this.id,
      isPending: isPending ?? this.isPending,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      category: category ?? this.category,
      name: name ?? this.name,
      color: color ?? this.color,
      startTime: startTime ?? this.startTime,
      absoluteDeadline: absoluteDeadline ?? this.absoluteDeadline,
      desireDeadline: desireDeadline ?? this.desireDeadline,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'is_pending': isPending ? 1 : 0,
      'urgency_level': urgencyLevel,
      'category': category,
      'name': name,
      'color': color.value,
      'start_time': startTime.toIso8601String(),
      'absolute_deadline': absoluteDeadline.toIso8601String(),
      'desire_deadline': desireDeadline.toIso8601String(),
    };
  }

  factory ElementTask.fromMap(Map<String, Object?> map) {
    return ElementTask(
      id: map['id']! as String,
      isPending: (map['is_pending'] as num).toInt() == 1,
      urgencyLevel: map['urgency_level']! as String,
      category: map['category']! as String,
      name: map['name']! as String,
      color: Color((map['color']! as num).toInt()),
      startTime: DateTime.parse(map['start_time']! as String),
      absoluteDeadline: DateTime.parse(map['absolute_deadline']! as String),
      desireDeadline: DateTime.parse(map['desire_deadline']! as String),
    );
  }
}
