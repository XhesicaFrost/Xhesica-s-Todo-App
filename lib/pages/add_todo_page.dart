import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/todo.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({Key? key}) : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedDateTime;
  Color? selectedColor; // 默认无色

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();

    // 设置默认时间为今天的23:59
    final now = DateTime.now();
    selectedDateTime = DateTime(now.year, now.month, now.day, 23, 59);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Todo')),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    final newTodo = Todo(
                      title: titleController.text,
                      description: descriptionController.text,
                      dateTime: selectedDateTime,
                      color: selectedColor, // 可以为null
                    );
                    Navigator.pop(context, newTodo);
                  }
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
