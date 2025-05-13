import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chattest/Services/database.dart';
import 'package:meta/meta.dart';

import '../../../Services/shared_pref.dart';

part 'chatbloc_event.dart';
part 'chatbloc_state.dart';

class ChatblocBloc extends Bloc<ChatblocEvent, ChatblocState> {
  String userName, profileUrl, name;

  String? myUserName, myName, myEmail, myPicture, chatRoomId, messageId;
  Stream? messageStream;
  ChatblocBloc({
    required this.name,
    required this.profileUrl,
    required this.userName,
  }) : super(ChatblocInitial()) {
    getTheSharedpreferenceData();
  }

  getTheSharedpreferenceData() async {
    emit(ChatBlocLoadingState());
    myUserName = await SharedPreferenceHelper().getUserName();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();
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
}
