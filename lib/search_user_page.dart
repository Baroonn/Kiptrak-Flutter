import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/Assignment.dart';
import 'constants.dart';
import 'custom_form.dart';

class SearchUserPage extends StatefulWidget {

  SearchUserPage({Key? key, required this.searchTerm}) : super(key: key);

  String searchTerm;

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  TextEditingController _gptCtl = TextEditingController();
  TextEditingController _searchCtl = TextEditingController();

  var searchCount;
  @override
  void initState(){
    _searchCtl.text = widget.searchTerm;
    super.initState();
  }

  _SearchUserPageState(){
    searchCount = 0;
  }

  Future<String> generateResponse(String prompt) async {
    final apiKey = apiSecretKey;
    var url = Uri.https("api.openai.com", "/v1/chat/completions");

    final response = await http.post(url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      body: jsonEncode({
        'model':'gpt-3.5-turbo',
        'messages':[
          {
            'role':'user',
            'content':prompt
          }
        ]
      })
    );

    Map<String, dynamic> newresponse = jsonDecode(response.body);
    return newresponse['choices'][0]['message']['content'].trim();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: Text(
              'Find Answers'
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
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
                    onPressed:() async {
                      if(searchCount>2){
                        Navigator.pop(context);
                      }
                      _gptCtl.text = "Finding Answers...";
                      var response = generateResponse(_searchCtl.text);
                      _gptCtl.text = await response;
                      searchCount++;
                      setState((){
                      });
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.grey,
                    )
                  ),
                  hintText: 'Search',
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _gptCtl,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              )
            ],
          )
        )
    );
  }
}
