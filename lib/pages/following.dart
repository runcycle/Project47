import 'package:bingeable/models/user.dart';
import 'package:bingeable/pages/home.dart';
//import 'package:bingeable/pages/search.dart';
import 'package:bingeable/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bingeable/pages/activity_feed.dart';

class Following extends StatefulWidget {
  final String profileId;

  Following({this.profileId});

  @override
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following>
    with AutomaticKeepAliveClientMixin<Following> {
  bool get wantKeepAlive => true;
  Future<QuerySnapshot> followingFuture;
  final String currentUserId = currentUser?.id;

  @override
  void initState() {
    super.initState();
    getFollowing();
  }

  //getFollowing needs a different query method
  getFollowing() async {
    List<String> followingIds = [];
    QuerySnapshot snapshot =
        await followingRef.doc(currentUserId).collection("userFollowing").get();
    followingIds = snapshot.docs.map((doc) => doc.id).toList();
    //print(followingIds);
    setState(() {
      followingIds.forEach((doc) {
        Future<QuerySnapshot> users =
            usersRef.where("id", isLessThanOrEqualTo: doc).get();
        followingFuture = users;
      });
    });
  }

  buildFollowingList() {
    return FutureBuilder(
        future: followingFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> followingResults = [];
          snapshot.data.docs.forEach((doc) {
            UserModel user = UserModel.fromDocument(doc);
            UserResult followingResult = UserResult(user);
            followingResults.add(followingResult);
          });
          return ListView(
            children: followingResults,
          );
        });
  }

  buildNoContent() {
    //final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Center(child: Text("You are not following any users.", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      //backgroundColor: Theme.of(context).accentColor.withOpacity(0.5),
      appBar: AppBar(
        elevation: 15,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Following",
          style: TextStyle(fontFamily: 'CherryCreamSoda', fontSize: 25.0),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 10),
          Container(
            height: MediaQuery.of(context).size.height,
            child: followingFuture == null
                ? buildNoContent()
                : buildFollowingList(),
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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 0.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  color: Colors.grey[300],
                  child: GestureDetector(
                    onTap: () => showProfile(context, profileId: user.id),
                    child: ListTile(
                      leading: CircleAvatar(
                          radius: 25.0,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl)),
                      title: Text(
                        user.displayName,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        user.username,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              height: 2.0,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
