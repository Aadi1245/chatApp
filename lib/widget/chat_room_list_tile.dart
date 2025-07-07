import 'package:chattest/Utils/Services/database.dart';
import 'package:chattest/views/chat/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoomListTile extends StatefulWidget {
  String chatroomId, lastMessage, myUserName, time;
  ChatRoomListTile(
      {required this.chatroomId,
      required this.lastMessage,
      required this.myUserName,
      required this.time,
      super.key});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", userName = "", id = "";

  getThisUserInfo() async {
    userName =
        widget.chatroomId.replaceAll("_", "").replaceAll(widget.myUserName, "");
    print("username to find -------<><><><><><><><>${userName}");
    QuerySnapshot querySnapshot =
        await DataBasemethods().getUserInfo(userName.toUpperCase());
    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["Image"]}";
    id = "${querySnapshot.docs[0]["Id"]}";

    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("chatroomlist tile data------------->>>");
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                      name: name,
                      profileUrl: profilePicUrl,
                      userName: userName)));
        },
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
                profilePicUrl == ""
                    ? SizedBox(
                        height: 70,
                        width: 70,
                        child: Center(child: CircularProgressIndicator()))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          profilePicUrl,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(78, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  constraints: BoxConstraints(maxWidth: 70),
                  alignment: Alignment.topRight,
                  child: Text(
                    widget.time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
