import 'dart:convert';
import 'dart:developer' as logDev;

import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:http/http.dart';
import 'package:kiptrak/database.dart';
import 'package:kiptrak/home_page.dart';
import 'package:kiptrak/network.dart';

import 'User.dart';

class VerifyUserPage extends StatefulWidget {
  User user;

  VerifyUserPage({Key? key, required User this.user}) : super(key: key);

  @override
  State<VerifyUserPage> createState() => _VerifyUserPageState();
}

class _VerifyUserPageState extends State<VerifyUserPage> {

  String? _code;
  bool? _onEditing;

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 15.0),
            color: Color(0xFF152d32),
            child: Column(
              children: [
                Text('Enter Code: ',
                    style: TextStyle(fontSize: 30.0, color: Colors.white)),
                Text('Please provide the 6 digits token sent to your mail',
                    style: TextStyle(color: Colors.white)),
                SizedBox(
                  height: 20.0,
                ),
                VerificationCode(
                    textStyle: TextStyle(fontSize: 20.0, color: Colors.pink),
                    fullBorder: true,
                    length: 6,
                    onCompleted: (String value) {
                      setState(() {
                        _code = value;
                      });
                    },
                    onEditing: (bool value) {
                      setState(() {
                        _onEditing = value;
                      });
                    }),
                SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40),
                      backgroundColor: Colors.pinkAccent,
                    ),
                    onPressed: _code == null
                        ? null
                        : () async {
                            logDev.log("Verifying User...");
                            var response = await KiptrakNetwork.verify_user(
                                token: _code!, email: widget.user.email);
                            Response loginResponse;
                            if (response.statusCode == 200 &&
                                jsonDecode(response.body)['valid'] == true) {
                              logDev.log("Username: ${widget.user.userName}");
                              logDev.log("Password: ${widget.user.password}");
                              loginResponse = await KiptrakNetwork.login(
                                  username: widget.user.userName,
                                  password: widget.user.password);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Error verifying user"),
                                  backgroundColor: Colors.pink,
                                ),
                              );
                              return;
                            }
                            logDev.log(loginResponse.statusCode.toString());
                            if (loginResponse.statusCode == 200) {
                              var token =
                                  jsonDecode(loginResponse.body)['token'];
                              logDev.log(token);
                              widget.user.token = token;
                              await KiptrakDatabase.insertUserDetails(
                                  user: widget.user);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyHomeApp(user: widget.user),
                                  ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error logging in"),
                                  backgroundColor: Colors.pink,
                                ),
                              );
                            }
                          },
                    child: Text('Verify'))
              ],
            )));
  }
}
