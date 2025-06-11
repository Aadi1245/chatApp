import 'package:stream_video_flutter/stream_video_flutter.dart';

class StreamVideoService {
  static final StreamVideoService _instance = StreamVideoService._internal();
  factory StreamVideoService() => _instance;
  StreamVideoService._internal();

  late StreamVideo _client;
  Call? _currentCall;

  /// Initialize the Stream Video client
  Future<void> init({
    required String apiKey,
    required String userId,
    required String userName,
    required String userToken,
  }) async {
    _client = StreamVideo(
      apiKey,
      user: User.regular(
        userId: userId,
        name: userName,
      ),
      userToken: userToken,
    );
  }

  /// Make or join a call
  Future<Call> startCall({
    required String callId,
    String callType = 'default',
  }) async {
    _currentCall = _client.makeCall(
      callType: StreamCallType(),
      id: callId,
    );
    await _currentCall!.join();
    return _currentCall!;
  }

  /// Get current active call
  Call? get currentCall => _currentCall;

  /// Leave the call
  Future<void> leaveCall() async {
    await _currentCall?.leave();
    _currentCall = null;
  }
}
