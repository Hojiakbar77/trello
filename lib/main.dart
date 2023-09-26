import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trello/auth/screens/login.dart';
import 'package:trello/task/screen/task_screen.dart';
import 'package:trello/utils/const.dart';

import 'auth/service/log_in_service.dart';




void main() {
  runApp( ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  final box = GetStorage();
  LoginService authClass = LoginService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.green,
            ),
            home: snapshot.data == true ? TaskBoard() : const LoginPage(),
          );
        } else {
          // You can return a loading indicator or another widget while waiting
          return const Center(child: CircularProgressIndicator(color: colorWhite,));
        }
      },
    );
  }

  Future<bool> checkLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Add a delay of 1 seconds (adjust as needed)
    String? token = await box.read("token");
    return token != null && token.isNotEmpty;
  }
}



