import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:WatchA/pages/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:admob_flutter/admob_flutter.dart';

Future main() async {
  await DotEnv().load('.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Admob.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bingeable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFab47bc),
        accentColor: Color(0xFF42a5f5),
      ),
      home: Home(),
      // initialRoute: "/",
      // routes: {
      //   "/": (context) => Home(),
      //   "/timeline": (context) => Timeline(),
      // }
    );
  }
}
