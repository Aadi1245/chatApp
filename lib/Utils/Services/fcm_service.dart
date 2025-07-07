import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  static void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      print(
          "message show <><><><><><><><><><><><===>${message.notification!.title}");
      print(
          "message show body <><><><><><><><><><><><===>${message.notification!.body}");
    });
  }
}
