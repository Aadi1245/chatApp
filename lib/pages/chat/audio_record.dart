import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioRecord {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _filePath;

  AudioRecorder() {
    _recorder = FlutterSoundRecorder();
  }

  Future<void> init() async {
    AudioRecorder();
    await _recorder!.openRecorder();
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    final directory = await getTemporaryDirectory();
    _filePath =
        '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder!.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,
    );
    _isRecording = true;
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    await _recorder!.stopRecorder();
    _isRecording = false;
    return _filePath;
  }

  bool get isRecording => _isRecording;

  Future<void> dispose() async {
    await _recorder!.closeRecorder();
    _recorder = null;
  }
}
