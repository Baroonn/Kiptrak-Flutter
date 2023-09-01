import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/Assignment.dart';

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
          backgroundColor: const Color(0xFF152d32),
          title: Text(
            titleCtl.text,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 10.0),
                      //margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF656565),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.ard.description,
                                style: const TextStyle(
                                  color: Colors.white,
                                )),
                            Text(
                                "\nCourse: ${widget.ard.course}\nLecturer: ${widget.ard.lecturer}\nDate Due: ${widget.ard.dateDue.toString().split(' ')[0]}\n",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ))
                          ])),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 10.0),
                      //margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Notes:\n${widget.ard.notes == null || widget.ard.notes == "" ? "*" : widget.ard.notes}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold
                                )
                            ),

                          ])),
                  const SizedBox(
                    height: 10,
                  ),
                  if (widget.ard.images != null && widget.ard.images != "")
                    for (var image in imagesArray!)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(image);
                              if (!await launchUrl(url)) {
                                throw Exception('Could not get image');
                              }
                            },
                            child: Image.network(image),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      )
                ],
              )),
        ));
  }
}
