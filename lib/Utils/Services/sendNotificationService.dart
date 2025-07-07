import 'dart:convert';

// import 'package:chattest/Services/get_server_key.dart';
import 'package:chattest/Utils/Services/get_server_key.dart';
import 'package:dio/dio.dart';

class Sendnotificationservice {
  static Future<void> sendNotificationWithApi(
      {required String? token,
      required String? title,
      required String? body,
      required Map<String, dynamic>? data1}) async {
    print(" sendNotificationWithApi called  ------------>>>>>>> ");
    String serverKey = await GetServerKey().getAccessToken();

    var headers = {
      'Authorization': 'Bearer ' + serverKey,
      'Content-Type': 'application/json'
    };
    var data = json.encode({
      "message": {
        "token":
            "faNjuQSyRVGgUpdOdte2d0:APA91bGRHzKAeTDEt9xOR5JwF7c4kZ2e8htYV2cqJHGyQwTlQ7lPY_CMvYYGI4p62IkdM7MT-KEBkW7_jEkJ929H0DV425JfSfDvb27EPze5pFrxjsJ42Hk",
        "notification": {
          "body": body,
          "title": title,
        },
        "data": data1,
      }
    });
    var dio = Dio();
    var response = await dio.request(
      'https://fcm.googleapis.com/v1/projects/chatup-9c474/messages:send',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print(
          "Notification sent successfully----${token}----->>>>>>>>>> ${json.encode(response.data)}");
    } else {
      print(" Api Failed ------------>>>>>>> ${response.statusMessage}");
    }
  }
}
