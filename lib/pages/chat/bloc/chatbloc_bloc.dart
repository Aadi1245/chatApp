import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chattest/Services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';
import 'package:record/record.dart';

import '../../../Services/shared_pref.dart';

part 'chatbloc_event.dart';
part 'chatbloc_state.dart';

class ChatblocBloc extends Bloc<ChatblocEvent, ChatblocState> {
  String userName, profileUrl, name;

  String? myUserName,
      myName,
      myEmail,
      myPicture,
      fcmToken,
      chatRoomId,
      messageId;
  Stream? messageStream;
  String apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91aWlpYm54cWlvZWR2bHdmYndsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcxMjgyNDksImV4cCI6MjA2MjcwNDI0OX0.aEDqtb7nzWayG0XnyE_I7etCe84c2fK5oKWKLb4FKSw';
  String authorization =
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91aWlpYm54cWlvZWR2bHdmYndsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcxMjgyNDksImV4cCI6MjA2MjcwNDI0OX0.aEDqtb7nzWayG0XnyE_I7etCe84c2fK5oKWKLb4FKSw';
  String baseUrl =
      "https://ouiiibnxqioedvlwfbwl.supabase.co/storage/v1/object/public/";
  String mainUrl = "";
  ChatblocBloc({
    required this.name,
    required this.profileUrl,
    required this.userName,
  }) : super(ChatblocInitial()) {
    on<deleteSelectedMsg>((event, State) async {
      // emit(ChatBlocLoadingState());
      await DataBasemethods()
          .deleteSelectedMessages(chatRoomId!, event.messageIds!);
      emit(ChatBlocLoadedState());
    });

    on<ClearChat>(
      (event, emit) async {
        emit(ChatBlocLoadingState());
        await DataBasemethods().deleteAllMessages(chatRoomId!);
        emit(ChatBlocLoadedState());
      },
    );

    getTheSharedpreferenceData();
  }

  getTheSharedpreferenceData() async {
    emit(ChatBlocLoadingState());
    myUserName = await SharedPreferenceHelper().getUserName();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();
    fcmToken = await SharedPreferenceHelper().getAccessToken();
    chatRoomId = getChatRoomIdByUserName(myUserName!, userName);
    print("chatpage shared chatroomid --- ${chatRoomId}");
    getAndSetMessage();
  }

  String getChatRoomIdByUserName(String a, String b) {
    List<String> users = [a.toLowerCase(), b.toLowerCase()]..sort();
    return "${users[0]}_${users[1]}";
  }

  getAndSetMessage() async {
    print("${chatRoomId}chat page===========");
    emit(ChatBlocLoadingState());
    messageStream = await DataBasemethods().getChatRoomMessage(chatRoomId);
    if (messageStream == null) {
      emit(ChatBlocFailedState());
    } else {
      emit(ChatBlocLoadedState());
    }
    print("${messageStream!.first}chat page after ===========");
  }

  Future<void> uploadImage(BuildContext context, String myUserName,
      String myPicture, String chatRoomId, File selectedImage) async {
    Fluttertoast.showToast(
      msg: "Your image is uploading please wait...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 12.0,
    );
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     backgroundColor: Colors.red,
    //     content: Text(
    //       "Your image is uploading please wait...",
    //       style: TextStyle(fontSize: 20),
    //     )));

    try {
      String addId = randomAlphaNumeric(5);

      var headers = {
        'apikey': apiKey,
        'Authorization': authorization,
        'Content-Type': 'image/jpeg'
      };
      var data = FormData.fromMap({
        'files': [await MultipartFile.fromFile(selectedImage.path)],
      });

      print("data that is provided <><><><><><> ${data}");

      var dio = Dio();
      var response = await dio.request(
        'https://ouiiibnxqioedvlwfbwl.supabase.co/storage/v1/object/my-storage/${myUserName}/${myUserName}${addId}.jpg',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print("-----response data-------${json.encode(response.data["Key"])}");
        mainUrl = json.encode(response.data["Key"]).replaceAll('"', '');
      } else {
        print("----------Api Failed-------${response.statusMessage}");
      }
      // Reference firebaseStorageRef =
      //     FirebaseStorage.instance.ref().child("blogImage").child(addId);
      // final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downloadUrl = baseUrl + mainUrl;
      print("downloaded url -------->>>>${downloadUrl}");
      DateTime now = DateTime.now();
      String formattedDate = DateFormat("h:mma").format(now);
      Map<String, dynamic> messageInfoMap = {
        "Data": "Image",
        "message": downloadUrl,
        "sendBy": myUserName, // myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgurl": myPicture //myPicture
      };
      messageId = randomAlphaNumeric(10);
      await DataBasemethods()
          .addMessage(chatRoomId, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": "Image",
          "lastMessageSendBy": myUserName,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp()
        };
        DataBasemethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);
      });
    } catch (e) {
      print("Image throw excetion====>>${e}");
    }
  }

  Future<void> uploadAudio(String filePath) async {
    String addId = randomAlphaNumeric(5);
    final fileName =
        filePath.split('/').last; // Extracts 'audio_1747323250106.aac'
    final destinationPath = 'user1/$fileName';

    final url =
        'https://ouiiibnxqioedvlwfbwl.supabase.co/storage/v1/object/my-storage/$destinationPath';

    // Initialize Dio
    final dio = Dio();

    try {
      // Create FormData for the file upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      // Make the POST request
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'apikey': apiKey,
            'Authorization': authorization,
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Upload response: ${response.data}');
        // Construct the public URL
        final publicUrl =
            'https://ouiiibnxqioedvlwfbwl.supabase.co/storage/v1/object/my-storage/$destinationPath';

        DateTime now = DateTime.now();
        String formattedDate = DateFormat("h:mma").format(now);
        Map<String, dynamic> messageInfoMap = {
          "Data": "Audio",
          "message": publicUrl,
          "sendBy": myUserName,
          "ts": formattedDate,
          "time": FieldValue.serverTimestamp(),
          "imgurl": myPicture
        };
        messageId = randomAlphaNumeric(10);
        await DataBasemethods()
            .addMessage(chatRoomId!, messageId!, messageInfoMap)
            .then((value) {
          Map<String, dynamic> lastMessageInfoMap = {
            "lastMessage": "Audio",
            "lastMessageSendBy": myUserName,
            "lastMessageSendTs": formattedDate,
            "time": FieldValue.serverTimestamp()
          };
          DataBasemethods()
              .updateLastMessageSent(chatRoomId!, lastMessageInfoMap);
        });
      } else {
        print('Failed to upload: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  // getGifFile(File gifFile) {
  //   uploadGif(myUserName!, myPicture!, chatRoomId!, gifFile,);
  // }

//For GIF upload

  Future<void> uploadGif(String myUserName, String myPicture, String chatRoomId,
      File selectedGif, String fcmToken) async {
    Fluttertoast.showToast(
      msg: "Your GIF is uploading please wait...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 12.0,
    );

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     backgroundColor: Colors.red,
    //     content: Text(
    //       "Your GIF is uploading please wait...",
    //       style: TextStyle(fontSize: 20),
    //     )));

    try {
      String addId = randomAlphaNumeric(5);

      var headers = {
        'apikey': apiKey,
        'Authorization': authorization,
        'Content-Type': 'image/gif'
      };
      var data = FormData.fromMap({
        'files': [await MultipartFile.fromFile(selectedGif.path)],
      });

      print("data that is provided <><><><><><> ${data}");

      var dio = Dio();
      var response = await dio.request(
        'https://ouiiibnxqioedvlwfbwl.supabase.co/storage/v1/object/my-storage/${myUserName}/${myUserName}${addId}.gif',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print("-----response data-------${json.encode(response.data["Key"])}");
        mainUrl = json.encode(response.data["Key"]).replaceAll('"', '');
      } else {
        print("----------Api Failed-------${response.statusMessage}");
      }
      // Reference firebaseStorageRef =
      //     FirebaseStorage.instance.ref().child("blogImage").child(addId);
      // final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downloadGifUrl = baseUrl + mainUrl;
      print("downloaded Gif url -------->>>>${downloadGifUrl}");
      DateTime now = DateTime.now();
      String formattedDate = DateFormat("h:mma").format(now);
      Map<String, dynamic> messageInfoMap = {
        "Data": "GIF",
        "message": downloadGifUrl,
        "sendBy": myUserName, // myUserName,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgurl": myPicture, //myPicture
        "fcmToken": fcmToken
      };
      messageId = randomAlphaNumeric(10);
      await DataBasemethods()
          .addMessage(chatRoomId, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": "GIF",
          "lastMessageSendBy": myUserName,
          "lastMessageSendTs": formattedDate,
          "time": FieldValue.serverTimestamp()
        };
        DataBasemethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);
      });
    } catch (e) {
      print("Image throw excetion====>>${e}");
    }
  }
}
