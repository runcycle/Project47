import 'dart:convert';
import 'package:bingeable/models/show.dart';
import 'package:bingeable/widgets/shows_tile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bingeable/models/user.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final UserModel currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState(currentUser);
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  final currentUser;
  _UploadState(this.currentUser);
  TextEditingController captionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isUploading = false;
  String postId = Uuid().v4();
  final apiKey = DotEnv().env['API_KEY'];
  String query = "";
  List<Show> _shows = [];

  searchShows(query) async {
    final response = await http.get(
        "https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=$query");
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(result);
      Iterable list = result["results"];
      final showList = list.map((query) => Show.fromJson(query)).toList();
      setState(() {
        _shows = showList;
        isUploading = false;
      });
    } else {
      throw Exception("Failed to load request.");
    }
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      _shows = [];
    });
  }

  clearCaption() {
    captionController.clear();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 15,
          backgroundColor: Theme.of(context).primaryColor,
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back, color: Colors.black),
          //   onPressed: () => {},
          // ),
          title: Text(
            "Create a Post",
            style: TextStyle(fontFamily: 'CherryCreamSoda', fontSize: 25.0),
          ),
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 10),
            TextFormField(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "What do you recommend?",
                  filled: true,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 28.0,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: clearSearch,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter a search term";
                  }
                  return null;
                }),
            SizedBox(height: 10),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 40.0,
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  ),
                  onPressed: () {
                    searchShows(query);
                    isUploading = true;
                    FocusManager.instance.primaryFocus.unfocus();
                  },
                )),
            SizedBox(height: 8),
            Container(
              child: ShowsTile(shows: _shows, currentUser: currentUser),
            ),
          ],
        ));
  }
}
