import 'dart:async';

import 'package:WatchA/models/user.dart';
import 'package:WatchA/pages/comments.dart';
import 'package:WatchA/pages/home.dart';
import 'package:WatchA/widgets/custom_image.dart';
import 'package:WatchA/widgets/progress.dart';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WatchA/pages/activity_feed.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String title;
  final String description;
  final String network;
  final String mediaUrl;
  final String mediaType;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.title,
    this.description,
    this.network,
    this.mediaUrl,
    this.mediaType,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc["postId"],
      ownerId: doc["ownerId"],
      username: doc["username"],
      title: doc["title"],
      description: doc["description"],
      network: doc["network"],
      mediaUrl: doc["mediaUrl"],
      mediaType: doc["mediaType"],
      likes: doc["likes"],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;

    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        title: this.title,
        description: this.description,
        network: this.network,
        mediaUrl: this.mediaUrl,
        mediaType: this.mediaType,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String title;
  final String description;
  final String network;
  final String mediaUrl;
  final String mediaType;
  bool showHeart = false;
  int likeCount;
  Map likes;
  bool isLiked;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.title,
    this.description,
    this.network,
    this.mediaUrl,
    this.mediaType,
    this.likes,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        UserModel user = UserModel.fromDocument(snapshot.data);
        return Container(
          color: Colors.grey[300],
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 15.0),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => showProfile(context, profileId: user.id),
              child: Text(
                user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //subtitle: Text(location),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
                    GestureDetector(
                      onTap: handleLikePost,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 28.0,
                        color: Colors.pink,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 2.0)),
                    Text(
                      "$likeCount",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 10.0)),
                    GestureDetector(
                      onTap: () => showComments(
                        context,
                        postId: postId,
                        ownerId: ownerId,
                        mediaUrl: mediaUrl,
                      ),
                      child: Icon(
                        Icons.chat,
                        size: 28.0,
                        color: Colors.blue[900],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 20.0)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        });
  }

  deletePost() async {
    // delte post itself
    postsRef.doc(ownerId).collection("userPosts").doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete uploaded image for the post
    //storageRef.child("post_$postId.jpg").delete();
    // then delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .where("postId", isEqualTo: postId)
        .get();
    activityFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot =
        await commentsRef.doc(postId).collection("comments").get();
    commentsSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection("userPosts")
          .doc(postId)
          .update({"likes.$currentUserId": false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection("userPosts")
          .doc(postId)
          .update({"likes.$currentUserId": true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection("feedItems").doc(postId).set({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostFooter() {
    bool isPostOwner = currentUserId == ownerId;
    return Container(
      color: Colors.grey[300],
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 15.0),
        title: Container(
          child: Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  title != null
                  ? Flexible(
                        child: Text("$title",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold)),
                  )
                  : Text(""),
                  Text(" ($mediaType)", style: TextStyle(fontSize: 15)),
                ],
              ),
              Row(
                children: [
                  network != null
                    ? Text("Watched on: $network",
                        style: TextStyle(
                          fontSize: 14.0,
                        ))
                    : Text(""),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
        trailing: 
        Padding(
          padding: EdgeInsets.only(left: 50),
          child: isPostOwner
          ? IconButton(
              onPressed: () => handleDeletePost(context),
              icon: Icon(Icons.delete_outline),
            )
          : Text(""),
        ),
      ),
    );
  }

  buildPostImage() {
    return Column(
      children: [
        GestureDetector(
          onDoubleTap: handleLikePost,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: cachedNetworkImage(mediaUrl),
                ),
              ),
              showHeart
                  ? Animator(
                      duration: Duration(milliseconds: 300),
                      tween: Tween(begin: 0.8, end: 1.4),
                      curve: Curves.elasticOut,
                      cycles: 0,
                      builder: (anim) => Transform.scale(
                        scale: anim.value,
                        child:
                            Icon(Icons.favorite, size: 80.0, color: Colors.red),
                      ),
                    )
                  : Text(""),
            ],
          ),
        ),
      ],
    );
  }

  buildComment() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 15.0),
                child: Text(
                  "Comment from $username: ",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(description),
              ),
            ],
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Card(
        elevation: 5.0,
        margin: EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildPostHeader(),
            buildComment(),
            buildPostImage(),
            buildPostFooter(),
          ],
        ),
      ),
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
