import 'package:chattest/Services/auth.dart';
import 'package:chattest/Services/database.dart';
import 'package:chattest/pages/starter/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Services/shared_pref.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? myUserName, myName, myEmail, myPicture = "";

  getTheSharedpreferenceData() async {
    myUserName = await SharedPreferenceHelper().getUserName();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  @override
  void initState() {
    onLoad();
    super.initState();
  }

  onLoad() async {
    await getTheSharedpreferenceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 40, left: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        color: Colors.white,
                        Icons.arrow_back,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                  ),
                  Text(
                    "Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 25, right: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: myPicture == null
                    ? Center(
                        child: CircularProgressIndicator(
                        color: Colors.blueGrey,
                      ))
                    : Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: myPicture != null
                                  ? Image.network(
                                      myPicture!,
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : CircularProgressIndicator(),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Material(
                            color: Colors.white,
                            elevation: 3,
                            borderRadius: BorderRadius.circular(5),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(
                                    color: Colors.blue.shade100,
                                    Icons.person,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(left: 10),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Name",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          top: 5,
                                          bottom: 5,
                                          right: 5),
                                      // height:
                                      //     50, //MediaQuery.of(context).size.height,
                                      // width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        "${myName}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Material(
                            color: Colors.white,
                            elevation: 3,
                            borderRadius: BorderRadius.circular(5),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(
                                    color: Colors.blue.shade100,
                                    Icons.email,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(left: 10),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "email",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            top: 5,
                                            bottom: 5,
                                            right: 5),
                                        // height:
                                        //     50, //MediaQuery.of(context).size.height,
                                        // width: MediaQuery.of(context).size.width,
                                        child: Text(
                                          "${myEmail}",
                                          // textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            onTap: () async {
                              await Authmethods().signOut();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Onbpoarding()));
                            },
                            child: Material(
                              color: Colors.white,
                              elevation: 3,
                              borderRadius: BorderRadius.circular(5),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      color: Colors.blue.shade100,
                                      Icons.logout,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        left: 10, top: 5, bottom: 5, right: 5),
                                    // height:
                                    //     50, //MediaQuery.of(context).size.height,
                                    // width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      "LogOut",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      color: Colors.black,
                                      Icons.arrow_forward_ios,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            onTap: () async {
                              await Authmethods().delete();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Onbpoarding()));
                            },
                            child: Material(
                              color: Colors.white,
                              elevation: 3,
                              borderRadius: BorderRadius.circular(5),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      color: Colors.blue.shade100,
                                      Icons.delete,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        left: 10, top: 5, bottom: 5, right: 5),
                                    // height:
                                    //     50, //MediaQuery.of(context).size.height,
                                    // width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      "Delete Account",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      color: Colors.black,
                                      Icons.arrow_forward_ios,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
