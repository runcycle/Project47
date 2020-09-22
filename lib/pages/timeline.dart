import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WatchA/widgets/header.dart';
import 'package:WatchA/widgets/progress.dart';

final usersRef = Firestore.instance.collection("users");

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    //createUser();
    //updateUser();
    deleteUser();
    super.initState();
  }

  createUser() async {
    await usersRef.document("asdsdasd").setData({
      "username": "Jeff",
      "postsCount": 0,
      "isAdmin": false,
    });
  }

  updateUser() async {
    final doc = await usersRef.document("7EQel685vqBWo66miyAc").get();
    if (doc.exists) {
      doc.reference
          .updateData({"username": "Fred", "postsCount": 5, "isAdmin": false});
    }
  }

  deleteUser() async {
    final DocumentSnapshot doc = await usersRef.document("asdsdasd").get();
    if (doc.exists) {
      doc.reference.delete();
    }
  }

  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final List<Text> children = snapshot.data.documents
              .map((doc) => Text(doc["username"]))
              .toList();
          return Container(
              child: ListView(
            children: children,
          ));
        },
      ),
    );
  }
}
