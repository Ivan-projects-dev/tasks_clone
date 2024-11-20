import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Импорт для форматирования даты и времени

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Tasks Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  void _addTask(String task, DateTime? dateTime) {
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add({
          'title': task,
          'completed': false,
          'dateTime': dateTime,
        });
      });
      _taskController.clear();
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? selectedDateTime;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration:
                        const InputDecoration(hintText: 'Enter your task'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  selectedDateTime ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                if (selectedDateTime != null) {
                                  selectedDateTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    selectedDateTime!.hour,
                                    selectedDateTime!.minute,
                                  );
                                } else {
                                  selectedDateTime = pickedDate;
                                }
                              });
                            }
                          },
                          child: Text(selectedDateTime == null
                              ? 'Date'
                              : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDateTime!)}'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedDateTime != null
                                  ? TimeOfDay.fromDateTime(selectedDateTime!)
                                  : TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                if (selectedDateTime != null) {
                                  selectedDateTime = DateTime(
                                    selectedDateTime!.year,
                                    selectedDateTime!.month,
                                    selectedDateTime!.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                } else {
                                  DateTime now = DateTime.now();
                                  selectedDateTime = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                }
                              });
                            }
                          },
                          child: Text(selectedDateTime == null
                              ? 'Time'
                              : 'Time: ${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _taskController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _addTask(_taskController.text, selectedDateTime);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Tasks Clone'),
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('Task list is empty!'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task['completed'],
                    onChanged: (value) => _toggleTaskCompletion(index),
                  ),
                  title: Text(
                    task['title'],
                    style: TextStyle(
                      decoration: task['completed']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: task['dateTime'] != null
                      ? Text(DateFormat('yyyy-MM-dd HH:mm')
                          .format(task['dateTime']))
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
