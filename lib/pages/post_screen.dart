import 'package:bingeable/pages/home.dart';
import 'package:bingeable/widgets/header.dart';
import 'package:bingeable/widgets/post.dart';
import 'package:bingeable/widgets/progress.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .doc(userId)
          .collection("userPosts")
          .doc(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],  
            ),
          ),
        );
      },
    );
  }
}
