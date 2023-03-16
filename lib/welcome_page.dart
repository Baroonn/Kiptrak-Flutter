import 'package:flutter/material.dart';

import 'create_account_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailCtl = TextEditingController();

  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                color: Color(0xFF152d32),
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: Text('Welcome \nto \nKiptrak',
                            style: TextStyle(
                                color: Colors.white, fontSize: 30.0))),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Enter your email',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Form(
                            key: _formKey,
                            child: Column(
                              children:[
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
                                    labelText: 'Email',
                                    fillColor: Colors.white,
                                    filled: true,
                                    prefixIcon: Icon(Icons.email),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                  ),
                                ),
                                SizedBox(height: 15.0),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(double.infinity, 40),
                                      backgroundColor: Colors.pinkAccent,
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => CreateAccountPage(
                                                  email: _emailCtl.text)),
                                        );
                                      }
                                    },
                                    child: Text('Continue'))
                              ]
                            )
                          ),

                        ],
                      ),
                    )
                  ],
                ))));
  }
}
