import 'dart:async';

import 'package:chattest/pages/chat/audio_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:permission_handler/permission_handler.dart';

class Chatmessagetile extends StatefulWidget {
  Chatmessagetile(this.senderProfilePic, this.message, this.sendByMe, this.Data,
      this.isSelected,
      {this.isplaying = false});
  String senderProfilePic;
  String message;
  bool sendByMe;
  String Data;
  bool isSelected;
  bool isplaying;

  @override
  State<Chatmessagetile> createState() => _ChatmessagetileState();
}

class _ChatmessagetileState extends State<Chatmessagetile> {
  Duration _position = Duration.zero;

  Duration _duration = Duration.zero;
  StreamSubscription? _progressSubscription;

  bool isRecording = false;

  late AudioRecord _audioRecorder;
  bool _permissionGranted = false;

  FlutterSoundPlayer? _player;

  Future<void> _initPlayer() async {
    await _player!.openPlayer();
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

  @override
  void initState() {
    // TODO: implement initState
    _player = FlutterSoundPlayer();
    _initPlayer();
    super.initState();
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
            child: Stack(
              children: [
                Container(
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
                              decoration: BoxDecoration(
                                // color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  widget.sendByMe
                                      ? audioProfileWithMic(
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
                                        await _progressSubscription?.cancel();
                                        setState(() {
                                          widget.isplaying = false;
                                          _position = Duration.zero;
                                          _duration = Duration.zero;
                                        });
                                      } else {
                                        await _player!.startPlayer(
                                          fromURI: widget.message,
                                          // codec: Codec.aacADTS,
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

                                              print(
                                                  "time------------->>>>>${_duration.inMilliseconds}");
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
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.blue),
                                  )),
                                  const SizedBox(width: 8),
                                  widget.sendByMe
                                      ? Container()
                                      : audioProfileWithMic(
                                          widget.senderProfilePic)
                                ],
                              ),
                            )
                          : Text(
                              widget.message,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                ),
                Positioned(
                  top: -3,
                  right: 1,
                  left: null,
                  child: widget.sendByMe
                      ? Container()
                      : PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (String value) {
                            if (value == "Reply") {
                              // handle reply
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                                height: 20,
                                value: "Reply",
                                child: Text("Reply")),
                          ],
                          icon: Icon(Icons.more_vert,
                              color: Colors.grey[700], size: 20),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
