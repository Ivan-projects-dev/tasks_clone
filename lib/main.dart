import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
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
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _saveTasks() {
    box.write('tasks', _tasks);
  }

  void _loadTasks() {
    final savedTasks = box.read('tasks');
    if (savedTasks != null) {
      setState(() {
        _tasks.addAll(List<Map<String, dynamic>>.from(savedTasks));
      });
    }
  }

  void _addTask(String task, DateTime? dateTime) {
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add({
          'title': task,
          'completed': false,
          'dateTime': dateTime?.toString(),
        });
        _sortTasks();
      });
      _saveTasks();
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
        return DateTime.parse(a['dateTime'])
            .compareTo(DateTime.parse(b['dateTime']));
      }
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

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
                              firstDate: now,
                              lastDate: DateTime(2101),
                            );
                            if (!mounted) return;
                            if (pickedDate != null) {
                              setStateDialog(() {
                                selectedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  selectedDateTime?.hour ?? 0,
                                  selectedDateTime?.minute ?? 0,
                                );
                              });
                            }
                          },
                          child: Text(selectedDateTime == null
                              ? 'Выбрать дату'
                              : 'Дата: ${DateFormat('yyyy-MM-dd').format(selectedDateTime!)}'),
                          // Добавлен оператор ! после selectedDateTime
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            TimeOfDay nowTime = TimeOfDay.now();
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedDateTime != null
                                  ? TimeOfDay.fromDateTime(selectedDateTime!)
                                  // Добавлен оператор ! после selectedDateTime
                                  : nowTime,
                            );
                            if (!mounted) return;
                            if (pickedTime != null) {
                              setStateDialog(() {
                                selectedDateTime = DateTime(
                                  selectedDateTime?.year ??
                                      DateTime.now().year,
                                  selectedDateTime?.month ??
                                      DateTime.now().month,
                                  selectedDateTime?.day ?? DateTime.now().day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          },
                          child: Text(selectedDateTime == null
                              ? 'Выбрать время'
                              : 'Время: ${selectedDateTime?.hour.toString().padLeft(2, '0') ?? '00'}:${selectedDateTime?.minute.toString().padLeft(2, '0') ?? '00'}'),
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
                    _addTask(
                        _taskController.text, selectedDateTime ?? DateTime.now());
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
        title: const Text('Google Tasks Clone'),
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
                          .format(DateTime.parse(task['dateTime'])))
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
