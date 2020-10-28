import 'dart:async';
import 'package:WatchA/widgets/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:WatchA/widgets/header.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EmailAccount extends StatefulWidget {
  @override
  _EmailAccountState createState() => _EmailAccountState();
}

class _EmailAccountState extends State<EmailAccount> {
  // final _auth = FirebaseAuth.instance;
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  // final _formKey = GlobalKey<FormState>();
  String email;
  String username;
  String password;
  String confirmPassword;
  bool _showProgress = false;

  showCircularProgress() {
    if (_showProgress == true) {
      return circularProgress();
    }
  }

  passwordCompare() {
    if (password == confirmPassword) {
      return submit();
    } else {
      return null;
    }
  }

  submit() {}
  // submit() {
  //   final form = _formKey.currentState;
  //   if (form.validate()) {
  //     form.save();
  //     SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
  //     _scaffoldKey.currentState.showSnackBar(snackbar);
  //     Timer(Duration(seconds: 2), () {
  //       Navigator.pop(context, username);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context,
          titleText: "Create Your Account", removeBackButton: false),
      body: ModalProgressHUD(
        inAsyncCall: _showProgress,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("Please Enter An Email Address",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 5.0,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                ),
                Text("Please Enter A Username",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    username = value;
                  },
                ),
                Text("Please Enter A Password",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 5.0,
                ),
                TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                ),
                Text("Please Confirm Your Password",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 5.0,
                ),
                TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
              },
            ),
          ],
        )),
      ),
    );
    // return Scaffold(
    //     key: _scaffoldKey,
    //     appBar: header(context,
    //         titleText: "Create Your Account", removeBackButton: true),
    //     body: ListView(
    //       children: <Widget>[
    //         Container(
    //           child: Column(
    //             children: <Widget>[
    //               Padding(
    //                 padding: EdgeInsets.only(top: 25.0),
    //                 child: Center(
    //                   child: Text(
    //                     "Create a Username",
    //                     style: TextStyle(
    //                       fontSize: 25.0,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               Padding(
    //                 padding: EdgeInsets.all(16.0),
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   crossAxisAlignment: CrossAxisAlignment.stretch,
    //                   children: <Widget>[
    //                     Form(
    //                       key: _formKey,
    //                       autovalidate: true,
    //                       child: Column(
    //                         children: <Widget>[
    //                           TextFormField(
    //                             validator: (val) {
    //                               if (val.trim().length < 3 || val.isEmpty) {
    //                                 return "Username too short";
    //                               } else if (val.trim().length > 15) {
    //                                 return "Username too long";
    //                               } else {
    //                                 return null;
    //                               }
    //                             },
    //                             onSaved: (val) => username = val,
    //                             decoration: InputDecoration(
    //                               border: OutlineInputBorder(),
    //                               labelText: "Username",
    //                               labelStyle: TextStyle(fontSize: 15.0),
    //                               hintText: "Must be at least 3 characters",
    //                               ),
    //                             ),
    //                             Padding(
    //                               padding: EdgeInsets.only(top: 25.0),
    //                               child: Center(
    //                                 child: Text(
    //                                   "Create a Username",
    //                                   style: TextStyle(
    //                                     fontSize: 25.0,

    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                             TextFormField(
    //                             validator: (val) {
    //                               if (val.trim().length < 3 || val.isEmpty) {
    //                                 return "Password too short";
    //                               } else if (val.trim().length > 15) {
    //                                 return "Password too long";
    //                               } else {
    //                                 return null;
    //                               }
    //                             },
    //                             onSaved: (val) => password = val,
    //                             decoration: InputDecoration(
    //                               border: OutlineInputBorder(),
    //                               labelText: "Password",
    //                               labelStyle: TextStyle(fontSize: 15.0),
    //                               hintText: "Must be at least 3 characters",
    //                               ),
    //                             ),
    //                           ]
    //                         )
    //                       ),
    //                     GestureDetector(
    //                       onTap: submit,
    //                       child: Container(
    //                         height: 50.0,
    //                         width: 100.0,
    //                         decoration: BoxDecoration(
    //                           color: Colors.blue,
    //                           borderRadius: BorderRadius.circular(7.0),
    //                         ),
    //                         child: Center(
    //                           child: Text(
    //                             "Submit",
    //                             style: TextStyle(
    //                               color: Colors.white,
    //                               fontSize: 15.0,
    //                               fontWeight: FontWeight.bold,
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ]
    //                 ),
    //               ),

    //             ],
    //           ),
    //         )
    //       ],
    //     ));
  }
}