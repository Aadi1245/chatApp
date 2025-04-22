// import 'package:chattest/dash_chat_2.dart';
// import 'package:chattest/pages/home.dart';
import 'package:chattest/pages/chat_page.dart';
import 'package:chattest/pages/home_page.dart';
import 'package:chattest/pages/onboarding.dart';
// import 'package:chattest/pages/onboarding.dart';
import 'package:flutter/material.dart';

void main() {
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
      home: Onbpoarding(),
    );
  }
}
