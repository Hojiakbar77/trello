import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';



import '../../task/screen/task_screen.dart';
import '../service/log_in_service.dart';




class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String errorMessage = 'Please check email and password';
  bool isLoading = false; // Added to track loading state

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Error'),

          content: Text(errorMessage),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loginUser(String username, String password) async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    // Perform the login operation
    await loginUser(username, password);

    final box = GetStorage();
    final String? token = box.read('token');

    setState(() {
      isLoading = false; // Set loading state to false
    });

    if (token != null) {
      // Successfully logged in, navigate to the TaskBoard page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TaskBoard(),
        ),
      );
    } else {
      // Handle the case where the token is not available
      _showErrorDialog();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username',border: OutlineInputBorder()),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: passwordController,

                  decoration: const InputDecoration(labelText: 'Password',border: OutlineInputBorder()),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, attempt to log in
                      final username = usernameController.text;
                      final password = passwordController.text;

                      // Call the _loginUser function with credentials
                      _loginUser(username, password);
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator() // Show a loading indicator
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

