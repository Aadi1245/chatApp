import 'package:chattest/Services/call_service.dart';
import 'package:chattest/Services/database.dart';
import 'package:chattest/Services/notification_services.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:chattest/main.dart';
import 'package:chattest/pages/chat/ApiCalling/all_api_calling.dart';
import 'package:chattest/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Authmethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Future<void> initializeStreamVideo(
  //     String userName, String token, String userDisplayName) async {
  //   // Step 1: Define your user
  //   final user = UserInfo(
  //     id: userName,
  //     role: 'admin',
  //     name: userDetails.displayName,
  //     image: userDetails.photoURL ?? '', // Optional
  //   );

  //   // Step 2: Initialize the StreamVideo SDK (only once)
  //   await StreamVideo.init(
  //     apiKey: 'vxeyjhp4548f',
  //     options: const StreamVideoOptions(),
  //   );

  //   // Step 3: Connect the user
  //   await StreamVideo.instance.connectUser(
  //     user: user,
  //     token: token, // Make sure this is a valid JWT token from your backend
  //   );

  //   // Step 4: Initialize your CallService (handles incoming call listeners, etc.)
  //   CallService()
  //       .init(navigatorKey); // Make sure navigatorKey is defined globally
  // }

  getCurrenUser() async {
    return await auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Return user data as a Map
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        print("---------------------- User not found ----------------------");
        return null;
      }
    } catch (e) {
      print("Error fetching user: ------------->>>> $e");
      return null;
    }
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    // String randomstr = randomAlphaNumeric(5);

    String userName = userDetails!.email!.replaceAll("@gmail.com", "");
    String firstletter = userName.substring(0, 1).toUpperCase();

    NotificationServices notificationServices = NotificationServices();
    await SharedPreferenceHelper()
        .saveUserDisplayName(userDetails.displayName!);
    await SharedPreferenceHelper().saveUserEmail(userDetails.email!);
    await SharedPreferenceHelper().saveUserId(userDetails.uid);
    await SharedPreferenceHelper().saveUserImage(userDetails.photoURL!);
    await SharedPreferenceHelper().saveUserName(userName);
    // await SharedPreferenceHelper()
    //     .saveAccessToken(await notificationServices.getDeviceToken());
    // String Token = await AllApiCalling.createUserAndGetAccessToken(
    //     userName, userDetails.displayName!);
    // await SharedPreferenceHelper().saveStreamToken(Token);

    // final user = stream_video.User.regular(
    //     userId: userName, role: 'admin', name: userDetails.displayName!);

//     final client = stream_video.StreamVideo('vxeyjhp4548f',
//         user:
//             user, //stream_video.User.regular(userId: 'Bastila_Shan', role: 'admin', name: 'John Doe'),
//         userToken: Token);

// // Initialize StreamVideo once (usually in main or startup file)
//     await StreamVideo.init(
//       apiKey: 'vxeyjhp4548f',
//       options: const StreamVideoOptions(),
//     );

// // Then connect the user

//     await StreamVideo.instance.connectUser(user, Token);
//     CallService().init(navigatorKey);
    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        "Name": userDetails!.displayName,
        "Email": userDetails!.email,
        "Image": userDetails.photoURL,
        "Id": userDetails.uid,
        "username": userName.toUpperCase(),
        "SearchKey": firstletter,
        // "accessToken": await notificationServices.getDeviceToken()
      };

      await DataBasemethods().addUser(userInfoMap, userDetails.uid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "User registered successfully",
            style: TextStyle(
                fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          )));

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  Future signOut() async {
    FirebaseAuth.instance.signOut();
    // SharedPreferenceHelper sharedPreferenceHelper =await SharedPreferenceHelper();
    SharedPreferences sh = await SharedPreferences.getInstance();

    sh.clear();
  }

  Future delete() async {
    User? user = await FirebaseAuth.instance.currentUser;
    user!.delete();
  }
}
