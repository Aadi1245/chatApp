import 'package:chattest/pages/chat/stream_video_services.dart';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class VideoCallPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userToken;
  final String callId;

  const VideoCallPage({
    required this.userId,
    required this.userName,
    required this.userToken,
    required this.callId,
    super.key,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  Call? call;

  @override
  void initState() {
    super.initState();
    initializeCall();
  }

  Future<void> initializeCall() async {
    await StreamVideoService().init(
      apiKey: 'vxeyjhp4548f',
      userId: widget.userId,
      userName: widget.userName,
      userToken: widget.userToken,
    );

    final activeCall = await StreamVideoService().startCall(
      callId: widget.callId,
    );

    setState(() {
      call = activeCall;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (call == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: StreamCallContainer(
        call: call!,
        callContentBuilder: (context, call, callState) {
          return StreamCallContent(
            call: call,
            callState: callState,
            callControlsBuilder: (context, call, callState) {
              return StreamCallControls(
                options: [
                  LeaveCallOption(
                    call: call,
                    onLeaveCallTap: () async {
                      await StreamVideoService().leaveCall();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
