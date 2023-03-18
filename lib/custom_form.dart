import 'dart:io';
import 'dart:developer' as logDev;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kiptrak/database.dart';

import 'Assignment.dart';

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  TextEditingController titleCtl = TextEditingController();
  TextEditingController descCtl = TextEditingController();
  TextEditingController courseCtl = TextEditingController();
  TextEditingController lecturerCtl = TextEditingController();
  TextEditingController dateCtl = TextEditingController();
  TextEditingController notesCtl = TextEditingController();
  FilePickerResult? result = null;
  List<PlatformFile>? files;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if(picked != null) setState(() => dateCtl.text = picked.toString().split(" ")[0]);

  }


  @override
  Widget build(BuildContext context) {

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: titleCtl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Title*',
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: descCtl,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Description*',
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: courseCtl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Course*',
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: lecturerCtl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Lecturer*',
            ),

          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: dateCtl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Date Due*',
            ),
            onTap: (){
              // Below line stops keyboard from appearing
              FocusScope.of(context).requestFocus(new FocusNode());

              // Show Date Picker Here
              _selectDate();
            },

          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: notesCtl,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Notes',
            ),
          ),
          SizedBox(height: 20.0),
          Wrap(
            children: [
              if(result!=null)
                for(PlatformFile file in result!.files)
                  Image.file(
                    File(file.path.toString()),
                    width: 50,
                    height: 50,
                  ),
              Row(
                children: [

                  // OutlinedButton(
                  //   onPressed: (){},
                  //   child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children:[
                  //         Container(
                  //           child: Icon(
                  //             Icons.add_a_photo_outlined,
                  //             size: 20.0,
                  //             color: Colors.black,
                  //           ),
                  //           padding: EdgeInsets.only(right: 10.0),
                  //         ),
                  //         Text(
                  //             'Camera',
                  //             style: TextStyle(
                  //               color: Colors.black,
                  //             )
                  //         ),
                  //       ]
                  //   ),
                  // ),
                  //SizedBox(width: 30.0),
                  OutlinedButton(
                    onPressed: () async {
                      result = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      if (result == null) {
                        print("No file selected");
                      } else {
                        setState(() {
                          result?.files.forEach((element) {
                            print(element.name);
                          });
                        });
                      }
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Container(
                            padding: EdgeInsets.only(right: 10.0),
                            child: const Icon(
                              Icons.image_rounded,
                              size: 20.0,
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                              'Add Image',
                              style: TextStyle(
                                color: Colors.black,
                              )
                          ),
                        ]
                    ),
                  ),
                ],
              ),

            ],
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
                  logDev.log(DateTime.parse(dateCtl.text).millisecondsSinceEpoch.toString());
                  AssignmentCreateDto fresh = AssignmentCreateDto(
                    title: titleCtl.text,
                    desc: descCtl.text,
                    course: courseCtl.text,
                    lecturer: lecturerCtl.text,
                    dateDue: DateTime.parse(dateCtl.text).millisecondsSinceEpoch,
                    notes: notesCtl.text,
                    imagePath: result != null? result!.files.map((x)=> x.path).join("|"):"",
                    status: AssignmentStatus.pending
                  );
                  await KiptrakDatabase.insertLocalAssignment(fresh);
                  titleCtl.clear(); descCtl.clear(); courseCtl.clear();
                  lecturerCtl.clear(); dateCtl.clear(); notesCtl.clear();
                }
              },

              child: const Text('SAVE'),
            ),

          // Add TextFormFields and ElevatedButton here.
        ],
      ),
    );
  }
}