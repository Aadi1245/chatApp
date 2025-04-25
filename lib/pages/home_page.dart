import 'package:chattest/Services/database.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:chattest/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();

  bool search = false;
  Stream? chatRoomsStream;
  var queryResultSet = [];
  var tempSearchStore = [];

  getChatRoomIdByUserName(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  initiateSearch(String value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    } else {
      setState(() {
        search = true;
      });
      var capitalizedValue =
          value.substring(0, 1).toUpperCase() + value.substring(1);
      if (queryResultSet.isEmpty && value.length == 1) {
        DataBasemethods().search(value).then((QuerySnapshot docs) {
          for (int i = 0; i < docs.docs.length; i++) {
            queryResultSet.add(docs.docs[i].data());
          }
        });
      } else {
        tempSearchStore = [];
        queryResultSet.forEach((element) {
          if (element['username'].startsWith(capitalizedValue)) {
            setState(() {
              tempSearchStore.add(element);
            });
          }
        });
      }
    }
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs['index'];
                  })
              : Container();
        });
  }

  @override
  void initState() {
    getTheSharedpreferenceData();
    super.initState();
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
              margin: EdgeInsets.only(top: 40, left: 15),
              child: Row(
                children: [
                  Text(
                    "👋 ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.yellowAccent),
                  ),
                  Text(
                    " Hello, ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  Text(
                    "Aadi ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      Icons.person,
                      size: 30,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              alignment: Alignment.topLeft,
              child: Text(
                "Welcome to  ",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              width: 30,
            ),
            Container(
              height: 70,
              margin: EdgeInsets.only(left: 25),
              alignment: Alignment.topLeft,
              child: Text(
                "ChatIt  ",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 50,
                      padding: EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(83, 212, 226, 231)),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          initiateSearch(value.toUpperCase());
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: "Search here...",
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    search
                        ? ListView(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            shrinkWrap: true,
                            primary: false,
                            children: tempSearchStore.map((e) {
                              return buildResultCard(e);
                            }).toList(),
                          )
                        : Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.asset(
                                      "assets/images/profile_img.jpg",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Tony Stark",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                      Text(
                                        "hello cap how are you ?",
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color.fromARGB(
                                                78, 0, 0, 0)),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "2:00 Pm",
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
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

  String? myUserName, myName, myEmail, myPicture;
  TextEditingController messageController = TextEditingController();
  getTheSharedpreferenceData() async {
    myUserName = await SharedPreferenceHelper().getUserName();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        String chatRoomId =
            getChatRoomIdByUserName(myPicture!, data['username']);

        Map<String, dynamic> chatInfoMap = {
          "users": [myUserName, data['username']],
        };
        await DataBasemethods().creatChatRoom(chatRoomId, chatInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: data['Name'],
                    profileUrl: data["Image"],
                    userName: data["username"])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    data['Image'],
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      data['Name'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    Text(
                      data['username'],
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(78, 0, 0, 0)),
                    ),
                  ],
                ),
                // Spacer(),
                // Container(
                //   alignment: Alignment.topLeft,
                //   child: Text(
                //     "2:00 Pm",
                //     textAlign: TextAlign.left,
                //     maxLines: 1,
                //     overflow: TextOverflow.ellipsis,
                //     style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.black),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  const ChatRoomListTile({super.key});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                "assets/images/profile_img.jpg",
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Tony Stark",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Text(
                  "hello cap how are you ?",
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(78, 0, 0, 0)),
                ),
              ],
            ),
            Spacer(),
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                "2:00 Pm",
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
