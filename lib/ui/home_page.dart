import 'package:flutter/material.dart';
import 'package:todo_list_app/widgets/todo_list.dart';
import 'package:todo_list_app/widgets/task_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> toDoList = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void sortTasksByPriority() {
    setState(() {
      toDoList.sort((a, b) {
        const priorityOrder = {'High': 1, 'Medium': 2, 'Low': 3};
        return priorityOrder[a['priority']]!.compareTo(priorityOrder[b['priority']]!);
      });
    });
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(toDoList));
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasks = prefs.getString('tasks');
    if (tasks != null) {
      setState(() {
        toDoList = List<Map<String, dynamic>>.from(jsonDecode(tasks));
        sortTasksByPriority();
      });
    }
  }

  void addTask(String title, String description, String priority, DateTime? dueDate) {
    setState(() {
      toDoList.add({
        'title': title,
        'description': description,
        'completed': false,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
      });
      sortTasksByPriority();
    });
    saveTasks();
  }

  void editTask(int index, String title, String description, String priority, DateTime? dueDate) {
    setState(() {
      toDoList[index] = {
        'title': title,
        'description': description,
        'completed': toDoList[index]['completed'],
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
      };
      sortTasksByPriority();
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
    saveTasks();
  }

  void checkBoxChanged(int index) {
    setState(() {
      toDoList[index]['completed'] = !toDoList[index]['completed'];
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: toDoList.length,
        itemBuilder: (context, index) {
          return TodoList(
            taskName: toDoList[index]['title'],
            description: toDoList[index]['description'],
            taskCompleted: toDoList[index]['completed'],
            onChanged: (value) => checkBoxChanged(index),
            deleteFunction: (context) => deleteTask(index),
            editFunction: () {
              showDialog(
                context: context,
                builder: (context) => TaskForm(
                  onSave: (title, description, priority, dueDate) {
                    editTask(index, title, description, priority, dueDate);
                  },
                  initialTitle: toDoList[index]['title'],
                  initialDescription: toDoList[index]['description'],
                  initialPriority: toDoList[index]['priority'],
                  initialDueDate: toDoList[index]['dueDate'] != null
                      ? DateTime.parse(toDoList[index]['dueDate'])
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => TaskForm(
              onSave: (title, description, priority, dueDate) {
                addTask(title, description, priority, dueDate);
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
