// import 'package:chattest/dash_chat_2.dart';
// import 'package:chattest/pages/home.dart';
import 'package:chattest/pages/chat/chat_page.dart';
import 'package:chattest/pages/home_page.dart';
import 'package:chattest/pages/starter/onboarding.dart';
import 'package:chattest/pages/profile.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:chattest/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  await Supabase.initialize(
    url: 'https://ouiiibnxqioedvlwfbwl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91aWlpYm54cWlvZWR2bHdmYndsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcxMjgyNDksImV4cCI6MjA2MjcwNDI0OX0.aEDqtb7nzWayG0XnyE_I7etCe84c2fK5oKWKLb4FKSw',
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
