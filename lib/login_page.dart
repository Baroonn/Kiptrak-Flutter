import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kiptrak/io/network.dart';
import 'package:kiptrak/verify_user_page.dart';
import 'models/User.dart';
import 'io/database.dart';
import 'home_page_test.dart';

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
                                color: Colors.deepOrange,
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
                                color: Colors.deepOrange,
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
                              backgroundColor: Colors.deepOrange,
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
                                  var token = body['token'];
                                  if(token!=null){
                                    var user = User(username: _userCtl.text, password: _passCtl.text, email: widget.email, token: token);
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
                                        backgroundColor: Colors.deepOrange,
                                      ),
                                    );
                                  }
                                }
                                else if(response.statusCode == 403){
                                  var user = User(username: _userCtl.text, password: _passCtl.text, email: widget.email);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VerifyUserPage(user: user),
                                      ));
                                }
                                else if(response.statusCode == 401){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(jsonDecode(response.body)["message"]),
                                      backgroundColor: Colors.deepOrange,
                                    ),
                                  );
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error logging in: ${jsonDecode(response.body)["message"]}"),
                                      backgroundColor: Colors.deepOrange,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('LOGIN'),
                          ),
                          const SizedBox(height: 15.0),
                          // RichText(
                          //   text: TextSpan(
                          //       text:'Not a user? ',
                          //       children: [
                          //         TextSpan(
                          //             text: 'Create Account',
                          //             style: TextStyle(color: Colors.blue),
                          //             recognizer: TapGestureRecognizer()
                          //               ..onTap = (){
                          //                 Navigator.pushReplacement(context,
                          //                   MaterialPageRoute(builder: (context)=> CreateAccountPage(email: widget.email)),);
                          //               }
                          //         )
                          //       ]
                          //   ),
                          // )
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
