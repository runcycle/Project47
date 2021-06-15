import "dart:io";

import 'package:bingeable/models/user.dart';
import 'package:bingeable/pages/home.dart';
import 'package:bingeable/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _auth = FirebaseAuth.instance;
  firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  UserModel user;
  bool _displayNameValid = true;
  bool _bioValid = true;
  File imageFile;
  String postId = Uuid().v4();
  String avatar;

  @override
  void initState() {
    super.initState();
    getUser();
    //state = AppState.free;
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
          keyboardType: TextInputType.multiline,
          maxLines: null,
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
      bioController.text.trim().length > 200
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Profile updated!")));
    }
  }

  logout() async {
    if (googleLogin = true) {
      await googleSignIn.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false);
    } else if (emailLogin = true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
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
      _cropImage();
    }
  }

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
      //state = AppState.cropped;
    });
    _compressImage();
  }

  _compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image newImage = Im.decodeImage(imageFile.readAsBytesSync());
    final compressedImage = File("$path/img_$postId.jpg")
      ..writeAsBytesSync(Im.encodeJpg(newImage, quality: 85));
    setState(() {
      imageFile = compressedImage;
    });
    _uploadImage(imageFile);
  }

  _uploadImage(imageFile) async {
    firebase_storage.UploadTask uploadTask =
        storageRef.child("avatars/post_$postId.jpg").putFile(imageFile);
    final avatarUrl = await (await uploadTask).ref.getDownloadURL();
    setState(() {
      avatar = avatarUrl.toString();
      //state == AppState.free;
    });
    //print(avatar);
    usersRef.doc(widget.currentUserId).update({
      "photoUrl": avatar,
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Profile updated!")));
    // SnackBar snackbar = SnackBar(content: Text("Profile updated!"));
    // _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  avatarButton() {
    return Column(
      children: [
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[400]),
            elevation: MaterialStateProperty.all<double>(4.0),
            shadowColor: MaterialStateProperty.all<Color>(Colors.black),
          ),
          // color: Colors.grey[400],
          // textColor: Colors.black,
          // minWidth: 5.0,
          child: Icon(Icons.person_add, color: Colors.black),
          onPressed: () {
            _pickImage();
          },
        ),
      ],
    );
  }

  logoutButton() {
    return Column(
      children: [
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[400]),
            elevation: MaterialStateProperty.all<double>(4.0),
            shadowColor: MaterialStateProperty.all<Color>(Colors.black),
          ),
          // textColor: Colors.black,
          // minWidth: 5.0,
          child: Icon(Icons.logout, color: Colors.black),
          onPressed: () {
            _askToLogout();
          },
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
          : ListView(
              children: <Widget>[
                Stack(
                  children: [
                    emailLogin
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: avatarButton(),
                              ),
                            ],
                          )
                        : Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: logoutButton(),
                        ),
                      ],
                    ),
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
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.only(left: 120, right: 120),
                  child: ElevatedButton(
                    onPressed: updateProfileData,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purple[400],
                      elevation: 2.0,
                      //side: BorderSide(color: Colors.grey[600], width: 1.0),
                      //visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
