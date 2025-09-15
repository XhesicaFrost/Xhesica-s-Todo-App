import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/todo.dart';

class EditTodoPage extends StatefulWidget {
  final Todo todo;

  const EditTodoPage({Key? key, required this.todo}) : super(key: key);

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedDateTime;
  Color? selectedColor;
  late Priority selectedPriority; // 新增优先级状态

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.todo.title);
    descriptionController = TextEditingController(text: widget.todo.description)
      ..selection = TextSelection.fromPosition(const TextPosition(offset: 0));
    selectedDateTime = widget.todo.dateTime;
    selectedColor = widget.todo.color; // 可能为null
    selectedPriority = widget.todo.priority; // 初始化优先级
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor ?? Colors.blue,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
              labelTypes: const [],
              pickerAreaBorderRadius: BorderRadius.circular(8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedColor = null; // 设置为无色
                });
                Navigator.of(context).pop();
              },
              child: const Text('No Color'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // 新增优先级选择器
  void _showPriorityPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择优先级'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                Priority.values.map((priority) {
                  return ListTile(
                    leading: Icon(priority.icon, color: priority.color),
                    title: Text(priority.displayName),
                    subtitle: Text(
                      _getPriorityDescription(priority),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    selected: selectedPriority == priority,
                    selectedTileColor: priority.color.withOpacity(0.1),
                    onTap: () {
                      setState(() {
                        selectedPriority = priority;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  // 获取优先级描述
  String _getPriorityDescription(Priority priority) {
    switch (priority) {
      case Priority.importantUrgent:
        return '立即处理，优先完成';
      case Priority.importantNotUrgent:
        return '计划安排，重要任务';
      case Priority.notImportantUrgent:
        return '尽快处理，委托他人';
      case Priority.notImportantNotUrgent:
        return '有时间再做，可以延后';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 20),

            // 时间和颜色并排显示
            Row(
              children: [
                // 时间选择区域
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date & Time: ${selectedDateTime.year}-${selectedDateTime.month.toString().padLeft(2, '0')}-${selectedDateTime.day.toString().padLeft(2, '0')} ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                selectedDateTime,
                              ),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        child: const Text('Select Date & Time'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // 颜色选择区域
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Color:', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _showColorPicker,
                        child: Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selectedColor ?? Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              selectedColor == null
                                  ? const Center(
                                    child: Text(
                                      'No Color',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Tap to select',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 新增优先级选择区域
            Row(
              children: [
                const Text('Priority:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _showPriorityPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selectedPriority.color.withOpacity(0.1),
                        border: Border.all(color: selectedPriority.color),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedPriority.icon,
                            color: selectedPriority.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedPriority.displayName,
                                  style: TextStyle(
                                    color: selectedPriority.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _getPriorityDescription(selectedPriority),
                                  style: TextStyle(
                                    color: selectedPriority.color.withOpacity(
                                      0.7,
                                    ),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: selectedPriority.color,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                ),
                textAlignVertical: TextAlignVertical.top,
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text == "") return;
                      setState(() {
                        widget.todo.title = titleController.text;
                        widget.todo.description = descriptionController.text;
                        widget.todo.dateTime = selectedDateTime;
                        widget.todo.color = selectedColor; // 可能为null
                        widget.todo.priority = selectedPriority; // 更新优先级
                      });
                      Navigator.pop(context, widget.todo);
                    },
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final bool? shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Todo'),
                            content: const Text(
                              'Are you sure you want to delete this todo?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        Navigator.pop(context, 'delete');
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
