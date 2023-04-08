import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/Assignment.dart';
import 'custom_form.dart';

class AssignmentDetailsPage extends StatefulWidget {
  AssignmentGlobalReadDto ard;

  AssignmentDetailsPage({Key? key, required AssignmentGlobalReadDto this.ard})
      : super(key: key);

  @override
  State<AssignmentDetailsPage> createState() => _AssignmentDetailsPageState();
}

class _AssignmentDetailsPageState extends State<AssignmentDetailsPage> {
  TextEditingController titleCtl = TextEditingController();
  List<String>? imagesArray;
  @override
  void initState() {
    titleCtl.text = widget.ard.title;
    if (widget.ard.images != null && widget.ard.images != "") {
      imagesArray = widget.ard.images!.split("|");
    }
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
                  ),
                  Text(
                    widget.ard.description,
                  ),
                  Text(widget.ard.course),
                  Text(widget.ard.lecturer),
                  Text(widget.ard.dateDue.toString().split(' ')[0]),
                  Text(widget.ard.notes ?? ""),
                  if (widget.ard.images != null && widget.ard.images != "")
                    for (var image in imagesArray!)
                      Column(
                        children: [
                          Image.network(
                            image,
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      )
                ],
              )),
        ));
  }
}
