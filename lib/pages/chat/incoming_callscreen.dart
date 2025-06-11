import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:chattest/pages/chat/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:stream_video/protobuf/video/sfu/models/models.pb.dart';

class IncomingCallScreen extends StatelessWidget {
  final Call call;

  const IncomingCallScreen({Key? key, required this.call}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("📞 Incoming Call",
                style: TextStyle(fontSize: 24, color: Colors.white)),
            SizedBox(height: 16),
            Text("Call ID: ${call.id}",
                style: TextStyle(color: Colors.white70)),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.call),
                  label: Text("Accept"),
                  onPressed: () async {
                    await call.call().join();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(call: call.call()),
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.call_end),
                  label: Text("Decline"),
                  onPressed: () {
                    call.call().end(); // Optionally reject
                    Navigator.pop(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
