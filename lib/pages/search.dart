import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:WatchA/models/user.dart';
import 'package:WatchA/pages/home.dart';
import 'package:WatchA/widgets/progress.dart';
import 'package:WatchA/pages/activity_feed.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  final _formKey = GlobalKey<FormState>();
  String query = "";

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where("displayName", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      searchResultsFuture = null;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            // SvgPicture.asset(
            //   "assets/images/search.svg",
            //   height: orientation == Orientation.portrait ? 250.0 : 150.0,
            // ),
            // Text(
            //   "Find Users",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontStyle: FontStyle.italic,
            //     fontWeight: FontWeight.w600,
            //     fontSize: 50.0,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        future: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach((doc) {
            UserModel user = UserModel.fromDocument(doc);
            UserResult searchResult = UserResult(user);
            searchResults.add(searchResult);
          });
          return ListView(
            children: searchResults,
          );
        });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      //backgroundColor: Theme.of(context).accentColor.withOpacity(0.5),
      appBar: AppBar(
        elevation: 15,
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          "Search for a User",
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
                hintText: "Search for a user...",
                filled: true,
                prefixIcon: Icon(
                  Icons.account_box,
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
              height: 30.0,
              alignment: Alignment.center,
              child: ElevatedButton(
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  handleSearch(query);
                  FocusManager.instance.primaryFocus.unfocus();
                },
              )),
          SizedBox(height: 10),
          Container(
            height: MediaQuery.of(context).size.height,
            child: 
            searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
          ),
        ],
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final UserModel user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.9),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl)),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
