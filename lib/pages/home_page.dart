import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/storage_helper.dart';
import '../services/hitokoto_service.dart';
import 'add_todo_page.dart';
import 'edit_todo_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> todos = [];
  String hitokotoText = "Loading..."; // 用于存储从 API 获取的文本

  @override
  void initState() {
    super.initState();
    _loadTodoList();
    _fetchHitokoto(); // 获取一言文本
  }

  Future<void> _loadTodoList() async {
    final loadedTodos = await StorageHelper.loadTodoList();
    setState(() {
      todos = _sortTodos(loadedTodos); // 加载时进行排序
    });
  }

  // 添加排序方法：超时的放在最前面
  List<Todo> _sortTodos(List<Todo> todoList) {
    final now = DateTime.now();
    todoList.sort((a, b) {
      bool aIsOverdue = a.dateTime.isBefore(now) && !a.isDone;
      bool bIsOverdue = b.dateTime.isBefore(now) && !b.isDone;

      // 超时且未完成的排在前面
      if (aIsOverdue && !bIsOverdue) return -1;
      if (!aIsOverdue && bIsOverdue) return 1;

      // 如果都是超时或都不是超时，按时间排序
      return a.dateTime.compareTo(b.dateTime);
    });
    return todoList;
  }

  // 判断是否超时
  bool _isOverdue(Todo todo) {
    return todo.dateTime.isBefore(DateTime.now()) && !todo.isDone;
  }

  Future<void> _fetchHitokoto() async {
    final text = await HitokotoService.fetchHitokoto();
    setState(() {
      hitokotoText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        toolbarHeight: 80, // 根据需要调整高度
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 18)),
                  Text(
                    hitokotoText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            // 刷新一言按钮
            IconButton(
              onPressed: _fetchHitokoto, // 点击时重新获取一言
              icon: const Icon(Icons.refresh),
              iconSize: 20,
              tooltip: '刷新一言', // 长按显示提示
              padding: const EdgeInsets.all(4),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            final isOverdue = _isOverdue(todo);

            return Container(
              decoration:
                  isOverdue
                      ? BoxDecoration(
                        color: Colors.red.withOpacity(0.1), // 超时项目的背景色
                        border: Border(
                          left: BorderSide(
                            color: Colors.red,
                            width: 4,
                          ), // 左侧红色边框
                        ),
                      )
                      : todo.color != null
                      ? BoxDecoration(
                        color: todo.color!.withOpacity(0.1), // 有颜色时使用该颜色的淡色背景
                        border: Border(
                          left: BorderSide(
                            color: todo.color!,
                            width: 4,
                          ), // 左侧边框
                        ),
                      )
                      : BoxDecoration(
                        // 无色时使用非常淡的灰色背景，几乎与默认背景一致
                        color: Colors.grey.withOpacity(0.05),
                        border: Border(
                          left: BorderSide(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.primary, // 左侧边框使用主题色
                            width: 4,
                          ),
                        ),
                      ),
              child: ListTile(
                leading:
                    isOverdue
                        ? Icon(Icons.warning, color: Colors.red, size: 20)
                        : Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color:
                                todo.color ??
                                Theme.of(
                                  context,
                                ).colorScheme.primary, // 无色时使用主题色
                            shape: BoxShape.circle,
                          ),
                        ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            todo.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isOverdue
                                      ? Colors.red.shade700
                                      : todo.color != null
                                      ? todo.color!.withOpacity(0.9)
                                      : null, // 无色时使用默认文字颜色
                            ),
                          ),
                        ),
                        if (isOverdue)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '超时',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '${todo.dateTime.year}-${todo.dateTime.month.toString().padLeft(2, '0')}-${todo.dateTime.day.toString().padLeft(2, '0')} ${todo.dateTime.hour.toString().padLeft(2, '0')}:${todo.dateTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isOverdue
                                ? Colors.red.shade600
                                : todo.color != null
                                ? todo.color!.withOpacity(0.7)
                                : Colors.grey, // 无色时使用灰色
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  todo.description.replaceAll(RegExp(r'\s+'), ' ').trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        isOverdue
                            ? Colors.red.shade600
                            : todo.color != null
                            ? todo.color!.withOpacity(0.6)
                            : null, // 无色时使用默认颜色
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    setState(() {
                      todos.removeAt(index);
                    });
                    await StorageHelper.saveTodoList(todos);
                  },
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTodoPage(todo: todo),
                    ),
                  );

                  if (result != null) {
                    if (result == 'delete') {
                      setState(() {
                        todos.removeAt(index);
                      });
                      await StorageHelper.saveTodoList(todos);
                    } else {
                      setState(() {
                        todos[index] = result;
                        todos = _sortTodos(todos);
                      });
                      await StorageHelper.saveTodoList(todos);
                    }
                  }
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newTodo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoPage()),
          );
          if (newTodo != null) {
            setState(() {
              todos.add(newTodo);
              todos = _sortTodos(todos); // 添加后重新排序
            });
            await StorageHelper.saveTodoList(todos);
          }
        },
      ),
    );
  }
}
