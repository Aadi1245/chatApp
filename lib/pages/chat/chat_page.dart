import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chattest/Services/database.dart';
import 'package:chattest/Services/shared_pref.dart';
import 'package:chattest/pages/chat/audio_record.dart';
import 'package:chattest/pages/chat/bloc/chatbloc_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:record/record.dart';

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
  String? _filePah;
  // FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  late AudioRecord _audioRecorder;
  bool _permissionGranted = false;

  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  FlutterSoundPlayer? _player;
  bool _isPlaying = false;

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
      // TaskSnapshot snapshot =
      //     await FirebaseStorage.instance.ref("uploads/audio.aac").putFile(file);
      // String downloadUrl = "await snapshot.ref.getDownloadURL()";

      // DateTime now = DateTime.now();
      // String formattedDate = DateFormat("h:mma").format(now);
      // Map<String, dynamic> messageInfoMap = {
      //   "Data": "Audio",
      //   "message": downloadUrl,
      //   "sendBy": myUserName,
      //   "ts": formattedDate,
      //   "time": FieldValue.serverTimestamp(),
      //   "imgurl": myPicture
      // };
      // messageId = randomAlphaNumeric(10);
      // await DataBasemethods()
      //     .addMessage(chatRoomId, messageId!, messageInfoMap)
      //     .then((value) {
      //   Map<String, dynamic> lastMessageInfoMap = {
      //     "lastMessage": "Audio",
      //     "lastMessageSendBy": myUserName,
      //     "lastMessageSendTs": formattedDate,
      //     "time": FieldValue.serverTimestamp()
      //   };
      //   DataBasemethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);
      // });
    } catch (e) {
      print("audio throw excetion====${e}");
    }
  }

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
                                  widget.profileUrl,
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
                                  child: GestureDetector(
                                    child: Icon(
                                        size: 45,
                                        Icons.mic,
                                        color: Colors.white),
                                    onLongPress: _permissionGranted
                                        ? () async {
                                            await _audioRecorder
                                                .startRecording();
                                            setState(() {});
                                          }
                                        : null,
                                    onLongPressEnd: _permissionGranted
                                        ? (_) async {
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
                                            setState(() {});
                                          }
                                        : null,
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
                                          onTap: () async {
                                            var image = await _picker.pickImage(
                                                source: ImageSource.gallery);
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

  Widget chatMessage(String friendPic, Stream messageStream) {
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
                        "chat messages-sdf${snapshot.data.docs.length}----${ds["message"]}--${ds["sendBy"]}----${ds["Data"]}--");
                    return chatMessageTile(
                        BlocProvider.of<ChatblocBloc>(context).myUserName ==
                                ds["sendBy"]
                            ? BlocProvider.of<ChatblocBloc>(context).myPicture!
                            : friendPic,
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

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription? _progressSubscription;

  Widget chatMessageTile(
      String senderProfilePic, String message, bool sendByMe, String Data) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          padding: Data == "Image"
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
          child: Data == "Image"
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    message,
                    height: 200,
                    width: 200,
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
                              _isPlaying
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
