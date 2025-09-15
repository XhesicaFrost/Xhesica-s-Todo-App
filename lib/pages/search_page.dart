import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/storage_helper.dart';
import 'edit_todo_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Todo> _allTodos = [];
  List<Todo> _filteredTodos = [];
  Priority? _selectedPriority;
  bool? _isOverdue;
  bool? _hasColor;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    final todos = await StorageHelper.loadTodoList();
    setState(() {
      _allTodos = todos;
      _filteredTodos = todos;
    });
  }

  void _onSearchChanged() {
    _performSearch();
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    final now = DateTime.now();

    setState(() {
      _filteredTodos =
          _allTodos.where((todo) {
            // 文本搜索
            if (query.isNotEmpty) {
              final titleMatch = todo.title.toLowerCase().contains(query);
              final descMatch = todo.description.toLowerCase().contains(query);
              if (!titleMatch && !descMatch) return false;
            }

            // 优先级筛选
            if (_selectedPriority != null &&
                todo.priority != _selectedPriority) {
              return false;
            }

            // 超时状态筛选
            if (_isOverdue != null) {
              final isOverdue = todo.dateTime.isBefore(now) && !todo.isDone;
              if (isOverdue != _isOverdue) return false;
            }

            // 颜色筛选
            if (_hasColor != null) {
              final hasColor = todo.color != null;
              if (hasColor != _hasColor) return false;
            }

            // 日期范围筛选
            if (_fromDate != null && todo.dateTime.isBefore(_fromDate!)) {
              return false;
            }
            if (_toDate != null && todo.dateTime.isAfter(_toDate!)) {
              return false;
            }

            return true;
          }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedPriority = null;
      _isOverdue = null;
      _hasColor = null;
      _fromDate = null;
      _toDate = null;
      _filteredTodos = _allTodos;
    });
  }

  bool _isOverdueCheck(Todo todo) {
    final now = DateTime.now();
    return todo.dateTime.isBefore(now) && !todo.isDone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索 Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearFilters,
            tooltip: '清除所有筛选',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索标题或描述...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 筛选器区域
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // 优先级和状态筛选
                Row(
                  children: [
                    Expanded(child: _buildPriorityFilter()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatusFilter()),
                  ],
                ),
                const SizedBox(height: 10),

                // 颜色和日期筛选
                Row(
                  children: [
                    Expanded(child: _buildColorFilter()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDateFilter()),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // 搜索结果
          Expanded(
            child:
                _filteredTodos.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      itemCount: _filteredTodos.length,
                      itemBuilder: (context, index) {
                        final todo = _filteredTodos[index];
                        return _buildTodoItem(todo, index);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFilter() {
    return DropdownButtonFormField<Priority?>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: '优先级',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<Priority?>(value: null, child: Text('全部')),
        ...Priority.values.map((priority) {
          return DropdownMenuItem<Priority?>(
            value: priority,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(priority.icon, color: priority.color, size: 16),
                const SizedBox(width: 8),
                Text(priority.shortName),
              ],
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPriority = value;
        });
        _performSearch();
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<bool?>(
      value: _isOverdue,
      decoration: InputDecoration(
        labelText: '状态',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem<bool?>(value: null, child: Text('全部')),
        DropdownMenuItem<bool?>(
          value: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Text('超时'),
            ],
          ),
        ),
        DropdownMenuItem<bool?>(
          value: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text('正常'),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _isOverdue = value;
        });
        _performSearch();
      },
    );
  }

  Widget _buildColorFilter() {
    return DropdownButtonFormField<bool?>(
      value: _hasColor,
      decoration: InputDecoration(
        labelText: '颜色',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem<bool?>(value: null, child: Text('全部')),
        DropdownMenuItem<bool?>(
          value: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.palette, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Text('有颜色'),
            ],
          ),
        ),
        DropdownMenuItem<bool?>(
          value: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle_outlined, color: Colors.grey, size: 16),
              SizedBox(width: 8),
              Text('无颜色'),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _hasColor = value;
        });
        _performSearch();
      },
    );
  }

  Widget _buildDateFilter() {
    return OutlinedButton.icon(
      onPressed: _showDateRangePicker,
      icon: const Icon(Icons.date_range),
      label: Text(
        _fromDate != null && _toDate != null
            ? '${_fromDate!.month}/${_fromDate!.day} - ${_toDate!.month}/${_toDate!.day}'
            : '日期范围',
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange:
          _fromDate != null && _toDate != null
              ? DateTimeRange(start: _fromDate!, end: _toDate!)
              : null,
    );

    if (result != null) {
      setState(() {
        _fromDate = result.start;
        _toDate = result.end;
      });
      _performSearch();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty ||
                    _selectedPriority != null ||
                    _isOverdue != null ||
                    _hasColor != null ||
                    _fromDate != null
                ? '没有找到匹配的 Todo'
                : '开始搜索您的 Todo',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text('使用上方的搜索框和筛选器', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildTodoItem(Todo todo, int index) {
    final isOverdue = _isOverdueCheck(todo);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    : todo.color ?? Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading:
            isOverdue
                ? const Icon(Icons.warning, color: Colors.red, size: 20)
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color:
                            todo.color ?? Theme.of(context).colorScheme.primary,
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
                              ? todo.color!.withOpacity(0.9)
                              : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: todo.priority.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
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
                        : Colors.grey,
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
                    : null,
          ),
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditTodoPage(todo: todo)),
          );

          if (result != null) {
            // 重新加载数据
            await _loadTodos();
          }
        },
      ),
    );
  }
}
