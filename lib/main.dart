// import 'package:chattest/dash_chat_2.dart';
// import 'package:chattest/pages/home.dart';
import 'package:chattest/pages/chat_page.dart';
import 'package:chattest/pages/home_page.dart';
import 'package:chattest/pages/onboarding.dart';
import 'package:chattest/pages/profile.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:chattest/pages/onboarding.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBo8dd5UxPfE2KpTUjHpDEt3QBefmubLs8",
          appId: "1:781777436407:android:b85effdf8936d3c0855df2",
          messagingSenderId: "781777436407",
          projectId: "chatup-9c474"));

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dash Chat Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        ),
        home: Onbpoarding());
  }
}
