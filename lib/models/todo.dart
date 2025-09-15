import 'package:flutter/material.dart';

enum Priority {
  importantUrgent, // 重要且紧急
  importantNotUrgent, // 重要不紧急
  notImportantUrgent, // 不重要紧急
  notImportantNotUrgent, // 不重要不紧急
}

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.importantUrgent:
        return '重要且紧急';
      case Priority.importantNotUrgent:
        return '重要不紧急';
      case Priority.notImportantUrgent:
        return '不重要紧急';
      case Priority.notImportantNotUrgent:
        return '不重要不紧急';
    }
  }

  String get shortName {
    switch (this) {
      case Priority.importantUrgent:
        return '重急';
      case Priority.importantNotUrgent:
        return '重缓';
      case Priority.notImportantUrgent:
        return '急';
      case Priority.notImportantNotUrgent:
        return '缓';
    }
  }

  Color get color {
    switch (this) {
      case Priority.importantUrgent:
        return Colors.red; // 红色 - 最高优先级
      case Priority.importantNotUrgent:
        return Colors.orange; // 橙色 - 重要但不急
      case Priority.notImportantUrgent:
        return Colors.yellow.shade700; // 黄色 - 紧急但不重要
      case Priority.notImportantNotUrgent:
        return Colors.green; // 绿色 - 最低优先级
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.importantUrgent:
        return Icons.priority_high;
      case Priority.importantNotUrgent:
        return Icons.star;
      case Priority.notImportantUrgent:
        return Icons.schedule;
      case Priority.notImportantNotUrgent:
        return Icons.low_priority;
    }
  }
}

class Todo {
  String title;
  String description;
  DateTime dateTime;
  bool isDone;
  Color? color;
  Priority priority; // 新增优先级字段

  Todo({
    required this.title,
    required this.description,
    required this.dateTime,
    this.isDone = false,
    this.color,
    this.priority = Priority.notImportantNotUrgent, // 默认为最低优先级
  });

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'isDone': isDone,
      'color': color?.value, // 保存颜色值，可为null
      'priority': priority.index, // 保存枚举索引
    };
  }

  // 从 JSON 创建实例
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dateTime: DateTime.parse(json['dateTime']),
      isDone: json['isDone'] ?? false,
      color: json['color'] != null ? Color(json['color']) : null,
      priority:
          json['priority'] != null
              ? Priority.values[json['priority']]
              : Priority.notImportantNotUrgent,
    );
  }
}
