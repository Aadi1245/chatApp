import 'package:chattest/Services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataBasemethods {
  Future addUser(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .doc(id)
        .set(userInfoMap);
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    print("message Id -----<><><><><><><><>>>${messageId}");
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chat")
        .doc(messageId)
        .set(messageInfoMap);
  }

  Future deleteMessage(String chatRoomId, String messageId) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chat")
        .doc(messageId)
        .delete();
  }

  Future<void> deleteAllMessages(String chatRoomId) async {
    final batch = FirebaseFirestore.instance.batch();

    QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chat")
        .get();

    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> deleteSelectedMessages(
      String chatRoomId, List<String> messageIds) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String messageId in messageIds) {
      DocumentReference messageRef = FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId)
          .collection("chat")
          .doc(messageId);
      batch.delete(messageRef);
    }
    print("Message deleted successfully--------->>>>");
    await batch.commit();
  }

  updateLastMessageSent(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  Future<QuerySnapshot> search(String userName) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .where("SearchKey", isEqualTo: userName.substring(0, 1).toUpperCase())
        .get();
  }

  creatChatRoom(String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    print("------------<><><><><>${chatRoomId}");
    final snapshot = await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .get();
    if (snapshot.exists) {
      print("true hai==========");
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessage(chatRoomId) async {
    print("${chatRoomId}===============>>>>");
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chat")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    // await deleteAllMessages(chatRoomId);
    await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .delete();
  }

  Future<QuerySnapshot> getUserInfo(String userName) async {
    return FirebaseFirestore.instance
        .collection("user")
        .where("username", isEqualTo: userName)
        .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUserName = await SharedPreferenceHelper().getUserName();
    print("under chatrooms call-------->>>>${myUserName}");
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .orderBy("time", descending: true)
        .where("user", arrayContains: myUserName!)
        .snapshots();
  }
}
