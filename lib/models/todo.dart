import 'package:flutter/material.dart';

class Todo {
  String title;
  String description;
  DateTime dateTime;
  bool isDone;
  Color? color; // 改为可空，默认无色

  Todo({
    required this.title,
    required this.description,
    required this.dateTime,
    this.isDone = false,
    this.color, // 默认为null（无色）
  });

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'isDone': isDone,
      'color': color?.value, // 保存颜色值，可为null
    };
  }

  // 从 JSON 创建实例
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      isDone: json['isDone'],
      color: json['color'] != null ? Color(json['color']) : null, // 支持null值
    );
  }
}
