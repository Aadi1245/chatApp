abstract class ChatblocEvent {}

class deleteSelectedMsg extends ChatblocEvent {
  List<String>? messageIds;
  deleteSelectedMsg(this.messageIds);
}

class ClearChat extends ChatblocEvent {
  ClearChat();
}
