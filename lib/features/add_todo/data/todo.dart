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
    return ElementTask(
      id: json['id']! as String,
      category: json['category']! as String,
      name: json['name']! as String,
      description: json['description']! as String,
      startTime: DateTime.parse(json['start_time']! as String),
      endTime: DateTime.parse(json['end_time']! as String),
      urgencyLevel: json['urgency_level']! as String,
      isPending: (json['is_pending'] as num).toInt() == 1,
    );
  }
}
