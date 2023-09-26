import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../utils/const.dart';


class LoginService{

}
Future<void> loginUser(String login, String password) async {
  final box = GetStorage();

  String apiUrl = '$baseUrl/api/v2/auth/login'; // Replace with your API URL

  final Map<String, dynamic> requestData = {
    'login': login,
    'password': password,
  };

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestData),
  );

  if (response.statusCode == 201) {
    // Login successful, parse the response data
    final responseData = jsonDecode(response.body);

    // Check if the response contains a token
    if (responseData.containsKey('token')) {
      final String token = responseData['token'];


      // Store the token in local storage
      box.write('token', token);

      print('Login successful. Token: $token');
    } else {
      // Handle the case where the response does not contain a token
      print('Login successful, but token is missing in the response.');
    }
  } else if (response.statusCode == 404) {
    // Unauthorized, handle invalid credentials here
    print('Invalid username or password.');
  } else {
    // Handle other error cases
    print('Request failed with status: ${response.statusCode}');
    print('Error message: ${response.body}');
  }
}
