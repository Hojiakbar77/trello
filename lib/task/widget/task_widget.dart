import 'package:flutter/material.dart';

import '../../utils/const.dart';

class TaskColumn extends StatelessWidget {
  final String title;
  final List<String> tasks;
  final Function(String, String) onAddTask;
  final Function(int, int) onSwapTasks;
  final Function(String, String) onTaskOptions;

  TaskColumn({
    required this.title,
    required this.tasks,
    required this.onAddTask,
    required this.onSwapTasks,
    required this.onTaskOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorGreen, // Background color for the title container
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              padding: EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  color: colorWhite, // Text color for the title
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ReorderableListView(
                onReorder: (int oldIndex, int newIndex) {
                  // Handle task reordering
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  onSwapTasks(oldIndex, newIndex);
                },
                children: tasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final task = entry.value;

                  return Card(
                    key: ValueKey(task),
                    elevation: 3.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(task),
                      onTap: () {
                        // Show task options dialog
                        onTaskOptions(task, title);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                // Show add task dialog
                _showAddTaskDialog(context);
              },
              child: Text('+ Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String task = ''; // Initialize task
        String selectedStatus = title; // Initialize selected status

        return AlertDialog(
          title: Text('Add Task to $title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Task'),
                onChanged: (value) {
                  task = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                onAddTask(task, selectedStatus);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
