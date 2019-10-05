import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> signup(String email, String password) async {
    final response = await http.post('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDAfPkVnY7Ww3pYq1UibyAYBcDiRJBvZk0',
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true
      })
    );

    print(json.decode(response.body));
  }
}