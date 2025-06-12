import 'package:chattest/pages/chat/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class IncomingCallScreen extends StatelessWidget {
  final Call call;

  const IncomingCallScreen({super.key, required this.call});

  void _acceptCall(BuildContext context) async {
    await call.accept();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => CallScreen(call: call)),
    );
  }

  void _rejectCall(BuildContext context) async {
    await call.reject();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final callState = call.state.value;
    final callerId =
        callState.callParticipants.firstWhere((p) => !p.isLocal).userId;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("📞 Incoming call from: $callerId",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.call),
              label: const Text("Accept"),
              onPressed: () => _acceptCall(context),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.call_end),
              label: const Text("Reject"),
              onPressed: () => _rejectCall(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
