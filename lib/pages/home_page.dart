import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/storage_helper.dart';
import '../services/hitokoto_service.dart';
import 'add_todo_page.dart';
import 'edit_todo_page.dart';
import 'search_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> todos = [];
  String hitokotoText = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadTodoList();
    _fetchHitokoto();
  }

  Future<void> _loadTodoList() async {
    final loadedTodos = await StorageHelper.loadTodoList();
    setState(() {
      todos = _sortTodos(loadedTodos);
    });
  }

  List<Todo> _sortTodos(List<Todo> todoList) {
    final now = DateTime.now();
    todoList.sort((a, b) {
      bool aIsOverdue = a.dateTime.isBefore(now) && !a.isDone;
      bool bIsOverdue = b.dateTime.isBefore(now) && !b.isDone;

      if (aIsOverdue && !bIsOverdue) return -1;
      if (!aIsOverdue && bIsOverdue) return 1;

      if (aIsOverdue == bIsOverdue) {
        int priorityComparison = a.priority.index.compareTo(b.priority.index);
        if (priorityComparison != 0) return priorityComparison;
      }

      return a.dateTime.compareTo(b.dateTime);
    });
    return todoList;
  }

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
        child: Column(
          children: [
            // 搜索栏区域 - 新增
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '搜索您的 Todo...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.filter_list,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Todo 列表
            Expanded(
              child:
                  todos.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          final isOverdue = _isOverdue(todo);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isOverdue
                                      ? Colors.red.withOpacity(0.1)
                                      : todo.color != null
                                      ? todo.color!.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.05),
                              border: Border(
                                left: BorderSide(
                                  color:
                                      isOverdue
                                          ? Colors.red
                                          : todo.color ??
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                  width: 4,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading:
                                  isOverdue
                                      ? const Icon(
                                        Icons.warning,
                                        color: Colors.red,
                                        size: 20,
                                      )
                                      : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color:
                                                  todo.color ??
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            todo.priority.icon,
                                            color: todo.priority.color,
                                            size: 16,
                                          ),
                                        ],
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
                                                    ? todo.color!.withOpacity(
                                                      0.9,
                                                    )
                                                    : null,
                                          ),
                                        ),
                                      ),
                                      // 优先级标签
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: todo.priority.color
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          todo.priority.shortName,
                                          style: TextStyle(
                                            color: todo.priority.color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (isOverdue)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                              : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                todo.description
                                    .replaceAll(RegExp(r'\s+'), ' ')
                                    .trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      isOverdue
                                          ? Colors.red.shade600
                                          : todo.color != null
                                          ? todo.color!.withOpacity(0.6)
                                          : null,
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
                                    builder:
                                        (context) => EditTodoPage(todo: todo),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newTodo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
          if (newTodo != null) {
            setState(() {
              todos.add(newTodo);
              todos = _sortTodos(todos);
            });
            await StorageHelper.saveTodoList(todos);
          }
        },
      ),
    );
  }

  // 空状态显示
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '还没有 Todo 项目',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角的 + 按钮添加新任务',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
