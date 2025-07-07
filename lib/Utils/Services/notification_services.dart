import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:chattest/views/home_page.dart';
import 'package:chattest/views/starter/onboarding.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void getNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted Permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User provisional granted Permission");
    } else {
      Fluttertoast.showToast(
        msg: 'permission denied' +
            'Please allow notifications to receive updates',
        backgroundColor: Colors.red,
        fontSize: 12,
        toastLength: Toast.LENGTH_SHORT,
      );
      Future.delayed(Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

// get device token

  Future<String> getDeviceToken() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true);
    String? token = await messaging.getToken();
    print("device token --====${token}");
    return token!;
  }

  // initialize notification
  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidIitSetting =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitSetting = const DarwinInitializationSettings();

    var initializationSettings =
        InitializationSettings(android: androidIitSetting, iOS: iosInitSetting);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(context, message);
      },
    );
  }

  //firebase init

  void firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (kDebugMode) {
        print("notification title<><><><<++++${message.notification!.title}");
        print("notification body<><><><<++++${message.notification!.body}");
      }

      if (Platform.isIOS) {
        iosForgroundMessage();
      }

      if (Platform.isAndroid) {
        print(
            "notification on android message ${message.notification!.android!.channelId}");
        initLocalNotification(context, message);
        showNotification(message);
      }
    });
  }

  //Show notification
  Future<void> showNotification(RemoteMessage message) async {
    // await flutterLocalNotificationsPlugin
    // .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    // ?.createNotificationChannel(channel);
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ecomm-channel', // Must match the one in your manifest
      'E-Commerce Channel', // Name shown in Android settings
      description: 'This channel is used for chat & general notifications.',
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            sound: channel.sound);

    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

// show notification

    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title ?? "No Title",
        message.notification!.body ?? "No Body",
        notificationDetails,
        payload: "my_data",
      );
    });
  }

  Future iosForgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    //background state
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(context, message);
    });

    //terminated state band hai

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && message.data.isNotEmpty) {
        handleMessage(context, message);
      }
    });
  }

  //handler message

  Future<void> handleMessage(
      BuildContext context, RemoteMessage? message) async {
    if (message == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }
}
