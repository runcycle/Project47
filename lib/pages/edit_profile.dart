import "dart:io";

import 'package:WatchA/models/user.dart';
import 'package:WatchA/pages/home.dart';
import 'package:WatchA/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _EditProfileState extends State<EditProfile> {
  final _auth = FirebaseAuth.instance;
  firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref("tempIcon.jpg");
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  UserModel user;
  bool _displayNameValid = true;
  bool _bioValid = true;
  File imageFile;
  AppState state;

  @override
  void initState() {
    super.initState();
    getUser();
    state = AppState.free;
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = UserModel.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Display Name",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        ),
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ? null : "Bio too long",
          ),
        ),
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });
      SnackBar snackbar = SnackBar(content: Text("Profile updated!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  logout() async {
    if (googleLogin = true) {
      await googleSignIn.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false);
    } else if (emailLogin = true) {
      await _auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false);
    }
  }

  Future<void> _askToLogout() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to log out?',
              style: TextStyle(
                fontSize: 15.0,
              )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('This is a demo alert dialog.'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                logout();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future _pickImage() async {
    final selected = await ImagePicker().getImage(source: ImageSource.gallery);
    imageFile = selected != null ? File(selected.path) : null;
    if (imageFile != null) {
      setState(() {
        //_imageFile = selected;
        state = AppState.picked;
      });
      _cropImage();
    } else {
      print("No image selected.");
    }
  }

  // void _clearImage() {
  //   setState(() {
  //     imageFile = null;
  //     state = AppState.free;
  //   });
  // }

  Future<void> _cropImage() async {
    final cropped = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Your Image',
            toolbarColor: Colors.purple[400],
            dimmedLayerColor: Colors.purple[800],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            activeControlsWidgetColor: Colors.blue[400],
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Your Image',
        ));
    setState(() {
      imageFile = cropped;
      state = AppState.cropped;
    });
    uploadImage();
  }

  uploadImage() {}

  _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.add);
    else
      return Container();
  }

  avatarButton() {
    return Column(
      children: [
        FlatButton(
          color: Colors.grey[400],
          textColor: Colors.black,
          minWidth: 10.0,
          child: _buildButtonIcon(),
          onPressed: () {
            _pickImage();
          },
        ),
        Text(
          "Edit Avatar",
          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 15,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "CherryCreamSoda",
            fontSize: 25.0,
          ),
        ),
      ),
      body: isLoading
          ? circularProgress()
          : Column(
              children: <Widget>[
                Stack(
                  children: [
                    emailLogin ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: avatarButton(),
                        ),
                      ],
                    ) : Container(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 35.0),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Column(
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildBioField(),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                RaisedButton(
                  onPressed: updateProfileData,
                  color: Colors.blue[400],
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RaisedButton(
                        onPressed: _askToLogout,
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
