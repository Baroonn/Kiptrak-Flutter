import 'dart:async';
import 'dart:developer' as logDev;

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/Assignment.dart';
import '../models/User.dart';

class KiptrakDatabase{
  static var database = createDatabase();
  static Future<Database> createDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'kiptrak'),
      version: 1,
      onCreate: (db, version) {
        db.execute(
          '''CREATE TABLE global_assignments(id INTEGER UNIQUE,
          title TEXT,
          description TEXT,
          course TEXT,
          lecturer TEXT,
          datedue INTEGER,
          notes TEXT,
          images TEXT,
          createdby INTEGER,
          createdate TEXT,
          username TEXT,
          status TEXT)
           ''',
        );

        db.execute(
          '''CREATE TABLE local_assignments(id INTEGER PRIMARY KEY,
          title TEXT,
          desc TEXT,
          course TEXT,
          lecturer TEXT,
          dateDue INTEGER,
          notes TEXT,
          status TEXT,
          imagePath TEXT)
           ''',
        );

        db.execute(
          '''CREATE TABLE user_details(id INTEGER PRIMARY KEY,
          userName TEXT,
          password TEXT,
          email TEXT,
          phoneNumber TEXT,
          token TEXT)
           ''',
        );
      }
    );

    logDev.log("user_details created");
    return database;
  }

  static Future<User?> getUser() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('user_details');
    if(maps.isEmpty){
      return User(
        userName: "",
        password: "",
        email:""
      );
    }
    return User(
      userName: maps[0]['userName'],
      password: maps[0]['password'],
      email: maps[0]['email'],
      phoneNumber: maps[0]['phoneNumber'],
      token: maps[0]['token']
    );
  }

  static Future<bool> userLoggedIn() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_details');

    return maps.isNotEmpty;
  }

  static Future<void> updateToken({required String token}) async {
    final db = await database;
    await db.update("user_details", {
      'token': token
    });
  }

  static Future<void> insertUserDetails ({required User user}) async {
    final db = await database;
    logDev.log("In InsertUserDetails");
    await db.rawDelete('DELETE FROM user_details');
    await db.insert(
      'user_details',
      {
        'userName':user.userName,
        'password':user.password,
        'email':user.email,
        'phoneNumber': user.phoneNumber,
        'token': user.token
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    logDev.log((await db.query('user_details')).toString());
    logDev.log("Left InsertUserDetails");
  }

  static Future<void> insertGlobalAssignment(AssignmentOnlineReadDto assignment) async {
    final db = await createDatabase();

    var maps = await db.query('global_assignments', where: 'id = ?', whereArgs: [assignment.id]);
    print("In global assignment");
    print(maps.length);
    if (maps.isNotEmpty){
      return;
    }
    print("Out global assignment");
    await db.insert(
      'global_assignments',
      assignment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertLocalAssignment(AssignmentCreateDto assignment) async {
    final db = await database;
    logDev.log("Assignments: ${assignment.toMap()}");
    await db.insert(
      'local_assignments',
      assignment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateLocalAssignmentStatus(int id, String status) async {
    final db = await database;

    int _ = await db.rawUpdate(
        'UPDATE local_assignments SET status = ? WHERE id = ?',
        [status, id]
    );
  }

  static Future<void> updateGlobalAssignmentStatus(int id, String status) async {
    final db = await database;

    print(id);print(status);
    int count = await db.rawUpdate(
        'UPDATE global_assignments SET status = ? WHERE id = ?',
        [status, id]
    );
    print(count);
  }

  static Future<List<Assignment>> assignments() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('global_assignments');

    return List.generate(maps.length, (i){
      return Assignment(
        title: maps[i]['title'],
        desc: maps[i]['desc'],
        course: maps[i]['course'],
        lecturer: maps[i]['lecturer'],
        dateDue: maps[i]['dateDue'],
        notes: maps[i]['notes'],
        createdBy: maps[i]['createdBy'],
        createdAt: maps[i]['createdAt'],
        status: maps[i]['status'],
      );
    });
  }
  // static List<AssignmentCreateDto> getLocalAssignmentsSync(){
  //   return getLocalAssignments().then(
  //       (result)=> result;
  //   )
  // }
  static Future<List<AssignmentReadDto>> getLocalAssignments() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
        'local_assignments',
      where: 'dateDue > ?',
      whereArgs: [DateTime.now().add(Duration(days: -2)).millisecondsSinceEpoch]
    );
    //logDev.log(maps[0]['dateDue']);
    return List.generate(maps.length, (i){
      return AssignmentReadDto(
          id: maps[i]['id'],
          title: maps[i]['title'],
          desc: maps[i]['desc'],
          course: maps[i]['course'],
          lecturer: maps[i]['lecturer'],
          dateDue: DateTime.fromMillisecondsSinceEpoch(maps[i]['dateDue']),
          notes: maps[i]['notes'],
          status: AssignmentStatus
              .values
              .firstWhere(
                  (a)=> a.toString() == 'AssignmentStatus.' + maps[i]['status']
          ),
          imagePath: maps[i]['imagePath']
      );
    });
  }

  static Future<List<AssignmentGlobalReadDto>> getGlobalAssignments() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
        'global_assignments',
        where: 'datedue > ? AND status IN (\'pending\', \'completed\')',
        whereArgs: [DateTime.now().add(Duration(days: -2)).millisecondsSinceEpoch]
    );
    logDev.log(maps.length.toString());
    //logDev.log(maps[0]['dateDue']);
    return List.generate(maps.length, (i){
      return AssignmentGlobalReadDto.fromJson(maps[i]);
    });
  }

  static Future<void> deleteLocalAssignments(int id) async{
    final db = await database;
    db.rawDelete(
      'DELETE FROM local_assignments WHERE id = ?',
      [id]
    );
  }
}
// Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
