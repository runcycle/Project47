import 'package:WatchA/models/user.dart';
import 'package:WatchA/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WatchA/widgets/header.dart';
import 'package:WatchA/widgets/progress.dart';
import 'package:WatchA/pages/home.dart';

final usersRef = Firestore.instance.collection("users");

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;

  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  // createUser() async {
  //   await usersRef.document("asdsdasd").setData({
  //     "username": "Jeff",
  //     "postsCount": 0,
  //     "isAdmin": false,
  //   });
  // }

  // updateUser() async {
  //   final doc = await usersRef.document("7EQel685vqBWo66miyAc").get();
  //   if (doc.exists) {
  //     doc.reference
  //         .updateData({"username": "Fred", "postsCount": 5, "isAdmin": false});
  //   }
  // }

  // deleteUser() async {
  //   final DocumentSnapshot doc = await usersRef.document("asdsdasd").get();
  //   if (doc.exists) {
  //     doc.reference.delete();
  //   }
  // }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Text("No posts");
    } else {
      return ListView(children: posts);
    }
  }

  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
