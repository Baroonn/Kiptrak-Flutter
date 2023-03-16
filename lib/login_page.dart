import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiptrak/network.dart';
import 'package:kiptrak/verify_user_page.dart';
import 'Assignment.dart';
import 'User.dart';
import 'create_account_page.dart';
import 'custom_form.dart';
import 'database.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  String email;

  LoginPage({Key? key, required this.email}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userCtl = TextEditingController();
  TextEditingController _passCtl = TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF152d32),
          title: Text(
            'Login',
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                color: Color(0xFF152d32),
                child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      top: 50.0,
                    ),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _userCtl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.pink,
                              ),
                              labelText: 'Username*',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                  Icons.person
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          TextFormField(
                            controller: _passCtl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.pink,
                              ),
                              labelText: 'Password*',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                  Icons.lock
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 40),
                              backgroundColor: Colors.pinkAccent,
                            ),
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                var response = await KiptrakNetwork.login(
                                  username: _userCtl.text,
                                  password: _passCtl.text
                                );

                                if(response.statusCode == 200){
                                  var body = jsonDecode(response.body);
                                  var valid = body['valid'];
                                  var token = body['token'];
                                  if(valid != null && valid == true){
                                    var user = User(userName: _userCtl.text, password: _passCtl.text, email: widget.email);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VerifyUserPage(user: user),
                                        ));
                                  }
                                  else if(token!=null){
                                    var user = User(userName: _userCtl.text, password: _passCtl.text, email: widget.email, token: token);
                                    await KiptrakDatabase.insertUserDetails(user: user);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyHomeApp(user: user),
                                        ));
                                  }
                                  else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error logging in"),
                                        backgroundColor: Colors.pink,
                                      ),
                                    );
                                  }
                                }
                                else if(response.statusCode == 401){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Invalid Username or Password"),
                                      backgroundColor: Colors.pink,
                                    ),
                                  );
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error logging in"),
                                      backgroundColor: Colors.pink,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('LOGIN'),
                          ),
                          const SizedBox(height: 15.0),
                          RichText(
                            text: TextSpan(
                                text:'Not a user? ',
                                children: [
                                  TextSpan(
                                      text: 'Create Account',
                                      style: TextStyle(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = (){
                                          Navigator.pushReplacement(context,
                                            MaterialPageRoute(builder: (context)=> CreateAccountPage(email: widget.email)),);
                                        }
                                  )
                                ]
                            ),
                          )
                          // Add TextFormFields and ElevatedButton here.
                        ],
                      ),
                    )
                )
            )
        )
    );
  }
}
