import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/src/response.dart';
import 'package:intl/intl.dart';
import 'package:kiptrak/io/network.dart';
import 'package:kiptrak/search_answer_page.dart';
import 'package:kiptrak/search_user_page.dart';

import 'models/Assignment.dart';
import 'models/User.dart';
import 'assignment_detail_page.dart';
import 'create_assignment_page.dart';
import 'io/database.dart';

class MyHomeApp extends StatefulWidget {
  User user;

  MyHomeApp({Key? key, required this.user}) : super(key: key);

  @override
  State<MyHomeApp> createState() => _MyHomeAppState();
}

class _MyHomeAppState extends State<MyHomeApp> {
  var formattedDate;
  late ValueNotifier<List<AssignmentGlobalReadDto>> assignments;
  var currentView;
  var currentAssignments;
  bool reload = true;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    var now = DateTime.now();
    formattedDate = DateFormat('EEEE, dd MMMM').format(now);
    currentView = 'All';
    assignments = ValueNotifier<List<AssignmentGlobalReadDto>>([]);
  }

  Offset _tapPosition = Offset.zero;

  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    setState(() {});
  }

  Future<void> _showContextMenu(
      BuildContext context, AssignmentGlobalReadDto assignment) async {
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();
    final result = await showMenu(
        context: context,
        color: Color(0xFF152d32),
        position: RelativeRect.fromRect(
            Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),
        items: [
          const PopupMenuItem(
            value: 'searchTitle',
            child: Text(
              'Search by Title',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const PopupMenuItem(
            value: 'searchDesc',
            child: Text(
              'Search by Description',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const PopupMenuItem(
            value: 'Delete',
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]);

    switch (result) {
      case 'Delete':
        KiptrakDatabase.updateGlobalAssignmentStatus(
            assignment.id, AssignmentStatus.deleted.name);
        setState(() {});
        break;
      case 'searchTitle':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SearchAnswerPage(searchTerm: assignment.title),
        ));
        break;
      case 'searchDesc':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SearchAnswerPage(searchTerm: assignment.description),
        ));
        break;
    }
  }

  String getCardStatus(index) {
    var daysLeft = (currentAssignments[index]
                .dateDue
                .difference(DateTime.now())
                .inSeconds /
            86400)
        .ceil();

    if (daysLeft == 1) {
      return '1 day left';
    } else if (daysLeft == 0) {
      return '0 days left';
    } else if (daysLeft < 0) {
      return 'Overdue';
    } else {
      return '$daysLeft days left';
    }
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<List<AssignmentGlobalReadDto>?> loadAssignments() async {
    print("loading Assignments");
    if (!reload) {
      return await KiptrakDatabase.getGlobalAssignments();
    }
    // if(!(await hasNetwork())){
    //   reload = false;
    //   return await KiptrakDatabase.getGlobalAssignments();
    // }
    print("loading from net");
    Response response;
    try {
      response = await KiptrakNetwork.getOnlineAssignments();
      print(response.statusCode);
    } on Exception catch (e) {
      reload = false;
      return await KiptrakDatabase.getGlobalAssignments();
    }
    if (response.statusCode == 200) {
      var assignments = jsonDecode(response.body);
      var processed = List.generate(assignments.length, (index) {
        return AssignmentOnlineReadDto.fromJson(assignments[index]);
      });
      for (var item in processed) {
        await KiptrakDatabase.insertGlobalAssignment(item);
      }
      print("got here");
      reload = false;
      return await KiptrakDatabase.getGlobalAssignments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error syncing assignments"),
          backgroundColor: Colors.orange,
        ),
      );
      reload = false;
      return await KiptrakDatabase.getGlobalAssignments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding:
                  const EdgeInsets.only(top: 30.0, left: 10.0, bottom: 15.0),
              width: double.infinity,
              //Color(0xFF4169e1),
              height: 220.0,
              decoration: const BoxDecoration(
                color: Color(0xFF152d32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hello, ${widget.user.username[0].toUpperCase()}${widget.user.username.substring(1).toLowerCase()}',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 35,
                            color: Colors.white,
                            fontFamily: ''),
                      ),
                      Container(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: TextButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchUserPage()),
                              );
                              setState(() {
                                reload = true;
                              });
                            },
                            child: const Icon(
                              Icons.person_add,
                              color: Colors.white,
                              size: 25.0,
                            ),
                          )),
                    ],
                  ),
                  Text(formattedDate,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      )),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(
                            margin:
                                const EdgeInsets.only(top: 5.0, right: 20.0),
                            padding: const EdgeInsets.all(20.0),
                            decoration: const BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 90.0,
                            child: Row(
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 15.0),
                                  child: const Icon(
                                    Icons.hourglass_bottom_rounded,
                                    size: 50.0,
                                    color: Colors.white,
                                  ),
                                ),
                                ValueListenableBuilder(
                                    valueListenable: assignments,
                                    builder: (context, value, _) {
                                      return RichText(
                                        text: TextSpan(
                                            text:
                                                'Pending \n${value.where((x) => x.status == AssignmentStatus.pending).toList().length ?? 0}',
                                            style: const TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => {
                                                    setState(() {
                                                      currentView = 'Pending';
                                                      currentAssignments =
                                                          assignments.value
                                                              ?.where((x) =>
                                                                  x.status ==
                                                                  AssignmentStatus
                                                                      .pending)
                                                              .toList();
                                                    })
                                                  }),
                                      );
                                    })
                              ],
                            )),
                        Container(
                            margin:
                                const EdgeInsets.only(top: 5.0, right: 20.0),
                            padding: const EdgeInsets.all(20.0),
                            decoration: const BoxDecoration(
                              color: Color(0xFF438029),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 90.0,
                            child: Row(children: [
                              Container(
                                margin: const EdgeInsets.only(right: 15.0),
                                child: const Icon(
                                  Icons.check_circle,
                                  size: 50.0,
                                  color: Colors.white,
                                ),
                              ),
                              ValueListenableBuilder(
                                  valueListenable: assignments,
                                  builder: (context, value, _) {
                                    return RichText(
                                      text: TextSpan(
                                          text:
                                              'Completed \n${assignments.value?.where((x) => x.status == AssignmentStatus.completed).toList().length ?? 0}',
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => {
                                                  setState(() {
                                                    currentView = 'Completed';
                                                    currentAssignments =
                                                        assignments
                                                            .value
                                                            ?.where((x) =>
                                                                x.status ==
                                                                AssignmentStatus
                                                                    .completed)
                                                            .toList();
                                                  })
                                                }),
                                    );
                                  }),
                            ])),
                        Container(
                            margin:
                                const EdgeInsets.only(top: 5.0, right: 20.0),
                            padding: const EdgeInsets.all(20.0),
                            decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 90.0,
                            child: Row(
                              //mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 15.0),
                                  child: const Icon(
                                    Icons.view_agenda_outlined,
                                    size: 50.0,
                                    color: Colors.white,
                                  ),
                                ),
                                ValueListenableBuilder(
                                    valueListenable: assignments,
                                    builder: (context, value, _) {
                                      return RichText(
                                        text: TextSpan(
                                            text:
                                                'View All \n${assignments.value?.length ?? 0}',
                                            style: const TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => {
                                                    setState(() {
                                                      currentView = 'All';
                                                      currentAssignments =
                                                          assignments;
                                                    })
                                                  }),
                                      );
                                    }),
                              ],
                            )),
                      ],
                    ),
                  )
                ],
              )),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10.0),
            alignment: Alignment.centerLeft,
            child: Text('$currentView Assignments',
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                )),
          ),
          FutureBuilder(
              future: loadAssignments(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    assignments.value =
                        snapshot.data as List<AssignmentGlobalReadDto>;
                    currentAssignments = assignments.value
                        .where((x) => (currentView == "All"
                            ? true
                            : x.status
                                .toString()
                                .contains(currentView.toLowerCase())))
                        .toList();
                  });
                  if (snapshot.data!.isNotEmpty) {
                    currentAssignments = snapshot.data!
                        .where((x) => (currentView == "All"
                            ? true
                            : x.status
                                .toString()
                                .contains(currentView.toLowerCase())))
                        .toList();
                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        itemCount: currentAssignments.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AssignmentDetailsPage(
                                        ard: currentAssignments[index]),
                                  ));
                                },
                                onLongPress: () async {
                                  await _showContextMenu(
                                      context, currentAssignments[index]);
                                  setState(() {});
                                },
                                onTapDown: (details) =>
                                    _getTapPosition(details),
                                child: Dismissible(
                                    key: ValueKey(123),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: currentAssignments[index].status ==
                                              AssignmentStatus.pending
                                          ? Colors.greenAccent
                                          : Colors.pink,
                                      alignment: Alignment.centerRight,
                                      padding:
                                          const EdgeInsets.only(right: 15.0),
                                      child: Icon(
                                          currentAssignments[index].status ==
                                                  AssignmentStatus.pending
                                              ? Icons.check_circle
                                              : Icons.hourglass_bottom_rounded,
                                          color: Colors.white,
                                          size: 40.0),
                                    ),
                                    confirmDismiss: (direction) async {
                                      await KiptrakDatabase
                                          .updateGlobalAssignmentStatus(
                                              currentAssignments[index].id,
                                              currentAssignments[index]
                                                          .status ==
                                                      AssignmentStatus.pending
                                                  ? AssignmentStatus
                                                      .completed.name
                                                  : AssignmentStatus
                                                      .pending.name);
                                      setState(() {});
                                      return false;
                                    },
                                    child: Container(
                                        height: 85,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '${currentAssignments[index].title}',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                            Text(
                                                '${currentAssignments[index].course}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic,
                                                )),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    'Lecturer: ${currentAssignments[index].lecturer}',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    )),
                                                Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0),
                                                  decoration: const BoxDecoration(
                                                      color: Color(0xFFFAF9F6),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
                                                  child:
                                                      Text(getCardStatus(index),
                                                          style: TextStyle(
                                                            color: (currentAssignments[index].dateDue.difference(DateTime.now()).inSeconds /
                                                                            86400)
                                                                        .ceil() <
                                                                    2
                                                                ? Colors.pink
                                                                : Colors.green,
                                                          )),
                                                ),
                                              ],
                                            )
                                          ],
                                        ))),
                              ),
                              const SizedBox(
                                height: 10.0,
                              )
                            ],
                          );
                        },
                      ),
                    );
                  } else {
                    return Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'You currently do not \nhave any assignment',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 24.0,
                                fontFamily: 'Arial',
                              ),
                            )));
                  }
                } else {
                  return const Expanded(
                      child: Center(
                    child: CircularProgressIndicator(),
                  ));
                }
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateAssignmentPage()),
          );

          setState(() {
            reload = true;
          });
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
        backgroundColor: Color(0xFF152d32),
      ),
    );
  }
}
