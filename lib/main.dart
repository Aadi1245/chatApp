// import 'package:chattest/dash_chat_2.dart';
// import 'package:chattest/pages/home.dart';
import 'package:chattest/Services/firebase_message.dart';
import 'package:chattest/Services/get_server_key.dart';
import 'package:chattest/app_theme.dart';
import 'package:chattest/pages/chat/chat_page.dart';
import 'package:chattest/pages/home_page.dart';
import 'package:chattest/pages/starter/onboarding.dart';
import 'package:chattest/pages/profile.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:chattest/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBo8dd5UxPfE2KpTUjHpDEt3QBefmubLs8",
          appId: "1:781777436407:android:b85effdf8936d3c0855df2",
          messagingSenderId: "781777436407",
          projectId: "chatup-9c474"));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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

  // String accessToken = await GetServerKey().getAccessToken();
  // print("Push Notification accesstoken ============>>>>>>>${accessToken}");
  await Supabase.initialize(
    url: 'https://ouiiibnxqioedvlwfbwl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91aWlpYm54cWlvZWR2bHdmYndsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcxMjgyNDksImV4cCI6MjA2MjcwNDI0OX0.aEDqtb7nzWayG0XnyE_I7etCe84c2fK5oKWKLb4FKSw',
  );
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('username');
  String? name = prefs.getString('name');

  // final client = stream_video.StreamVideo(
  //   'vxeyjhp4548f',
  //   user: stream_video.User.regular(
  //       userId: userId!,
  //       role: 'admin',
  //       name:
  //           name), //stream_video.User.regular(userId: 'Bastila_Shan', role: 'admin', name: 'John Doe'),
  //   userToken:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0Jhc3RpbGFfU2hhbiIsInVzZXJfaWQiOiJCYXN0aWxhX1NoYW4iLCJ2YWxpZGl0eV9pbl9zZWNvbmRzIjo2MDQ4MDAsImlhdCI6MTc0OTYzNTY2OCwiZXhwIjoxNzUwMjQwNDY4fQ.JcQRuUCs1934qz13a3O6v1RrNk1g2MN9bjS7eRnhM_k',
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Dash Chat Demo',
        theme: //AppTheme.lightTheme,
            ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        ),
        home: Onbpoarding());
  }
}
