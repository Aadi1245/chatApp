import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:chattest/views/chat/call_screen.dart';
import 'package:chattest/views/chat/incoming_callscreen.dart';

class CallService {
  static final CallService _instance = CallService._internal();

  factory CallService() => _instance;

  CallService._internal();

  late final StreamVideo _client;
  StreamVideo get streamClient => _client;

  StreamSubscription<Call>? _incomingCallSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  void setClient(StreamVideo client) {
    print("----------------->>>>>>>>>>Client set successfully");
    _client = client;
  }

  /// Initializes incoming call listener
  void init(GlobalKey<NavigatorState> navigatorKey) {
    print("----------------->>>>>>>>>>init() call successfully");
    _navigatorKey = navigatorKey;

    _incomingCallSubscription?.cancel();

    _incomingCallSubscription =
        _client.state.incomingCall.listen((incomingCall) {
      debugPrint('📞 Incoming call: ${incomingCall.id}');

      final call = _client.makeCall(
        callType: incomingCall.type,
        id: incomingCall.id,
      );

      _navigatorKey?.currentState?.push(
        MaterialPageRoute(
          builder: (_) => IncomingCallScreen(call: call),
        ),
      );
    });
  }

  /// Starts an outgoing call
  Future<void> startCall({
    required BuildContext context,
    required String callId,
    required String calleeUserId,
  }) async {
    print("----------------->>>>>>>>>>Startcall called successfully");
    final call = _client.makeCall(
      callType: StreamCallType(), // default video + audio call
      id: callId,
    );

    await call.getOrCreate(
      memberIds: [calleeUserId],
      ringing: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CallScreen(call: call)),
    );
  }

  /// Dispose listener
  void dispose() {
    _incomingCallSubscription?.cancel();
    _incomingCallSubscription = null;
    _navigatorKey = null;
  }
}
