import 'dart:convert';
import 'dart:developer' as logDev;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kiptrak/database.dart';
import 'package:kiptrak/network.dart';
import 'package:kiptrak/verify_user_page.dart';
import 'User.dart';
import 'login_page.dart';

class CreateAccountPage extends StatefulWidget {
  String email;
  CreateAccountPage({Key? key, required this.email}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userCtl = TextEditingController();
  TextEditingController _passCtl = TextEditingController();
  TextEditingController _emailCtl = TextEditingController();
  TextEditingController _phoneCtl = TextEditingController();

  @override
  void initState() {
    logDev.log("Init State Called");
    // TODO: implement initState
    super.initState();
    _emailCtl.text = widget.email;
    //onStart();
  }

  void onStart() async {
    logDev.log("onStart Called");
    await KiptrakDatabase.createDatabase();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF152d32),
          title: Text(
            'Create Account',

          ),
        ),
        body: SingleChildScrollView(
            child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height,
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
                          SizedBox(height: 30.0),
                          TextFormField(
                            controller: _passCtl,
                            keyboardType: TextInputType.multiline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              if(value.length < 10){
                                return 'Password must be at least 10 characters';
                              }
                              if(!value.contains(new RegExp(r'[0-9]')))
                              {
                                return 'Password must contain at least 1 digit';
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
                          SizedBox(height: 30.0),
                          TextFormField(
                            controller: _emailCtl,
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
                              labelText: 'Email*',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                  Icons.email
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            ),
                          ),
                          SizedBox(height: 30.0),
                          TextFormField(
                            controller: _phoneCtl,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.pink,
                              ),
                              labelText: 'Phone',
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(
                                  Icons.phone
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 40),
                              backgroundColor: Colors.pinkAccent,
                            ),
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Processing Data')),
                                );

                                User user = User(userName: _userCtl.text, password: _passCtl.text, email: _emailCtl.text, phoneNumber: _phoneCtl.text);

                                var response = await KiptrakNetwork.postUser(user: user);
                                if(response.statusCode == 201){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Created User Successfully'),
                                      backgroundColor: Colors.green,),
                                  );

                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context)=> VerifyUserPage(user: user)),);
                                }
                                else if(response.statusCode == 400){
                                  Map<String, dynamic> responseBody = jsonDecode(response.body);
                                  String message = "";
                                  for(var i in responseBody.keys){
                                    message += responseBody[i][0];
                                    break;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: Colors.pink,),
                                  );
                                }
                                else{
                                  print(response.body);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error creating user: ${response.statusCode.toString()}')),
                                  );
                                }
                              }
                            },
                            child: const Text('CREATE ACCOUNT'),
                          ),
                          const SizedBox(height: 15.0),
                          RichText(
                            text: TextSpan(
                                text:'Already a user? ',
                                children: [
                                  TextSpan(
                                      text: 'Login',
                                      style: TextStyle(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = (){
                                          Navigator.push(context,
                                            MaterialPageRoute(builder: (context)=> LoginPage(email: _emailCtl.text)),);
                                        }
                                  )
                                ]
                            ),
                          )
                        ],
                      ),
                    )
                )
            )
        )
    );
  }
}
