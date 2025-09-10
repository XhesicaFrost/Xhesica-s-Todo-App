import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';

class StorageHelper {
  // 获取本地文件路径
  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    print('Local file path: ${directory.path}'); // 打印路径
    return File('${directory.path}/todo_list.json');
  }

  // 保存 todoList 到本地文件
  static Future<void> saveTodoList(List<Todo> todos) async {
    final file = await _getLocalFile();
    final jsonData = jsonEncode(todos.map((todo) => todo.toJson()).toList());
    await file.writeAsString(jsonData);
  }

  // 从本地文件加载 todoList
  static Future<List<Todo>> loadTodoList() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final List<dynamic> data = jsonDecode(jsonData);
        return data.map((item) => Todo.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading todo list: $e');
    }
    return [];
  }
}
