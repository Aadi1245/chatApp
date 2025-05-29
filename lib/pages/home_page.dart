import 'package:chattest/Services/database.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:chattest/pages/chat/chat_page.dart';
import 'package:chattest/pages/profile.dart';
import 'package:chattest/widget/chat_room_list_tile.dart';
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
  Stream<QuerySnapshot>? chatRoomsStream;
  var queryResultSet = [];
  var tempSearchStore = [];

  String getChatRoomIdByUserName(String a, String b) {
    List<String> users = [a.toLowerCase(), b.toLowerCase()]..sort();
    return "${users[0]}_${users[1]}";
  }

  initiateSearch(String value) {
    if (value.trim().length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        search = false;
      });
      onTheLoad();
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
              print("${tempSearchStore[0]["username"]}------------>>>>>>");
            });
          }
        });
      }
    }
  }

  Widget chatRoomList() {
    print("cha------------------->>>>> inside chtroomlistsdfsvd");
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    print("------------------->>>>> inside chtroomlist");
                    print(
                        "chatroomlist=======${snapshot.data.docs.length}=====>>>>${ds["lastMessage"]}------${ds["lastMessageSendTs"]}");
                    return Column(
                      children: [
                        ChatRoomListTile(
                          chatroomId: ds.id,
                          lastMessage: ds["lastMessage"],
                          myUserName: myUserName != null ? myUserName! : "",
                          time: ds["lastMessageSendTs"],
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    );
                  })
              : Container();
        });
  }

  @override
  void initState() {
    onTheLoad();
    super.initState();
  }

  List<String> subName = [""];
  onTheLoad() async {
    await getTheSharedpreferenceData();
    chatRoomsStream = await DataBasemethods().getChatRooms();

    print(" after on the load chatRoomsStream-------->>>>${chatRoomsStream}");

    subName = myName!.split(" ");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 40, left: 15),
              child: Row(
                children: [
                  Text(
                    "👋",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.yellowAccent),
                  ),
                  Text(
                    " Hello,",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  Text(
                    subName.first,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Profile()));
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(
                        Icons.person,
                        size: 30,
                      ),
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
                          // searchController.text == ""
                          //     ? search = false
                          //     : search = true;
                          // setState(() {});
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
                              print("${e["username"]}");
                              return buildResultCard(e);
                            }).toList(),
                          )
                        : chatRoomList()
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
        print("---------------${data["username"]}------${myUserName!}------");
        String chatRoomId =
            getChatRoomIdByUserName(myUserName!, data['username']);
        print("-----------chat chat-----${chatRoomId!}------");
        Map<String, dynamic> chatInfoMap = {
          "user": [myUserName, data['username']],
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
                Expanded(
                  child: Column(
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
