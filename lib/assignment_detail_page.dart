import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Assignment.dart';
import 'custom_form.dart';

class AssignmentDetailsPage extends StatefulWidget {
  final AssignmentReadDto ard;

  const AssignmentDetailsPage({Key? key, required AssignmentReadDto this.ard}) : super(key: key);

  @override
  State<AssignmentDetailsPage> createState() => _AssignmentDetailsPageState(ard: ard);
}

class _AssignmentDetailsPageState extends State<AssignmentDetailsPage> {

  AssignmentReadDto ard;

  _AssignmentDetailsPageState({required AssignmentReadDto this.ard}){
    titleCtl.text = ard.title;
  }
  TextEditingController titleCtl = TextEditingController();
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
