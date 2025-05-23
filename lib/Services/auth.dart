import 'package:chattest/Services/database.dart';
import 'package:chattest/Services/notification_services.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:chattest/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authmethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

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
    await SharedPreferenceHelper()
        .saveAccessToken(await notificationServices.getDeviceToken());

    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        "Name": userDetails!.displayName,
        "Email": userDetails!.email,
        "Image": userDetails.photoURL,
        "Id": userDetails.uid,
        "username": userName.toUpperCase(),
        "SearchKey": firstletter,
        "accessToken": await notificationServices.getDeviceToken()
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
