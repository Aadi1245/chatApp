import 'dart:io';

import 'package:chattest/Services/database.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:chattest/pages/chat/bloc/chatbloc_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  String userName, profileUrl, name;
  ChatPage(
      {required this.name,
      required this.profileUrl,
      required this.userName,
      super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // String? myUserName, myName, myEmail, myPicture, chatRoomId,
  String? messageId;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  TextEditingController messageController = TextEditingController();
  // getTheSharedpreferenceData() async {
  //   myUserName = await SharedPreferenceHelper().getUserName();
  //   myName = await SharedPreferenceHelper().getUserDisplayName();
  //   myEmail = await SharedPreferenceHelper().getUserEmail();
  //   myPicture = await SharedPreferenceHelper().getUserImage();
  //   chatRoomId = getChatRoomIdByUserName(myUserName!, widget.userName);
  //   print("chatpage shared chatroomid --- ${chatRoomId}");
  //   setState(() {});
  // }

  bool isRecording = false;
  String? _filePah;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  Future getImage(
      String myUserName, String myPicture, String chatRoomId) async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(image!.path);
    _uploadImage(myUserName, myPicture, chatRoomId);
    setState(() {});
  }

  Future<void> _uploadImage(
      String myUserName, String myPicture, String chatRoomId) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Your image is uploading please wait...",
          style: TextStyle(fontSize: 20),
        )));

    try {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("blogImage").child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var downloadUrl = await (await task).ref.getDownloadURL();

      DateTime now = DateTime.now();
      String formattedDate = DateFormat("h:mma").format(now);
      Map<String, dynamic> messageInfoMap = {
        "Data": "Image",
        "message": downloadUrl,
        "sendBy": myUserName, // myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgurl": myPicture //myPicture
      };
      messageId = randomAlphaNumeric(10);
      await DataBasemethods()
          .addMessage(chatRoomId, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": "Image",
          "lastMessageSendBy": myUserName,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp()
        };
        DataBasemethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);
      });
    } catch (e) {
      print("Image throw excetion====${e}");
    }
  }

  Future<void> _initialize() async {
    await _recorder.openRecorder();
    await _requestPermission();
    var tempDir = await getTemporaryDirectory();
    _filePah = "${tempDir}/adio.aac";
  }

  Future<void> _requestPermission() async {
    var status = await Permission.microphone.status;

    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _startRecording(
      String myUserName, String myPicture, String chatRoomId) async {
    await _recorder.startRecorder(toFile: _filePah);
    setState(() {
      isRecording = true;
      Navigator.pop(context);
      openRecording(myUserName, myPicture, chatRoomId);
    });
  }

  Future<void> _stopRecording(
      String myUserName, String myPicture, String chatRoomId) async {
    await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
      Navigator.pop(context);
      openRecording(myUserName, myPicture, chatRoomId);
    });
  }

  Future openRecording(
          String myUserName, String myPicture, String chatRoomId) =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          "Add Voice Note",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              if (isRecording) {
                                _startRecording(
                                    myUserName, myPicture, chatRoomId);
                              } else {
                                _startRecording(
                                    myUserName, myPicture, chatRoomId);
                              }
                            },
                            child: Text(
                              isRecording
                                  ? "Stop Recording"
                                  : "Start Recording",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              if (isRecording) {
                                null;
                              } else {
                                _uploadFile(myUserName, myPicture, chatRoomId);
                              }
                            },
                            child: Text(
                              "Upload Audio",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  ),
                ),
              ));

  Future<void> _uploadFile(
      String myUserName, String myPicture, String chatRoomId) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Your audio is uploading please wait...",
          style: TextStyle(fontSize: 20),
        )));

    File file = File(_filePah!);

    try {
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref("uploads/audio.aac").putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat("h:mma").format(now);
      Map<String, dynamic> messageInfoMap = {
        "Data": "Audio",
        "message": downloadUrl,
        "sendBy": myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgurl": myPicture
      };
      messageId = randomAlphaNumeric(10);
      await DataBasemethods()
          .addMessage(chatRoomId, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": "Audio",
          "lastMessageSendBy": myUserName,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp()
        };
        DataBasemethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);
      });
    } catch (e) {
      print("audio throw excetion====${e}");
    }
  }

  onLoad() async {
    // await getTheSharedpreferenceData();
    // await getAndSetMessage();
    // setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    onLoad();
    super.initState();
  }

  String getChatRoomIdByUserName(String a, String b) {
    List<String> users = [a.toLowerCase(), b.toLowerCase()]..sort();
    return "${users[0]}_${users[1]}";
  }

  addMessage(bool sendClicked, String myUserName, String myPicture,
      String chatRoomId) async {
    if (messageController.text != "") {
      String message = messageController.text;
      messageController.text = "";
      DateTime now = DateTime.now();
      String formatedDate = DateFormat("h:mma").format(now);

      Map<String, dynamic> messageInfoMap = {
        "Data": "message",
        "message": message,
        "sendBy": myUserName,
        "ts": formatedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myPicture
      };
      messageId = randomAlphaNumeric(10);

      await DataBasemethods()
          .addMessage(chatRoomId, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendBy": myUserName,
          "lastMessageSendTs": formatedDate,
          "time": FieldValue.serverTimestamp()
        };
        DataBasemethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);

        if (sendClicked) {
          message = "";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      resizeToAvoidBottomInset: true,
      body: BlocProvider(
          create: (context) => ChatblocBloc(
              name: widget.name,
              profileUrl: widget.profileUrl,
              userName: widget.userName),
          child: BlocBuilder<ChatblocBloc, ChatblocState>(
              builder: (context, State) {
            if (State is ChatBlocLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (State is ChatBlocFailedState) {
              return Center(
                child: Text("Something went wrong!"),
              );
            } else {
              return Container(
                margin: EdgeInsets.only(
                  top: 35,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            )),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                        ),
                        Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30))),
                        child: Column(
                          children: [
                            // SizedBox(
                            //   height: 30,
                            // ),
                            Expanded(
                              // height: MediaQuery.of(context).size.height * 0.78,
                              child: chatMessage(
                                  BlocProvider.of<ChatblocBloc>(context)
                                      .messageStream!),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Microphone button
                                Container(
                                  margin: EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueGrey,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.mic, color: Colors.white),
                                    onPressed: () {
                                      // Handle mic
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),

                                // Text field with attachment icon
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    margin: EdgeInsets.only(bottom: 6),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: messageController,
                                            decoration: InputDecoration(
                                              hintText: "Type a message...",
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // getImage(
                                            //     BlocProvider.of<ChatblocBloc>(
                                            //             context)
                                            //         .myUserName!,
                                            //     BlocProvider.of<ChatblocBloc>(
                                            //             context)
                                            //         .myPicture!,
                                            //     BlocProvider.of<ChatblocBloc>(
                                            //             context)
                                            //         .chatRoomId!);
                                          },
                                          child: Icon(Icons.attach_file,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),

                                // Send button
                                Container(
                                  margin: EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueGrey,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.send, color: Colors.white),
                                    onPressed: () {
                                      addMessage(
                                          true,
                                          BlocProvider.of<ChatblocBloc>(context)
                                              .myUserName!,
                                          BlocProvider.of<ChatblocBloc>(context)
                                              .myPicture!,
                                          BlocProvider.of<ChatblocBloc>(context)
                                              .chatRoomId!);
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          })),
    );
  }

  // Stream? messageStream;

  Widget chatMessage(Stream messageStream) {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    print(
                        "chat messages-${snapshot.data.docs.length}----${ds["message"]}--${ds["sendBy"]}----${ds["Data"]}--");
                    return chatMessageTile(
                        ds["message"],
                        BlocProvider.of<ChatblocBloc>(context).myUserName ==
                            ds["sendBy"],
                        ds["Data"]);
                  })
              : Container();
        });
  }

  // getAndSetMessage() async {
  //   print(
  //       "${BlocProvider.of<ChatblocBloc>(context).chatRoomId}chat page===========");
  //   messageStream = await DataBasemethods()
  //       .getChatRoomMessage(BlocProvider.of<ChatblocBloc>(context).chatRoomId);
  //   print("${messageStream!.first}chat page after ===========");
  //   setState(() {});
  // }

  Widget chatMessageTile(String message, bool sendByMe, String Data) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft:
                      sendByMe ? Radius.circular(15) : Radius.circular(0),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(15)),
              color: sendByMe
                  ? Color.fromARGB(255, 197, 223, 222)
                  : Colors.blue.shade100),
          child: Data == "Image"
              ? Image.network(
                  message,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                )
              : Data == "Audio"
                  ? Row(
                      children: [
                        Icon(
                          Icons.mic,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Audio",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  : Text(
                      message,
                      style: TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
        ))
      ],
    );
  }
}
