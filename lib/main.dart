import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        _sortTasks();
      });
      _taskController.clear();
    }
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a['dateTime'] == null && b['dateTime'] == null) {
        return 0;
      } else if (a['dateTime'] == null) {
        return -1;
      } else if (b['dateTime'] == null) {
        return 1;
      } else {
        return (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime);
      }
    });
  }

  void _toggleTaskCompletion(int index) => setState(() {
        _tasks[index]['completed'] = !_tasks[index]['completed'];
      });
  void _deleteTask(int index) => setState(() {
        _tasks.removeAt(index);
      });

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? selectedDateTime;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Добавить задачу'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                        hintText: 'Введите название задачи'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime now = DateTime.now();
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDateTime ?? now,
                              firstDate:
                                  now, // Ограничиваем выбор на даты ПОЗЖЕ текущей
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setStateDialog(() {
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
                              ? 'Выбрать дату'
                              : 'Дата: ${DateFormat('yyyy-MM-dd').format(selectedDateTime!)}'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            TimeOfDay nowTime = TimeOfDay.now();
                            DateTime now = DateTime.now();
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedDateTime != null
                                  ? TimeOfDay.fromDateTime(selectedDateTime!)
                                  : nowTime,
                            );
                            if (pickedTime != null) {
                              DateTime pickedDateTime = DateTime(
                                selectedDateTime?.year ?? now.year,
                                selectedDateTime?.month ?? now.month,
                                selectedDateTime?.day ?? now.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              if (pickedDateTime.isBefore(now)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Нельзя выбрать время раньше текущего')),
                                );
                              } else {
                                setStateDialog(() {
                                  selectedDateTime = pickedDateTime;
                                });
                              }
                            }
                          },
                          child: Text(selectedDateTime == null
                              ? 'Выбрать время'
                              : 'Время: ${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}'),
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
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    _addTask(_taskController.text, selectedDateTime);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Добавить'),
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
        title: const Text('Tasks'),
      ),
      body: _tasks.isEmpty
          ? const Center(
              child: Text('Пока нет задач! Добавьте несколько задач.'))
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
        tooltip: 'Добавить задачу',
        child: const Icon(Icons.add),
      ),
    );
  }
}
