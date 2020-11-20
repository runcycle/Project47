import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
  });

  //Usermodel has to be upgraded to use new DocumentSnapshot code
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      id: doc.data()["id"],
      email: doc.data()["email"],
      username: doc.data()["username"],
      photoUrl: doc.data()["photoUrl"],
      displayName: doc.data()["displayName"],
      bio: doc.data()["bio"],
    );
  }
}
