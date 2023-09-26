import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:trello/auth/screens/login.dart';
import 'package:trello/task/widget/task_widget.dart';

import '../../utils/const.dart';



class TaskBoard extends StatefulWidget {
  @override
  _TaskBoardState createState() => _TaskBoardState();
}

class _TaskBoardState extends State<TaskBoard> {
  List<String> newTasks = [];
  List<String> inProgressTasks = [];
  List<String> inReviewTasks = [];
  List<String> doneTasks = [];
  static const String taskDataKey = 'task_data';

  // Load task data from shared preferences when the app starts
  @override
  void initState() {
    super.initState();
    _loadTaskData();
     // Fetch data from the server when the app starts
  }
  void _navigateToLogin() async {
    // Clear local data
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    // Clear data stored with GetStorage
    final box = GetStorage();
    box.erase();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _loadTaskData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      newTasks = prefs.getStringList('newTasks') ?? [];
      inProgressTasks = prefs.getStringList('inProgressTasks') ?? [];
      inReviewTasks = prefs.getStringList('inReviewTasks') ?? [];
      doneTasks = prefs.getStringList('doneTasks') ?? [];
    });

    // If local storage is empty, fetch data from the server and store it locally
    if (newTasks.isEmpty &&
        inProgressTasks.isEmpty &&
        inReviewTasks.isEmpty &&
        doneTasks.isEmpty) {
      await fetchData();
    }
  }

  // Save task data to shared preferences when tasks are added or removed
  void _saveTaskData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('newTasks', newTasks);
    prefs.setStringList('inProgressTasks', inProgressTasks);
    prefs.setStringList('inReviewTasks', inReviewTasks);
    prefs.setStringList('doneTasks', doneTasks);
  }

  void addTask(String task, String status) {
    setState(() {
      switch (status) {
        case 'New':
          newTasks.insert(0, task);
          break;
        case 'In Progress':
          inProgressTasks.insert(0, task);
          break;
        case 'In Review':
          inReviewTasks.insert(0, task);
          break;
        case 'Done':
          doneTasks.insert(0, task);
          break;
        default:
          break;
      }
      // Save task data
      _saveTaskData();
    });
  }

  void removeTask(String task, String status) {
    setState(() {
      switch (status) {
        case 'New':
          newTasks.remove(task);
          break;
        case 'In Progress':
          inProgressTasks.remove(task);
          break;
        case 'In Review':
          inReviewTasks.remove(task);
          break;
        case 'Done':
          doneTasks.remove(task);
          break;
        default:
          break;
      }
      // Save task data
      _saveTaskData();
    });
  }

  void deleteTask(String task, String status) {
    setState(() {
      switch (status) {
        case 'New':
          newTasks.remove(task);
          break;
        case 'In Progress':
          inProgressTasks.remove(task);
          break;
        case 'In Review':
          inReviewTasks.remove(task);
          break;
        case 'Done':
          doneTasks.remove(task);
          break;
        default:
          break;
      }
      // Save task data
      _saveTaskData();
    });
  }

  void replaceTask(String currentTask, String newTask, String status) {
    setState(() {
      switch (status) {
        case 'New':
          final index = newTasks.indexOf(currentTask);
          if (index != -1) {
            newTasks[index] = newTask;
          }
          break;
        case 'In Progress':
          final index = inProgressTasks.indexOf(currentTask);
          if (index != -1) {
            inProgressTasks[index] = newTask;
          }
          break;
        case 'In Review':
          final index = inReviewTasks.indexOf(currentTask);
          if (index != -1) {
            inReviewTasks[index] = newTask;
          }
          break;
        case 'Done':
          final index = doneTasks.indexOf(currentTask);
          if (index != -1) {
            doneTasks[index] = newTask;
          }
          break;
        default:
          break;
      }
      // Save task data
      _saveTaskData();
    });
  }

  void moveTaskToState(String task, String currentStatus, String newStatus) {
    setState(() {
      removeTask(task, currentStatus);
      addTask(task, newStatus);
    });
  }

  void swapTasks(String status, int currentIndex, int newIndex) {
    setState(() {
      List<String> tasks;
      switch (status) {
        case 'New':
          tasks = newTasks;
          break;
        case 'In Progress':
          tasks = inProgressTasks;
          break;
        case 'In Review':
          tasks = inReviewTasks;
          break;
        case 'Done':
          tasks = doneTasks;
          break;
        default:
          return;
      }

      final task = tasks.removeAt(currentIndex);
      tasks.insert(newIndex, task);
      // Save task data
      _saveTaskData();
    });
  }

  Future<void> showTaskOptions(String task, String status) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Move Task to Another State'),
          children: <Widget>[
            if (status != 'New') // Exclude the current state from the options
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 'New');
                },
                child: const Text('New'),
              ),
            if (status != 'In Progress')
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 'In Progress');
                },
                child: const Text('In Progress'),
              ),
            if (status != 'In Review')
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 'In Review');
                },
                child: const Text('In Review'),
              ),
            if (status != 'Done')
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 'Done');
                },
                child: const Text('Done'),
              ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Delete');
              },
              child: const Text('Delete Task',style: TextStyle(color: colorRed),),
            ),
          ],
        );
      },
    );

    if (newStatus != null) {
      moveTaskToState(task, status, newStatus);
    }
  }


  List<String> statusTasks(String status) {
    switch (status) {
      case 'New':
        return newTasks;
      case 'In Progress':
        return inProgressTasks;
      case 'In Review':
        return inReviewTasks;
      case 'Done':
        return doneTasks;
      default:
        return [];
    }
  }

  void categorizeAndStoreDataLocally(List<dynamic> data) async {
    List<String> newTasks = [];
    List<String> inProgressTasks = [];
    List<String> inReviewTasks = [];
    List<String> doneTasks = [];

    for (final taskData in data) {
      final String status = taskData['status'];
      final String taskName = taskData['name'];

      switch (status) {
        case 'new':
          newTasks.add(taskName);
          break;
        case 'in_progress':
          inProgressTasks.add(taskName);
          break;
        case 'in_review':
          inReviewTasks.add(taskName);
          break;
        case 'done':
          doneTasks.add(taskName);
          break;
        default:
          break;
      }
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('newTasks', newTasks);
    prefs.setStringList('inProgressTasks', inProgressTasks);
    prefs.setStringList('inReviewTasks', inReviewTasks);
    prefs.setStringList('doneTasks', doneTasks);

    setState(() {
      this.newTasks = newTasks;
      this.inProgressTasks = inProgressTasks;
      this.inReviewTasks = inReviewTasks;
      this.doneTasks = doneTasks;
    });

    print('Data categorized and stored locally.');
  }

  Future<void> fetchData() async {
    final box = GetStorage();
     String apiUrl = '$baseUrl/api/v1/task/get_all_tasks';

    final String? bearerToken = box.read('token');

    if (bearerToken == null) {
      // Handle the case where the token is not available in local storage
      print('Token not found in local storage.');
      return;
    }

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $bearerToken', // Use the stored token
      },
    );

    if (response.statusCode == 200) {
      // Successfully fetched data, you can parse and use it here
      final List<dynamic> responseData = jsonDecode(response.body);
      categorizeAndStoreDataLocally(responseData); // Call the categorization function
    } else {
      // Handle errors, e.g., display an error message
      print('Request failed with status: ${response.statusCode}');
      print('Error message: ${response.body}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // You can change the icon as needed
            onPressed: _navigateToLogin,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/home.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          ListView(
            scrollDirection: Axis.horizontal, // Set the scroll direction to horizontal
            children: List.generate(
              4,
                  (index) {
                String title;
                List<String> tasks;

                switch (index) {
                  case 0:
                    title = 'New';
                    tasks = newTasks;
                    break;
                  case 1:
                    title = 'In Progress';
                    tasks = inProgressTasks;
                    break;
                  case 2:
                    title = 'In Review';
                    tasks = inReviewTasks;
                    break;
                  case 3:
                    title = 'Done';
                    tasks = doneTasks;
                    break;
                  default:
                    title = '';
                    tasks = [];
                    break;
                }

                return SizedBox(
                  width: 300, // Set a fixed width for each TaskColumn
                  child: TaskColumn(
                    title: title,
                    tasks: tasks,
                    onAddTask: addTask,
                    onSwapTasks: (currentIndex, newIndex) {
                      swapTasks(title, currentIndex, newIndex);
                    },
                    onTaskOptions: showTaskOptions,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
