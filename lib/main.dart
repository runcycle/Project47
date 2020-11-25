import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:WatchA/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatchA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFab47bc),
        accentColor: Color(0xFF42a5f5),
      ),
      home: Home(),
    );
  }
}
