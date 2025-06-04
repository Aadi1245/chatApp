import 'package:chattest/widget/chatMessageTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../pages/chat/bloc/chatbloc_bloc.dart';

class ChatMessageWidget extends StatefulWidget {
  String friendPic;
  Stream messageStream;
  String myUsername;
  ChatblocBloc chatbloc;
  Function(String message, bool sendByMe, String picture)? showReply;

  ChatMessageWidget(
      this.friendPic, this.messageStream, this.myUsername, this.chatbloc,
      {super.key, this.showReply});

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  // List<String> messageIds = [];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    final data = ds.data() as Map<String, dynamic>;
                    final isPlaying = data["isPlaying"] ?? false;

                    // print(
                    //     "----------- ds[isPlaying]-------${ds.data()}----------dsisPlaying----${ds.get("isPlaying")}---${ds["isPlaying"]}");
                    // print(
                    //     "chat messages-sdf-------1${widget.chatbloc.messageIds}--------${snapshot.data.docs.length}----${ds["message"]}--${ds["sendBy"]}----${ds["Data"]}--");
                    return GestureDetector(
                      onTap: () {
                        if (widget.chatbloc.messageIds.isNotEmpty) {
                          if (widget.chatbloc.messageIds.contains(ds.id)) {
                            widget.chatbloc.messageIds
                                .removeWhere((item) => item == ds.id);
                            setState(() {});
                          } else {
                            if (widget.chatbloc.myUserName == ds["sendBy"]) {
                              widget.chatbloc.messageIds.add(ds.id);
                            } else {
                              Fluttertoast.showToast(
                                msg:
                                    "You don't have permission to modify this message.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 12.0,
                              );
                            }
                            setState(() {});
                          }
                        }
                      },
                      onLongPress: () {
                        if (widget.chatbloc.messageIds.contains(ds.id)) {
                          widget.chatbloc.messageIds
                              .removeWhere((item) => item == ds.id);
                          setState(() {});
                        } else {
                          if (widget.chatbloc.myUserName == ds["sendBy"]) {
                            widget.chatbloc.messageIds.add(ds.id);
                          } else {
                            Fluttertoast.showToast(
                              msg:
                                  "You don't have permission to modify this message.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 12.0,
                            );
                          }
                          setState(() {});
                        }
                      },
                      child: Chatmessagetile(
                        widget.chatbloc.myUserName == ds["sendBy"]
                            ? widget.chatbloc.myPicture!
                            : widget.friendPic,
                        ds["message"] != null ? ds["message"] : "failed",
                        widget.chatbloc.myUserName == ds["sendBy"],
                        ds["Data"],
                        widget.chatbloc.messageIds.contains(ds.id),
                        isplaying: isPlaying,
                        showReply: () {
                          // print("message kya 11111h ${ds["message"]}----->>>>");
                          if (ds["message"] != null) {
                            widget.showReply!(
                              ds["message"],
                              widget.chatbloc.myUserName == ds["sendBy"],
                              widget.chatbloc.myUserName == ds["sendBy"]
                                  ? widget.chatbloc.myPicture!
                                  : widget.friendPic,
                            );
                          }
                        },
                        replyMessage: ds["Data"] == "replyMessage"
                            ? ds["replyMessage"]
                            : "",
                      ),
                    );
                  })
              : Container();
        });
    ;
  }
}
