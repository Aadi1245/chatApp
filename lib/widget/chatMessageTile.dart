import 'dart:async';

import 'package:chattest/pages/chat/audio_record.dart';
import 'package:chattest/widget/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:permission_handler/permission_handler.dart';

class Chatmessagetile extends StatefulWidget {
  Function()? showReply;
  Chatmessagetile(
    this.senderProfilePic,
    this.message,
    this.sendByMe,
    this.Data,
    this.isSelected, {
    this.isplaying = false,
    this.showReply,
    this.replyMessage,
  });
  String senderProfilePic;
  String message;
  bool sendByMe;
  String Data;
  bool isSelected;
  bool isplaying;
  String? replyMessage;

  @override
  State<Chatmessagetile> createState() => _ChatmessagetileState();
}

class _ChatmessagetileState extends State<Chatmessagetile>
    with SingleTickerProviderStateMixin {
  Duration _position = Duration.zero;

  Duration _duration = Duration.zero;
  StreamSubscription? _progressSubscription;

  bool isRecording = false;

  // late AudioRecord _audioRecorder;
  // bool _permissionGranted = false;

  FlutterSoundPlayer? _player;

  Future<void> _initPlayer() async {
    await _player!.openPlayer();
  }

  @override
  void dispose() {
    // _audioRecorder.dispose();
    _player!.stopPlayer();
    _progressSubscription?.cancel();
    _player?.closePlayer();

    _player = null;
    super.dispose();
  }

  double _dragOffset = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    _player = FlutterSoundPlayer();
    _initPlayer();
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  // Widget audioProfileWithMic(String imageUrl) {
  //   return Stack(
  //     children: [
  //       ClipRRect(
  //         borderRadius: BorderRadius.circular(25), // half of 50 for circle
  //         child: Image.network(
  //           imageUrl,
  //           height: 50,
  //           width: 50,
  //           fit: BoxFit.cover,
  //         ),
  //       ),
  //       Positioned(
  //         top: 35,
  //         left: 35,
  //         bottom: 0,
  //         right: 0,
  //         child: Icon(
  //           Icons.mic,
  //           size: 18,
  //           color: Colors.grey,
  //         ),
  //         // ),
  //       ),
  //     ],
  //   );
  // }

  void _animateBack() {
    _animation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          _dragOffset = _animation.value;
        });
      });

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color:
          widget.isSelected ? Color.fromARGB(109, 127, 228, 235) : Colors.white,
      child: Row(
        mainAxisAlignment:
            widget.sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragOffset += details.delta.dx;

                    // Allow drag only in valid direction
                    if (widget.sendByMe) {
                      // Sent by me -> allow left swipe only
                      widget.showReply!();
                      if (_dragOffset > 0) _dragOffset = 0;
                    } else {
                      // Received -> allow right swipe only
                      if (_dragOffset < 0) _dragOffset = 0;
                      print("allow right swipe only--------->>");
                      // print("message kya 2222 }----->>>>");
                      widget.showReply!();
                    }
                  });
                },
                onHorizontalDragEnd: (details) {
                  final swipeThreshold = 100;
                  if (widget.sendByMe &&
                      _dragOffset.abs() > swipeThreshold &&
                      _dragOffset < 0) {
                    // Swiped left
                    print("Swiped left (sent by me) — trigger reply");
                    // widget.onSwipeLeft(); // optional
                  } else if (!widget.sendByMe && _dragOffset > swipeThreshold) {
                    // Swiped right
                    print("Swiped right (received) — trigger reply");
                    // widget.onSwipeRight(); // optional
                  }
                  _animateBack(); // Snap back to position
                },
                child: Transform.translate(
                    offset: Offset(_dragOffset, 0),
                    child: Container(
                      padding: widget.Data == "Image" || widget.Data == "GIF"
                          ? EdgeInsets.all(5)
                          : widget.Data == "Audio"
                              ? EdgeInsets.all(5)
                              : EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: widget.sendByMe
                              ? Radius.circular(15)
                              : Radius.circular(0),
                          bottomRight: widget.sendByMe
                              ? Radius.circular(0)
                              : Radius.circular(15),
                        ),
                        color: widget.sendByMe
                            ? Color.fromARGB(255, 197, 223, 222)
                            : Colors.blue.shade100,
                      ),
                      child: widget.Data == "Image" || widget.Data == "GIF"
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.message,
                                height: widget.Data == "GIF" ? 250 : 200,
                                width: widget.Data == "GIF" ? 250 : 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.Data == "Audio"
                              ? Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: widget.sendByMe
                                        ? const Color.fromARGB(
                                            255, 197, 223, 222)
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      widget.sendByMe
                                          ? CommonWidgets.audioProfileWithMic(
                                              widget.senderProfilePic)
                                          : Container(),
                                      IconButton(
                                        icon: Icon(
                                          size: 35,
                                          widget.isplaying!
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          if (widget.isplaying) {
                                            await _player!.stopPlayer();
                                            await _progressSubscription
                                                ?.cancel();
                                            setState(() {
                                              widget.isplaying = false;
                                              _position = Duration.zero;
                                              _duration = Duration.zero;
                                            });
                                          } else {
                                            await _player!.startPlayer(
                                              fromURI: widget.message,
                                              whenFinished: () async {
                                                await _progressSubscription
                                                    ?.cancel();
                                                setState(() {
                                                  widget.isplaying = false;
                                                  _position = Duration.zero;
                                                  _duration = Duration.zero;
                                                });
                                              },
                                            );

                                            _progressSubscription = _player!
                                                .onProgress!
                                                .listen((event) {
                                              if (event != null && mounted) {
                                                setState(() {
                                                  _position = event.position;
                                                  _duration = event.duration;
                                                });
                                              }
                                            });

                                            setState(() {
                                              widget.isplaying = true;
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
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.blue),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      widget.sendByMe
                                          ? Container()
                                          : CommonWidgets.audioProfileWithMic(
                                              widget.senderProfilePic),
                                    ],
                                  ),
                                )
                              : widget.Data == "replyMessage"
                                  ? Container(
                                      margin: EdgeInsets.only(bottom: 6),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        border: Border(
                                          left: BorderSide(
                                            color: Colors
                                                .blue, // a colored line to indicate reply
                                            width: 4,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      constraints:
                                          BoxConstraints(maxWidth: 250),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          widget.replyMessage!.contains(".aac")
                                              ? CommonWidgets.audioReplyMessage(
                                                  widget.replyMessage!)
                                              : widget.replyMessage!
                                                      .contains(".jpg")
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // half of 50 for circle
                                                      child: Image.network(
                                                        widget.replyMessage!,
                                                        height: 50,
                                                        width: 50,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : widget.replyMessage!
                                                          .contains(".gif")
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10), // half of 50 for circle
                                                          child: Image.network(
                                                            widget
                                                                .replyMessage!,
                                                            height: 50,
                                                            width: 50,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                      : Text(
                                                          widget.Data ==
                                                                  "replyMessage"
                                                              ? widget
                                                                  .replyMessage!
                                                              : "",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                        ),
                                          SizedBox(height: 2),
                                          Text(
                                            widget.message,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    )
                                  :

                                  // ACTUAL MESSAGE
                                  Text(
                                      widget.message,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                    ))),
          )
        ],
      ),
    );
  }
}
