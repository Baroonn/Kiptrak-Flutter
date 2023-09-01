import 'package:flutter/material.dart';
import 'custom_form.dart';

class CreateAssignmentPage extends StatefulWidget {

  const CreateAssignmentPage({Key? key}) : super(key: key);

  @override
  State<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends State<CreateAssignmentPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF152d32),
        title: const Text(
          'Create Assignment',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: MyCustomForm(),
        ),
      )
    );
  }
}
