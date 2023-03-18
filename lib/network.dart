import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'User.dart';

class KiptrakNetwork{
  static Future<Response> postUser({required User user}) async {
    return http.post(
      Uri.parse('http://10.0.2.2:5000/api/1/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toMap())
    );
  }

  static Future<Response> login({required String username,
    required String password}) async {
    return http.post(
        Uri.parse('http://10.0.2.2:5000/api/1/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userName': username,
          'password': password,
        })
    );
  }

  static Future<Response> verify_user({required String code, required String email, required String username}) async{
    return http.get(
      Uri.parse('http://10.0.2.2:5000/api/1/auth/validatecode?code=$code&email=$email&username=$username'),
    );
  }

}