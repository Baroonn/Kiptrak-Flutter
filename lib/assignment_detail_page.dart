import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/Assignment.dart';
import 'custom_form.dart';

class AssignmentDetailsPage extends StatefulWidget {
  AssignmentGlobalReadDto ard;

  AssignmentDetailsPage({Key? key, required AssignmentGlobalReadDto this.ard}) : super(key: key);

  @override
  State<AssignmentDetailsPage> createState() => _AssignmentDetailsPageState();
}

class _AssignmentDetailsPageState extends State<AssignmentDetailsPage> {
  TextEditingController titleCtl = TextEditingController();

  @override
  void initState(){
    titleCtl.text = widget.ard.title;
    super.initState();
  }
  _AssignmentDetailsPageState();

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: Text(
            'Details',
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: [
                TextField(
                  controller: titleCtl,
                )
              ],
            )
          ),
        )
    );
  }
}
