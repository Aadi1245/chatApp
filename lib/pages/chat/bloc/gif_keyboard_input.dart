import 'package:flutter/services.dart';

class GifKeyboardInput {
  static const platform = MethodChannel('com.example.gif/input');

  static Future<void> startListening() async {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onGifReceived") {
        final String gifUri = call.arguments;
        // Use gifUri to upload to Supabase and send to Firebase
        print("gifurl of nativ code --------->>>>${gifUri}");
      }
    });
  }
}
