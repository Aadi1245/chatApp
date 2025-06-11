import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:chattest/Services/database.dart';
import 'package:chattest/Services/sendNotificationService.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:chattest/pages/chat/ApiCalling/all_api_calling.dart';
import 'package:chattest/pages/chat/audio_record.dart';
import 'package:chattest/pages/chat/bloc/chatbloc_bloc.dart';
import 'package:chattest/pages/chat/call_screen.dart';
import 'package:chattest/pages/chat/video_call_page.dart';
import 'package:chattest/widget/chatMessageTile.dart';
import 'package:chattest/widget/chat_message_widget.dart';
import 'package:chattest/widget/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:stream_video/protobuf/video/sfu/models/models.pb.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'bloc/gif_keyboard_input.dart';

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

  // bool isRecording = false;

  late AudioRecord _audioRecorder;
  bool _permissionGranted = false;
  String accessTokenForCall = "";
  // FlutterSoundPlayer? _player;
  // bool _isPlaying = false;

  void _listenForIncomingCalls(BuildContext context, String myUserName) {
    FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: myUserName)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) async {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['callType'] == 'video') {
          _showIncomingCallDialog(
            callId: doc.id,
            callerId: data['callerId'],
            streamCallId: data['streamCallId'],
            context: context,
          );
        }
      }
    });
  }

  Future<void> _showIncomingCallDialog({
    required String callId,
    required String callerId,
    required String streamCallId,
    required BuildContext context,
  }) async {
    try {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
              // ... dialog code ...
              ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error handling call: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 12.0,
      );
    }
  }

  onLoad() async {
    accessTokenForCall = await AllApiCalling.createUserAndGetAccessToken(
        widget.userName, widget.name);
    print("accessTokenForCall =============>>>>>> $accessTokenForCall");

    // await getTheSharedpreferenceData();
    // await getAndSetMessage();
    setState(() {});
  }

  Future<bool> requestMicrophonePermission() async {
    // Request microphone permission
    final status = await Permission.microphone.request();

    // Check the result
    if (status.isGranted) {
      return true; // Permission granted, recording can proceed
    } else if (status.isDenied) {
      // Permission denied, but not permanently. You can request again.
      return false;
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied. Prompt the user to enable it in settings.
      await openAppSettings(); // Opens the app settings page
      return false;
    }

    return false; // Default case
  }

  @override
  void initState() {
    // TODO: implement initState
    onLoad();
    // _player = FlutterSoundPlayer();
    // _initPlayer();
    _audioRecorder = AudioRecord();
    _initRecorder();
    GifKeyboardInput.startListening();
    super.initState();
  }

  // Future<void> _initPlayer() async {
  //   await _player!.openPlayer();
  // }

  Future<void> _initRecorder() async {
    _permissionGranted = await requestMicrophonePermission();
    if (_permissionGranted) {
      await _audioRecorder.init();
    } else {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Message deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 12.0,
        );
        openAppSettings();
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _audioRecorder.dispose();

    super.dispose();
  }

  String getChatRoomIdByUserName(String a, String b) {
    List<String> users = [a.toLowerCase(), b.toLowerCase()]..sort();
    return "${users[0]}_${users[1]}";
  }

  // deleteSelectedMessage(String chatRoomId, List<String> messageIds) async {
  //   await DataBasemethods().deleteSelectedMessages(chatRoomId, messageIds);
  // }

  addMessage(
      {bool? sendClicked,
      String? myUserName,
      String? myPicture,
      String? chatRoomId,
      String? fcmToken,
      String? gifUrl}) async {
    if (messageController.text != "") {
      String message = messageController.text;
      messageController.text = "";
      DateTime now = DateTime.now();
      String formatedDate = DateFormat("h:mma").format(now);

      Map<String, dynamic> messageInfoMap = {
        "Data": "message",
        "isPlaying": false,
        "message": gifUrl == null ? message : gifUrl,
        "sendBy": myUserName,
        "ts": formatedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myPicture,
        "fcmToken": fcmToken
      };

      Map<String, dynamic> replyMessageInfoMap = {
        "Data": "replyMessage",
        "isPlaying": false,
        "replyMessage": replyMessage,
        "message": gifUrl == null ? message : gifUrl,
        "sendBy": myUserName,
        "ts": formatedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myPicture,
        "fcmToken": fcmToken
      };

      messageId = randomAlphaNumeric(10);

      await DataBasemethods()
          .addMessage(chatRoomId!, messageId!,
              replyMessage.isNotEmpty ? replyMessageInfoMap : messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": gifUrl == null ? message : gifUrl,
          "replyMessage": replyMessage.isNotEmpty ? replyMessage : "",
          "lastMessageSendBy": myUserName,
          "lastMessageSendTs": formatedDate,
          "time": FieldValue.serverTimestamp()
        };

        DataBasemethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);

        if (sendClicked!) {
          message = "";
        }
      });
      receiverFcmToken =
          await DataBasemethods().getUserFcmToken(widget.userName);
      print(" receiverFcmToken ------------>>>>>>> ${receiverFcmToken}");
      receiverFcmToken != null
          ? Sendnotificationservice.sendNotificationWithApi(
              token: receiverFcmToken,
              title: myUserName,
              body: message,
              data1: {"screen": "chatPage"})
          : "";
      setState(() {
        replyMessage = "";
      });
    }
  }

  String replyMessage = "", replypicture = "";
  bool isSendByMe = false;

  bool mic = true, _isRecording = false;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ChatblocBloc(
            name: widget.name,
            profileUrl: widget.profileUrl,
            userName: widget.userName),
        child:
            BlocBuilder<ChatblocBloc, ChatblocState>(builder: (context, State) {
          // _listenForIncomingCalls(
          //     context, BlocProvider.of<ChatblocBloc>(context).myUserName!);

          if (State is ChatBlocLoadingState) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (State is ChatBlocFailedState) {
            return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Text("Something went wrong!"),
                ));
          } else {
            return Scaffold(
                backgroundColor: Colors.blueGrey,
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  title: Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(color: Colors.white, Icons.arrow_back)),
                  backgroundColor:
                      Colors.blueGrey, // Optional: for contrast with icon
                  elevation: 1, // Optional: to show subtle shadow
                  actions: [
                    PopupMenuButton<String>(
                      onSelected: (String value) async {
                        // Handle menu item click here
                        print("Selected: $value");
                        if (value == "Delete") {
                          if (BlocProvider.of<ChatblocBloc>(context)
                              .messageIds
                              .isNotEmpty) {
                            BlocProvider.of<ChatblocBloc>(context).add(
                                deleteSelectedMsg(
                                    BlocProvider.of<ChatblocBloc>(context)
                                        .messageIds));

                            Fluttertoast.showToast(
                              msg: "Message deleted successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 12.0,
                            );
                          }
                        }
                        if (value == "Video Call") {
                          // Handle video call action
                          print("Video Call clicked");
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => VideoCallPage(
                          //       userId: widget.userName,
                          //       userName: widget.name,
                          //       userToken: accessTokenForCall,
                          //       callId: widget.userName +
                          // BlocProvider.of<ChatblocBloc>(context)
                          //     .myUserName!,
                          //     ),
                          //   ),
                          // );

                          // if (value == "Video Call") {
                          // Create a new Stream.io call
                          final callId = const Uuid().v4();
                          // final client = StreamVideo(
                          //   'vxeyjhp4548f',
                          //   user: User.regular(
                          //     userId: BlocProvider.of<ChatblocBloc>(context)
                          //         .myUserName!,
                          //     name:
                          //         BlocProvider.of<ChatblocBloc>(context).name,
                          //   ),
                          //   userToken: accessTokenForCall,
                          // );

                          StreamVideo.instance.connect(
                            includeUserDetails: true,
                          );

                          try {
                            var call = StreamVideo.instance.makeCall(
                              callType: StreamCallType(),
                              id: BlocProvider.of<ChatblocBloc>(context)
                                  .myUserName!,
                            );

                            await call.getOrCreate(
                              memberIds: [widget.userName],
                              ringing: true,
                            );

                            // Created ahead
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(call: call),
                              ),
                            );
                          } catch (e) {
                            debugPrint('Error joining or creating call: $e');
                            debugPrint(e.toString());
                          }
                          // },
                          // call.getOrCreate(memberIds: [
                          // BlocProvider.of<ChatblocBloc>(context)
                          //     .myUserName!,
                          //   widget.userName
                          // ]);
// grant access to more users
                          // await call.updateCallMembers(updateMembers: [
                          //   UserInfo(id: widget.userName, role: 'call_member')
                          // ]);
// or
                          // await call.addMembers([
                          //   const UserInfo(id: 'charlie', role: 'call_member')
                          // ]);
// remove access from some users
//                             await call
//                                 .updateCallMembers(removeIds: ['charlie']);
// // or
//                             await call.removeMembers(['charlie']);

                          // await call.join();

                          // Create call invitation in Firestore
                          //   await FirebaseFirestore.instance
                          //       .collection('calls')
                          //       .doc(callId)
                          //       .set({
                          //     'callerId': BlocProvider.of<ChatblocBloc>(context)
                          //         .myUserName!,
                          //     'receiverId': widget.userName,
                          //     'status': 'pending',
                          //     'callType': 'video',
                          //     'createdAt': FieldValue.serverTimestamp(),
                          //     'streamCallId': callId,
                          //   });

                          //   // Send push notification to receiver
                          //   receiverFcmToken = await DataBasemethods()
                          //       .getUserFcmToken(widget.userName);
                          //   if (receiverFcmToken != null) {
                          //     Sendnotificationservice.sendNotificationWithApi(
                          //       token: receiverFcmToken,
                          //       title: BlocProvider.of<ChatblocBloc>(context)
                          //           .myUserName!,
                          //       body: 'Incoming video call',
                          //       data1: {"screen": "chatPage", "callId": callId},
                          //     );
                          //   }

                          //   // Join the call immediately
                          //   // await call.join();
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (_) => VideoCallPage(
                          //         userId: BlocProvider.of<ChatblocBloc>(context)
                          //             .myUserName!,
                          //         userName: widget.name,
                          //         userToken: accessTokenForCall,
                          //         callId: callId,
                          //       ),
                          //     ),
                          //   );
                          // }

                          // You can implement your video call logic here
                          // }
                          // if (value == "Clear All Chat") {
                          //   BlocProvider.of<ChatblocBloc>(context)
                          //       .add(ClearChat());
                          // }
                          // }
                          ;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: "Delete",
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Text("Delete"), Icon(Icons.delete)],
                            ),
                          ),
                          PopupMenuItem(
                            value: "Video Call",
                            child: Text("Video Call"),
                          ),
                          // PopupMenuItem(
                          //   value: "Mute",
                          //   child: Text("Mute"),
                          // ),
                        ];
                      },
                      icon: Icon(Icons.more_vert,
                          color: Colors.white), // 3-dot icon
                    ),
                  ],
                ),
                body: Container(
                  child: Column(
                    children: [
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
                              Expanded(
                                // height: MediaQuery.of(context).size.height * 0.78,
                                child: ChatMessageWidget(
                                  widget.profileUrl,
                                  BlocProvider.of<ChatblocBloc>(context)
                                      .messageStream!,
                                  BlocProvider.of<ChatblocBloc>(context)
                                      .myUserName!,
                                  BlocProvider.of<ChatblocBloc>(context),
                                  showReply: (message, sendByMe, Picture) {
                                    // m
                                    print(
                                        "=<><><><><>reply call back<><>>><><> ${message}----->>>>${sendByMe}=======${Picture}");
                                    replyMessage = message;
                                    isSendByMe = sendByMe;
                                    replypicture = Picture;
                                    setState(() {});
                                  },
                                ),
                              ),
                              Visibility(
                                visible: _isRecording,
                                child: Image.asset(
                                  'assets/images/audio_gif2.gif',
                                  height: 80,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Text field with attachment icon
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
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
                                      child: Column(
                                        children: [
                                          Visibility(
                                            visible:
                                                replyMessage.trim().isNotEmpty,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0, left: 8.0),
                                                  child: Text(
                                                    isSendByMe
                                                        ? BlocProvider.of<
                                                                    ChatblocBloc>(
                                                                context)
                                                            .myName!
                                                        : widget.name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    replyMessage
                                                            .contains(".aac")
                                                        ? CommonWidgets
                                                            .audioReplyMessage(
                                                                replypicture)
                                                        : replyMessage.contains(
                                                                ".jpg")
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10), // half of 50 for circle
                                                                  child: Image
                                                                      .network(
                                                                    replyMessage,
                                                                    height: 50,
                                                                    width: 50,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              )
                                                            : replyMessage
                                                                    .contains(
                                                                        ".gif")
                                                                ? Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10), // half of 50 for circle
                                                                      child: Image
                                                                          .network(
                                                                        replyMessage,
                                                                        height:
                                                                            50,
                                                                        width:
                                                                            50,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Expanded(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Text(
                                                                        replyMessage,
                                                                        maxLines:
                                                                            3,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    ),
                                                                  ),
                                                    IconButton(
                                                        onPressed: () {
                                                          replyMessage = "";
                                                          setState(() {});
                                                        },
                                                        icon: Icon(
                                                            Icons.cancel_sharp))
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.gif,
                                                    color: Colors.grey,
                                                    size: 30),
                                                onPressed: () async {
                                                  final gif =
                                                      await GiphyGet.getGif(
                                                    context: context,
                                                    apiKey:
                                                        "fmRcfcCrA0eJVznbt9epr4pIDLh6isoO", // Replace with your Giphy API Key
                                                    lang: GiphyLanguage.english,
                                                    randomID: Uuid().v4(),
                                                    tabColor: Colors.purple,
                                                  );

                                                  if (gif != null) {
                                                    // Step 1: Download GIF as File
                                                    final response = await http
                                                        .get(Uri.parse(gif
                                                            .images!
                                                            .original!
                                                            .url!));
                                                    final tempDir =
                                                        Directory.systemTemp;
                                                    final filePath =
                                                        "${tempDir.path}/${const Uuid().v4()}.gif";
                                                    final selectedGifFile =
                                                        File(filePath);
                                                    await selectedGifFile
                                                        .writeAsBytes(
                                                            response.bodyBytes);

                                                    print(
                                                        "File of GIF--------=======>>>> ${selectedGifFile}");
                                                    BlocProvider.of<
                                                                ChatblocBloc>(
                                                            context)
                                                        .uploadGif(
                                                            BlocProvider.of<
                                                                        ChatblocBloc>(
                                                                    context)
                                                                .myUserName!,
                                                            BlocProvider.of<
                                                                        ChatblocBloc>(
                                                                    context)
                                                                .myPicture!,
                                                            BlocProvider.of<
                                                                        ChatblocBloc>(
                                                                    context)
                                                                .chatRoomId!,
                                                            selectedGifFile);
                                                  }
                                                },
                                              ),
                                              Expanded(
                                                child: TextField(
                                                  onChanged: (value) {
                                                    if (value
                                                        .trim()
                                                        .isNotEmpty) {
                                                      mic = false;
                                                    } else {
                                                      mic = true;
                                                    }

                                                    setState(() {});
                                                  },
                                                  controller: messageController,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  textInputAction:
                                                      TextInputAction.newline,
                                                  maxLines: null,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Type a message...",
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  var image =
                                                      await _picker.pickImage(
                                                          source: ImageSource
                                                              .gallery);
                                                  selectedImage =
                                                      File(image!.path);
                                                  BlocProvider.of<ChatblocBloc>(
                                                          context)
                                                      .uploadImage(
                                                          context,
                                                          BlocProvider.of<
                                                                      ChatblocBloc>(
                                                                  context)
                                                              .myUserName!,
                                                          BlocProvider.of<
                                                                      ChatblocBloc>(
                                                                  context)
                                                              .myPicture!,
                                                          BlocProvider.of<
                                                                      ChatblocBloc>(
                                                                  context)
                                                              .chatRoomId!,
                                                          selectedImage!);
                                                  setState(() {});
                                                },
                                                child: Icon(Icons.attach_file,
                                                    color: Colors.grey[700]),
                                              ),
                                            ],
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
                                    child: GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                            size: 30,
                                            mic
                                                ? Icons.mic_outlined
                                                : Icons.send_rounded,
                                            color: Colors.white),
                                      ),
                                      onLongPress: _permissionGranted
                                          ? () async {
                                              if (mic) {
                                                setState(() {
                                                  _isRecording = true;
                                                });
                                                await _audioRecorder
                                                    .startRecording();
                                              }
                                            }
                                          : null,
                                      onLongPressEnd: _permissionGranted
                                          ? (_) async {
                                              if (mic) {
                                                setState(() {
                                                  _isRecording = false;
                                                });
                                                final filePath =
                                                    await _audioRecorder
                                                        .stopRecording();
                                                if (filePath != null) {
                                                  print(
                                                      "object---------->>>${filePath}");
                                                  BlocProvider.of<ChatblocBloc>(
                                                          context)
                                                      .uploadAudio(filePath);
                                                }
                                              }
                                            }
                                          : null,
                                      onTap: () {
                                        if (messageController.text
                                            .trim()
                                            .isNotEmpty) {
                                          print(
                                              "message sent ----->>>>${messageController.text}");
                                          addMessage(
                                            sendClicked: true,
                                            myUserName:
                                                BlocProvider.of<ChatblocBloc>(
                                                        context)
                                                    .myUserName!,
                                            myPicture:
                                                BlocProvider.of<ChatblocBloc>(
                                                        context)
                                                    .myPicture!,
                                            chatRoomId:
                                                BlocProvider.of<ChatblocBloc>(
                                                        context)
                                                    .chatRoomId!,
                                            fcmToken:
                                                BlocProvider.of<ChatblocBloc>(
                                                        context)
                                                    .fcmToken!,
                                          );

                                          mic = true;
                                        } else {
                                          messageController.text = "";
                                          Fluttertoast.showToast(
                                            msg: "Text should not be empty",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.TOP,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 12.0,
                                          );
                                        }
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
                ));
          }
        }));
    // );
  }

  String? receiverFcmToken;
}
