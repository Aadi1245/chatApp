import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userImageKey = "USERIMAGEKEY";
  static String userUserNameKey = "USERURESNAMEKEY";
  static String accessToken = "ACCESSTOKEN";

  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserDisplayName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserImage(String getUserImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userImageKey, getUserImage);
  }

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userUserNameKey, getUserName);
  }

  Future<bool> saveAccessToken(String getAccesstoken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(accessToken, getAccesstoken);
  }

  Future<bool> saveStreamToken(String getAccesstoken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(accessToken, getAccesstoken);
  }

  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessToken);
  }

  Future<String?> getStreamToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessToken);
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userUserNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userImageKey);
  }
}
