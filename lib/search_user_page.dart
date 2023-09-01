import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kiptrak/io/network.dart';
import 'models/Assignment.dart';
import 'constants.dart';
import 'custom_form.dart';

class SearchUserPage extends StatefulWidget {
  SearchUserPage({Key? key}) : super(key: key);

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  TextEditingController _gptCtl = TextEditingController();
  TextEditingController _searchCtl = TextEditingController();

  var searchCount;
  var searchState = "";
  List users = [];
  List following = [];
  @override
  void initState() {
    super.initState();
  }

  _SearchUserPageState() {
    searchCount = 0;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF152d32),
          title: const Text('Search for User'),
        ),
        body: Column(
          children: [
            TextFormField(
              controller: _searchCtl,
              enabled: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'No user entered!';
                }
                return null;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: TextButton(
                    onPressed: () async {
                      try {
                        searchState = 'Searching';
                        setState(() {

                        });
                        following = jsonDecode(
                            (await KiptrakNetwork.getFollowing())
                                .body)['message'].split('|');
                        print(following);
                        var response = await KiptrakNetwork.getUsers(
                            searchTerm: _searchCtl.text);
                        if(response.statusCode == 200){
                          users = jsonDecode(response.body);
                        }
                        setState(() {
                          searchState = users.isEmpty?"No user found":"";
                        });
                      } on Exception catch (e) {}
                    },
                    child: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    )),
                hintText: 'Search',
              ),
            ),
            Text(searchState),
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${users[index]['username'][0].toUpperCase()}${users[index]['username'].substring(1).toLowerCase()}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Joined: ${users[index]['created']}'),
                            TextButton(
                                onPressed: ()async {
                                  var response = await KiptrakNetwork.followUser(id: users[index]['username'], action:following.contains(users[index]['username'].toString())?'unfollow':'follow');
                                  print(response?.statusCode);
                                  if(response?.statusCode == 200){
                                    following.contains(users[index]['username'].toString())?following.remove(users[index]['username'].toString()) : following.add(users[index]['username'].toString());
                                    setState(() {

                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(jsonDecode(response!.body)['message']),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                  else if(response!= null){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(jsonDecode(response.body)['message']),
                                        backgroundColor: Colors.deepOrangeAccent,
                                      ),
                                    );
                                  }
                                },
                                child: Text(following.contains(users[index]['username'].toString())?'Unfollow':'Follow')
                            )
                          ],
                        ),
                        const Divider(

                        )
                      ]
                  );
                })
          ],
        ));
  }
}
