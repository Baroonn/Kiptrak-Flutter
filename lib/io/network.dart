import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kiptrak/models/Assignment.dart';
import 'package:kiptrak/io/database.dart';

import '../models/User.dart';

class KiptrakNetwork {
  static const baseUrl = 'https://kiptrak.herokuapp.com';
  static Future<Response> postUser({required User user}) async {
    return http.post(Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toMap()));
  }

  static Future<Response> login(
      {required String username, required String password}) async {
    return http.post(Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }));
  }

  static Future<void> loginAgain() async {
    var user = await KiptrakDatabase.getUser();
    var response = await http.post(Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': user!.userName,
          'password': user.password,
        }));

    if (response.statusCode == 200) {
      await KiptrakDatabase.updateToken(
          token: jsonDecode(response.body)['token']);
    }
  }

  static Future<Response> verifyUser(
      {required String code, required String username}) async {
    return http.get(
      Uri.parse(
          '$baseUrl/api/v1/auth/validatecode?code=$code&username=$username'),
    );
  }

  static Future<Response> getOnlineAssignments() async {
    var user = await KiptrakDatabase.getUser();
    var token = user?.token;
    var response = await http.get(Uri.parse('$baseUrl/api/v1/assignments'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        }).timeout(const Duration(seconds: 10));

    if(response.statusCode == 403){
      await loginAgain();
      return await getOnlineAssignments();
    }
    else{
      return response;
    }
  }

  static Future<Response> createOnlineAssignment(
      {required AssignmentOnlineCreateDto assignment}) async {
    var user = await KiptrakDatabase.getUser();
    var token = user?.token;
    var response = await http.post(
      Uri.parse('$baseUrl/api/v1/assignments'),
      body: jsonEncode(assignment.toMap()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return response;
    } else if (response.statusCode == 403) {
      await loginAgain();
      return await createOnlineAssignment(assignment: assignment);
    } else {
      return response;
    }
  }

  static Future<StreamedResponse> uploadImages(
      {required String id, required FilePickerResult result}) async {
    var user = await KiptrakDatabase.getUser();
    var token = user?.token;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/$id/imageupload'),
    );
    for (var file in result.files) {
      request.files.add(http.MultipartFile.fromBytes(
          'file', File(file!.path!).readAsBytesSync(),
          filename: file!.name));
    }
    request.headers['Authorization'] = 'Bearer $token';
    var res = await request.send();

    if (res.statusCode == 200) {
      return res;
    } else if (res.statusCode == 403) {
      await loginAgain();
      return await uploadImages(id: id, result: result);
    }
    return res;
  }

  //static Future<Ass>
}
