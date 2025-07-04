import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:chattest/Services/call_service.dart';
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

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  String? messageId;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  TextEditingController messageController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  late AudioRecord _audioRecorder;
  bool _permissionGranted = false;
  String accessTokenForCall = "";

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Incoming Call'),
            content: Text('$callerId is calling you...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Decline'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Accept'),
              ),
            ],
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
    setState(() {});
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  @override
  void initState() {
    onLoad();
    _audioRecorder = AudioRecord();
    _initRecorder();
    GifKeyboardInput.startListening();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    super.initState();
  }

  Future<void> _initRecorder() async {
    _permissionGranted = await requestMicrophonePermission();
    if (_permissionGranted) {
      await _audioRecorder.init();
    } else {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Microphone permission required",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.orange,
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
    _animationController.dispose();
    super.dispose();
  }

  String getChatRoomIdByUserName(String a, String b) {
    List<String> users = [a.toLowerCase(), b.toLowerCase()]..sort();
    return "${users[0]}_${users[1]}";
  }

  addMessage(
      {bool? sendClicked,
      String? myUserName,
      String? myPicture,
      String? chatRoomId,
      String? fcmToken,
      String? gifUrl}) async {
    if (messageController.text.trim().isNotEmpty) {
      String message = messageController.text.trim();
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
      });

      receiverFcmToken =
          await DataBasemethods().getUserFcmToken(widget.userName);
      receiverFcmToken != null
          ? Sendnotificationservice.sendNotificationWithApi(
              token: receiverFcmToken,
              title: myUserName,
              body: message,
              data1: {"screen": "chatPage"})
          : "";

      setState(() {
        replyMessage = "";
        mic = true;
      });
    }
  }

  String replyMessage = "", replypicture = "";
  bool isSendByMe = false;
  bool mic = true, _isRecording = false;
  String? receiverFcmToken;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatblocBloc(
          name: widget.name,
          profileUrl: widget.profileUrl,
          userName: widget.userName),
      child: BlocBuilder<ChatblocBloc, ChatblocState>(
        builder: (context, state) {
          if (state is ChatBlocLoadingState) {
            return Scaffold(
              backgroundColor: Color(0xFF1A1A2E),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA)),
                ),
              ),
            );
          } else if (state is ChatBlocFailedState) {
            return Scaffold(
              backgroundColor: Color(0xFF1A1A2E),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Something went wrong!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: Color(0xFF1A1A2E),
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color(0xFF16213E),
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Row(
                  children: [
                    Hero(
                      tag: 'profile_${widget.userName}',
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF00D4AA),
                        backgroundImage: widget.profileUrl.isNotEmpty
                            ? NetworkImage(widget.profileUrl)
                            : null,
                        child: widget.profileUrl.isEmpty
                            ? Text(
                                widget.name.isNotEmpty
                                    ? widget.name[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF00D4AA),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.videocam, color: Colors.white),
                    onPressed: () {
                      final callId =
                          '${BlocProvider.of<ChatblocBloc>(context).myUserName!}_${widget.userName}_${DateTime.now().millisecondsSinceEpoch}';
                      CallService().startCall(
                        context: context,
                        callId: callId,
                        calleeUserId: widget.userName,
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    color: Color(0xFF16213E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (String value) async {
                      if (value == "Delete") {
                        if (BlocProvider.of<ChatblocBloc>(context)
                            .messageIds
                            .isNotEmpty) {
                          BlocProvider.of<ChatblocBloc>(context).add(
                              deleteSelectedMsg(
                                  BlocProvider.of<ChatblocBloc>(context)
                                      .messageIds));
                          Fluttertoast.showToast(
                            msg: "Messages deleted successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Color(0xFF00D4AA),
                            textColor: Colors.white,
                            fontSize: 12.0,
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          value: "Delete",
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text("Delete Selected",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF16213E),
                      Color(0xFF1A1A2E),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ChatMessageWidget(
                                widget.profileUrl,
                                BlocProvider.of<ChatblocBloc>(context)
                                    .messageStream!,
                                BlocProvider.of<ChatblocBloc>(context)
                                    .myUserName!,
                                BlocProvider.of<ChatblocBloc>(context),
                                showReply: (message, sendByMe, picture) {
                                  replyMessage = message;
                                  isSendByMe = sendByMe;
                                  replypicture = picture;
                                  setState(() {});
                                },
                              ),
                            ),

                            // Recording animation
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: _isRecording ? 100 : 0,
                              child: _isRecording
                                  ? Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF00D4AA).withOpacity(0.1),
                                            Color(0xFF00D4AA).withOpacity(0.05),
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedBuilder(
                                            animation: _pulseAnimation,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale: _pulseAnimation.value,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            "Recording...",
                                            style: TextStyle(
                                              color: Color(0xFF00D4AA),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),

                            // Message input area
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Reply preview
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    height:
                                        replyMessage.trim().isNotEmpty ? 80 : 0,
                                    child: replyMessage.trim().isNotEmpty
                                        ? Container(
                                            margin: EdgeInsets.only(bottom: 12),
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF00D4AA)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Color(0xFF00D4AA)
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 4,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF00D4AA),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        isSendByMe
                                                            ? BlocProvider.of<
                                                                        ChatblocBloc>(
                                                                    context)
                                                                .myName!
                                                            : widget.name,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFF00D4AA),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Expanded(
                                                        child: Text(
                                                          _getReplyPreview(
                                                              replyMessage),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.close,
                                                      size: 20,
                                                      color: Colors.grey),
                                                  onPressed: () {
                                                    replyMessage = "";
                                                    setState(() {});
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ),

                                  // Input row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF8F9FA),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            border: Border.all(
                                              color: Color(0xFFE9ECEF),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.gif_box,
                                                  color: Color(0xFF00D4AA),
                                                  size: 28,
                                                ),
                                                onPressed: () async {
                                                  final gif =
                                                      await GiphyGet.getGif(
                                                    context: context,
                                                    apiKey:
                                                        "fmRcfcCrA0eJVznbt9epr4pIDLh6isoO",
                                                    lang: GiphyLanguage.english,
                                                    randomID: Uuid().v4(),
                                                    tabColor: Color(0xFF00D4AA),
                                                  );

                                                  if (gif != null) {
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
                                                  controller: messageController,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  textInputAction:
                                                      TextInputAction.newline,
                                                  maxLines: null,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      mic =
                                                          value.trim().isEmpty;
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "Type a message...",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 16,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.attach_file,
                                                  color: Color(0xFF00D4AA),
                                                ),
                                                onPressed: () async {
                                                  var image =
                                                      await _picker.pickImage(
                                                          source: ImageSource
                                                              .gallery);
                                                  if (image != null) {
                                                    selectedImage =
                                                        File(image.path);
                                                    BlocProvider.of<
                                                                ChatblocBloc>(
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
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),

                                      // Send/Mic button
                                      GestureDetector(
                                        onTap: () {
                                          if (!mic) {
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
                                          }
                                        },
                                        onLongPress: _permissionGranted && mic
                                            ? () async {
                                                setState(() {
                                                  _isRecording = true;
                                                });
                                                _animationController.repeat(
                                                    reverse: true);
                                                await _audioRecorder
                                                    .startRecording();
                                              }
                                            : null,
                                        onLongPressEnd: _permissionGranted &&
                                                mic
                                            ? (_) async {
                                                setState(() {
                                                  _isRecording = false;
                                                });
                                                _animationController.stop();
                                                final filePath =
                                                    await _audioRecorder
                                                        .stopRecording();
                                                if (filePath != null) {
                                                  BlocProvider.of<ChatblocBloc>(
                                                          context)
                                                      .uploadAudio(filePath);
                                                }
                                              }
                                            : null,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF00D4AA),
                                                Color(0xFF00B894),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF00D4AA)
                                                    .withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            mic ? Icons.mic : Icons.send,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _getReplyPreview(String message) {
    if (message.contains(".aac")) {
      return "🎵 Audio message";
    } else if (message.contains(".jpg") || message.contains(".png")) {
      return "📷 Photo";
    } else if (message.contains(".gif")) {
      return "🎬 GIF";
    } else {
      return message;
    }
  }
}
