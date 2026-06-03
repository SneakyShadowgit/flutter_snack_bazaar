import 'package:flutter/material.dart';

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> _tasks = [
    {'title': "learn flutter", "isDone": true},
    {'title': "complete the to do app", "isDone": false},
    {'title': "have some rest", "isDone": true},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My To-Do List")),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task['isDone'],
              onChanged: (bool? newValue) {
                setState(() {
                  task['isDone'] = newValue ?? false;
                });
              },
            ),
            title: Text(task['title']),
          );
        },
      ),
    );
  }
}
