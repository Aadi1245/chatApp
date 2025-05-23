import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chattest/Services/database.dart';
import 'package:chattest/Services/sendNotificationService.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:chattest/pages/chat/audio_record.dart';
import 'package:chattest/pages/chat/bloc/chatbloc_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  bool isRecording = false;

  late AudioRecord _audioRecorder;
  bool _permissionGranted = false;

  FlutterSoundPlayer? _player;
  bool _isPlaying = false;

  onLoad() async {
    // await getTheSharedpreferenceData();
    // await getAndSetMessage();
    // setState(() {});
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
    _player = FlutterSoundPlayer();
    _initPlayer();
    _audioRecorder = AudioRecord();
    _initRecorder();
    GifKeyboardInput.startListening();
    super.initState();
  }

  Future<void> _initPlayer() async {
    await _player!.openPlayer();
  }

  Future<void> _initRecorder() async {
    _permissionGranted = await requestMicrophonePermission();
    if (_permissionGranted) {
      await _audioRecorder.init();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Microphone permission is required to record audio.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _player!.stopPlayer();
    _progressSubscription?.cancel();
    _player?.closePlayer();

    _player = null;
    super.dispose();
  }

  String getChatRoomIdByUserName(String a, String b) {
    List<String> users = [a.toLowerCase(), b.toLowerCase()]..sort();
    return "${users[0]}_${users[1]}";
  }

  deleteSelectedMessage(String chatRoomId, List<String> messageIds) async {
    await DataBasemethods().deleteSelectedMessages(chatRoomId, messageIds);
  }

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

      messageId = randomAlphaNumeric(10);

      await DataBasemethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": gifUrl == null ? message : gifUrl,
          "lastMessageSendBy": myUserName,
          "lastMessageSendTs": formatedDate,
          "time": FieldValue.serverTimestamp()
        };
        DataBasemethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);

        if (sendClicked!) {
          message = "";
        }
      });
    }
  }

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
                      onSelected: (String value) {
                        // Handle menu item click here
                        print("Selected: $value");
                        if (value == "Delete") {
                          if (messageIds.isNotEmpty) {
                            BlocProvider.of<ChatblocBloc>(context)
                                .add(deleteSelectedMsg(messageIds));

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
                        if (value == "Clear All Chat") {
                          BlocProvider.of<ChatblocBloc>(context)
                              .add(ClearChat());
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
                          // PopupMenuItem(
                          //   value: "Clear All Chat",
                          //   child: Text("Clear All Chat"),
                          // ),
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
                                child: chatMessage(
                                    widget.profileUrl,
                                    BlocProvider.of<ChatblocBloc>(context)
                                        .messageStream!,
                                    BlocProvider.of<ChatblocBloc>(context)
                                        .myUserName!),
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
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.gif,
                                                color: Colors.grey, size: 30),
                                            onPressed: () async {
                                              final gif = await GiphyGet.getGif(
                                                context: context,
                                                apiKey:
                                                    "fmRcfcCrA0eJVznbt9epr4pIDLh6isoO", // Replace with your Giphy API Key
                                                lang: GiphyLanguage.english,
                                                randomID: Uuid().v4(),
                                                tabColor: Colors.purple,
                                              );

                                              if (gif != null) {
                                                // Step 1: Download GIF as File
                                                final response = await http.get(
                                                    Uri.parse(gif.images!
                                                        .original!.url!));
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
                                                BlocProvider.of<ChatblocBloc>(
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
                                                        selectedGifFile,
                                                        receiverFcmToken!);
                                              }
                                            },
                                          ),
                                          Expanded(
                                            child: TextField(
                                              onChanged: (value) {
                                                if (value.trim().isNotEmpty) {
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
                                                hintText: "Type a message...",
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              var image =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              selectedImage = File(image!.path);
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
  // Stream? messageStream;
  List<String> messageIds = [];
  Widget chatMessage(
      String friendPic, Stream messageStream, String myUsername) {
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

                    // print(
                    //     "chat messages-sdf-------1${messageIds}--------${snapshot.data.docs.length}----${ds["message"]}--${ds["sendBy"]}----${ds["Data"]}--");
                    return GestureDetector(
                      onTap: () {
                        if (messageIds.isNotEmpty) {
                          if (messageIds.contains(ds.id)) {
                            messageIds.removeWhere((item) => item == ds.id);
                            setState(() {});
                          } else {
                            if (BlocProvider.of<ChatblocBloc>(context)
                                    .myUserName ==
                                ds["sendBy"]) {
                              messageIds.add(ds.id);
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
                        if (messageIds.contains(ds.id)) {
                          messageIds.removeWhere((item) => item == ds.id);
                          setState(() {});
                        } else {
                          if (BlocProvider.of<ChatblocBloc>(context)
                                  .myUserName ==
                              ds["sendBy"]) {
                            messageIds.add(ds.id);
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
                      child: chatMessageTile(
                          BlocProvider.of<ChatblocBloc>(context).myUserName ==
                                  ds["sendBy"]
                              ? BlocProvider.of<ChatblocBloc>(context)
                                  .myPicture!
                              : friendPic,
                          ds["message"] != null ? ds["message"] : "failed",
                          BlocProvider.of<ChatblocBloc>(context).myUserName ==
                              ds["sendBy"],
                          ds["Data"],
                          messageIds.contains(ds.id),
                          isplaying: ds["isPlaying"].toString() != "false"),
                    );
                  })
              : Container();
        });
  }

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription? _progressSubscription;

  Widget chatMessageTile(String senderProfilePic, String message, bool sendByMe,
      String Data, bool isSelected,
      {bool? isplaying}) {
    return Container(
      color: isSelected ? Color.fromARGB(109, 127, 228, 235) : Colors.white,
      child: Row(
        mainAxisAlignment:
            sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
              child: Container(
            padding: Data == "Image" || Data == "GIF"
                ? EdgeInsets.all(5)
                : Data == "Audio"
                    ? EdgeInsets.all(5)
                    : EdgeInsets.all(12),
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
            child: Data == "Image" || Data == "GIF"
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      message,
                      height: Data == "GIF" ? 250 : 200,
                      width: Data == "GIF" ? 250 : 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Data == "Audio"
                    ? Container(
                        decoration: BoxDecoration(
                          // color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            audioProfileWithMic(senderProfilePic),
                            IconButton(
                              icon: Icon(
                                size: 35,
                                isplaying!
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                if (_isPlaying) {
                                  await _player!.stopPlayer();
                                  await _progressSubscription?.cancel();
                                  setState(() {
                                    _isPlaying = false;
                                    _position = Duration.zero;
                                    _duration = Duration.zero;
                                  });
                                } else {
                                  await _player!.startPlayer(
                                    fromURI: message,
                                    // codec: Codec.aacADTS,
                                    whenFinished: () async {
                                      await _progressSubscription?.cancel();
                                      setState(() {
                                        _isPlaying = false;
                                        _position = Duration.zero;
                                        _duration = Duration.zero;
                                      });
                                    },
                                  );

                                  _progressSubscription =
                                      _player!.onProgress!.listen((event) {
                                    if (event != null && mounted) {
                                      setState(() {
                                        _position = event.position;
                                        _duration = event.duration;

                                        print(
                                            "time------------->>>>>${_duration.inMilliseconds}");
                                      });
                                    }
                                  });

                                  setState(() {
                                    _isPlaying = true;
                                    isplaying = true;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: LinearProgressIndicator(
                              value: (_duration.inMilliseconds == 0)
                                  ? 0
                                  : _position.inMilliseconds /
                                      _duration.inMilliseconds,
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                            )),
                            const SizedBox(width: 8),
                          ],
                        ),
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
      ),
    );
  }

  Widget audioProfileWithMic(String imageUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25), // half of 50 for circle
          child: Image.network(
            imageUrl,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 35,
          left: 35,
          bottom: 0,
          right: 0,
          // child: Container(
          //   height: 20,
          //   width: 20,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Colors.black.withOpacity(0.6),
          //   ),
          child: Icon(
            Icons.mic,
            size: 18,
            color: Colors.grey,
          ),
          // ),
        ),
      ],
    );
  }
}
