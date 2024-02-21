import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiptrak/io/database.dart';
import 'package:kiptrak/welcome_page.dart';
import './home_page_test.dart';
import 'models/User.dart';

void main() async{
  await KiptrakDatabase.createDatabase();

  runApp(const KipTrak());
}

class KipTrak  extends StatelessWidget {
  const KipTrak ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Arial',
          textTheme: GoogleFonts.notoSansTextTheme(textTheme),
        ),
        home:FutureBuilder(
          future: KiptrakDatabase.getUser(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              User? user = snapshot.data as User;
              return user.username != ""? MyHomeApp(user: user,):WelcomePage();
            }

            return CircularProgressIndicator();
          }
        )
    );
  }
}

