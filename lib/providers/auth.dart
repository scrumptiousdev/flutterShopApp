import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    try {
      final response = await http.post('https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDAfPkVnY7Ww3pYq1UibyAYBcDiRJBvZk0',
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true
        })
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) throw HttpException(responseData['error']['message']);
    } catch (err) {
      throw err;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}