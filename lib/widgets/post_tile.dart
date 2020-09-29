import 'package:WatchA/widgets/custom_image.dart';
import 'package:WatchA/widgets/post.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("The post was tapped"),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
