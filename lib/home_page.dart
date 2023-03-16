import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:kiptrak/search_user_page.dart';

import 'Assignment.dart';
import 'User.dart';
import 'assignment_detail_page.dart';
import 'create_assignment_page.dart';
import 'database.dart';

class MyHomeApp extends StatefulWidget {
  User user;
  MyHomeApp({Key? key, required this.user}) : super(key: key);

  @override
  State<MyHomeApp> createState() => _MyHomeAppState();
}

class _MyHomeAppState extends State<MyHomeApp> {
  var formattedDate;
  var assignments;
  var currentView;
  var currentAssignments;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    var now = DateTime.now();
    formattedDate = DateFormat('EEEE, dd MMMM').format(now);
    currentView = 'All';
    // assignments = [
    //   Assignment(title: "No Sense of Place: The Impact of Electronic Media on Social Behavior", desc: 'This is a test assignment', course: 'CSC101', lecturer: 'Mr. Samuel', dateDue: DateTime.now(), notes: 'This is a test note', createdBy: 'Bolu', createdAt: DateTime.now(), status: AssignmentStatus.completed),
    //   Assignment(title: "A Sense of Place: The Impact of Electronic Media on Social Behavior", desc: 'This is a test assignment', course: 'CSC101', lecturer: 'Mr. Samuel', dateDue: DateTime.now(), notes: 'This is a test note', createdBy: 'Bolu', createdAt: DateTime.now(), status: AssignmentStatus.pending),
    //   Assignment(title: "Many Sense of Place: The Impact of Electronic Media on Social Behavior", desc: 'This is a test assignment', course: 'CSC101', lecturer: 'Mr. Samuel', dateDue: DateTime.now(), notes: 'This is a test note', createdBy: 'Bolu', createdAt: DateTime.now(), status: AssignmentStatus.completed),
    //   Assignment(title: "Any Sense of Place: The Impact of Electronic Media on Social Behavior", desc: 'This is a test assignment', course: 'CSC101', lecturer: 'Mr. Samuel', dateDue: DateTime.now(), notes: 'This is a test note', createdBy: 'Bolu', createdAt: DateTime.now(), status: AssignmentStatus.completed),
    //   Assignment(title: "Every Sense of Place: The Impact of Electronic Media on Social Behavior", desc: 'This is a test assignment', course: 'CSC101', lecturer: 'Mr. Samuel', dateDue: DateTime.now(), notes: 'This is a test note', createdBy: 'Bolu', createdAt: DateTime.now(), status: AssignmentStatus.pending),
    //   Assignment(title: "Some Sense of Place: The Impact of Electronic Media on Social Behavior", desc: 'This is a test assignment', course: 'CSC101', lecturer: 'Mr. Samuel', dateDue: DateTime.now(), notes: 'This is a test note', createdBy: 'Bolu', createdAt: DateTime.now(), status: AssignmentStatus.completed),
    // ];
  }

  Offset _tapPosition = Offset.zero;

  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    setState(() {});
  }

  Future<void> _showContextMenu(BuildContext context, AssignmentReadDto assignment) async {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();
    final result = await showMenu(
        context: context,
        color: Color(0xFF152d32),
        position: RelativeRect.fromRect(
            Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),
        items: [
          const PopupMenuItem(
            value: 'Answer',
            child: Text(
              'Find Answer',
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
        KiptrakDatabase.deleteLocalAssignments(assignment.id);
        break;
      case 'Answer':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchUserPage(searchTerm: assignment.title),
          )
        );
        break;
    }
  }

  String getCardStatus(index){
    var daysLeft = (currentAssignments[index].dateDue.difference(DateTime.now()).inSeconds/86400).ceil();

    if(daysLeft == 1){
      return '1 day left';
    }
    else if(daysLeft == 0){
      return '0 days left';
    }
    else if(daysLeft < 0){
      return 'Overdue';
    }
    else{
      return '$daysLeft days left';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF9F6),
      body: FutureBuilder(
          future: KiptrakDatabase.getLocalAssignments(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              assignments = snapshot.data as List<AssignmentReadDto>;
              currentAssignments = assignments
                  .where((x) => (currentView == "All"
                      ? true
                      : x.status
                          .toString()
                          .contains(currentView.toLowerCase())))
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 30.0),
                      width: double.infinity,
                      //Color(0xFF4169e1),
                      height: 250.0,
                      decoration: BoxDecoration(
                        color: Color(0xFF152d32),
                        //   borderRadius: BorderRadius.only(
                        //   bottomLeft: Radius.circular(20.0),
                        //   bottomRight: Radius.circular(20.0)
                        // )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${widget.user.userName??""}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                color: Colors.white,
                                fontFamily: ''),
                          ),
                          Text(formattedDate,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              )),
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // FractionallySizedBox(
                                //   widthFactor: 0.7,
                                //   heightFactor: 0.8,
                                // ),
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 20.0, right: 20.0),
                                    padding: EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: 90.0,
                                    child: Row(
                                      //mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 15.0),
                                          child: Icon(
                                            Icons.hourglass_bottom_rounded,
                                            size: 50.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              text:
                                                  'Pending \n${assignments?.where((x) => x.status == AssignmentStatus.pending).toList().length ?? 0}',
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () => {
                                                      setState(() {
                                                        currentView = 'Pending';
                                                        currentAssignments =
                                                            assignments
                                                                ?.where((x) =>
                                                                    x.status ==
                                                                    AssignmentStatus
                                                                        .pending)
                                                                .toList();
                                                      })
                                                    }),
                                        ),
                                      ],
                                    )),
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 20.0, right: 20.0),
                                    padding: EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: 90.0,
                                    child: Row(children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 15.0),
                                        child: Icon(
                                          Icons.check_circle,
                                          size: 50.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                            text:
                                                'Completed \n${assignments?.where((x) => x.status == AssignmentStatus.completed).toList().length ?? 0}',
                                            style: TextStyle(
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
                                                              ?.where((x) =>
                                                                  x.status ==
                                                                  AssignmentStatus
                                                                      .completed)
                                                              .toList();
                                                    })
                                                  }),
                                      ),
                                    ])),
                                Container(
                                    margin:
                                        EdgeInsets.only(top: 20.0, right: 20.0),
                                    padding: EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.lightGreen,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: 90.0,
                                    child: Row(
                                      //mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 15.0),
                                          child: Icon(
                                            Icons.view_agenda_outlined,
                                            size: 50.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              text:
                                                  'View All \n${assignments?.length ?? 0}',
                                              style: TextStyle(
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
                                        ),
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
                  if(assignments.length>0)
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        itemCount: currentAssignments.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap:(){
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AssignmentDetailsPage(ard: currentAssignments[index]),
                                      )
                                  );
                                },
                                onLongPress: () async {
                                  await _showContextMenu(
                                      context, currentAssignments[index]);
                                  setState(() {

                                  });
                                },
                                onTapDown: (details) => _getTapPosition(details),
                                child: Dismissible(
                                    key: ValueKey(123),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                        color: currentAssignments[index].status ==
                                            AssignmentStatus.pending
                                            ? Colors.greenAccent
                                            : Colors.pink,
                                        child: Icon(
                                            currentAssignments[index].status ==
                                                AssignmentStatus.pending
                                                ? Icons.check_circle
                                                : Icons.hourglass_bottom_rounded,
                                            color: Colors.white,
                                            size: 40.0),
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(right: 15.0)),
                                    confirmDismiss: (direction) async {
                                      await KiptrakDatabase
                                          .updateLocalAssignmentStatus(
                                          currentAssignments[index].id,
                                          currentAssignments[index].status ==
                                              AssignmentStatus.pending
                                              ? AssignmentStatus
                                              .completed.name
                                              : AssignmentStatus
                                              .pending.name);
                                      setState(() {});
                                      print("update executed");
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
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic,
                                                )),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                    'Lecturer: ${currentAssignments[index].lecturer}',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontStyle: FontStyle.italic,
                                                    )),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFFFAF9F6),
                                                      borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10.0))),
                                                  child:
                                                  Text(
                                                      getCardStatus(index),
                                                      style: TextStyle(
                                                        color: (currentAssignments[index].dateDue.difference(DateTime.now()).inSeconds/86400).ceil()<2?Colors.pink:Colors.green,
                                                      )),
                                                ),
                                              ],
                                            )
                                          ],
                                        ))),
                              ),
                              SizedBox(
                                height: 10.0,
                              )
                            ],
                          );
                        },
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'You currently do not \nhave an assignment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 24.0,
                            fontFamily: 'Arial',
                          ),
                        )
                      )
                    ),
                ],
              );
            }
            return const CircularProgressIndicator();
          }),
      // floatingActionButton: SpeedDial(
      //   animatedIcon: AnimatedIcons.add_event,
      //   animatedIconTheme: IconThemeData(size: 22),
      //   visible: true,
      //   backgroundColor: Color(0xFF152d32),
      //   curve: Curves.bounceIn,
      //   children: [
      //     SpeedDialChild(
      //       child: Icon(Icons.add),
      //       label: 'Add Assignment',
      //       backgroundColor: Color(0xFF152d32),
      //       foregroundColor: Colors.white,
      //       labelStyle: TextStyle(
      //           fontWeight: FontWeight.w500,
      //           color: Colors.white,
      //           fontSize: 16.0),
      //       labelBackgroundColor: Colors.green,
      //       onTap: () async {
      //         await Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => const CreateAssignmentPage()),
      //         );
      //         setState(() {
      //
      //         });
      //       },
      //     ),
      //     SpeedDialChild(
      //       child: Icon(Icons.search),
      //       label: 'Find answers',
      //       backgroundColor: Color(0xFF152d32),
      //       foregroundColor: Colors.white,
      //       labelStyle: TextStyle(
      //           fontWeight: FontWeight.w500,
      //           color: Colors.white,
      //           fontSize: 16.0),
      //       labelBackgroundColor: Colors.green,
      //       onTap: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => const SearchUserPage()),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()async{
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=> const CreateAssignmentPage()),
          );
          setState(() {

          });
          print("home");
        },
        label: const Text('Add'),
        icon: const Icon(Icons.add),
        backgroundColor: Color(0xFF152d32),
      ),
    );
  }
}
