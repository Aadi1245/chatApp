import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getAccessToken() async {
    final scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "chatup-9c474",
          "private_key_id": "f28b496929eaefd1b07f00efb0a60f124f30825a",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDB6Mm2MvDOR3c0\nKtCoSt+Ivz+s2GgolfwP/QNzhdayy+oK90UgSX607WiXZpvbYn407auab7usGSK4\nBlGZszS3ATdXlhpmo6B9acc/QTHwtIpDyHV5ME7ejRB8xgu0IrFVr619Np+LNPi0\nZq81JE5OhENgBNyY8JeBAfdZLUMLySJ541SBuObhauwmhvZQbfVaIoGFTjUU46Cd\nZ2Ok+KdVM9DnKkIphWXCeHhENQW7P0Cd3XpaEv7Z624miH6v4YiAoEXLFY5o69PL\nhDaUrCKFyPTA7fSYj3GLvgIfi0UgDyyAxWEhVdp8ta1K4Na+oGnDN2U24jTJYGAk\n/RbAT9/NAgMBAAECggEAX4OEdEBEWD9giqw6SmNTFz8pJMEWEUPLvK5iuFEpL7n8\nxzkEbkJ1bLZyaf0rcVVjGDwn5nL6DOv2q5HFOQHKSgiJ05VG3N7la1EiyVgaOtgb\nMQc5QiAXAU2X3PYKhsj989iMitxQmxfVF7tquzDud4Nz0oSiip0b63pl9aGzYEZv\nsoyA7rvuKaXFt8vz27Lj0eh2jb8pPPNK945hgPB77AJayvUcP9HXQA2QZ5NVT6Yt\nqTG1MVmlpZnKIAYxvmYYroBUKE+kG43QPJzO0LvOhPZiPF/Hk8zKAIaqvmMaAK4U\nUIy+JYy8iiHSaDiu/04/GxOaz/uz2HL8fEe3hG1xqwKBgQDi60HbC2bi35DMQW5w\nq50Ca1OOGYJCpTQWUL4DZrRsuFj5ESjqCJwG8MjXAkLAKQnVvqwTjEOZCFtgtvuE\ncl5Yb+waxUjKWc4Wc378fhOguahHhs53MatMXFHKX6TJL8HvNMn5KjCDawNtyxLA\nrTBQFrLBLp1bDr6Jhsq2+8ThjwKBgQDawo1qQg6mKwjHfPFRU6sGwpI/yJ1MKX2u\n+FcxxP1OU8yfLgsm/kyi9+tRM2N3BTB0Y57+kYSPYgtSgXFXq25IczB4Jac8lM4E\nwps/bc/AQwCwQBkreltl1YIigxKZ1mCKq85/5IC3MEnMbl6jCT98Et46wvt6Mjq8\n4tz0g5tC4wKBgQCD/EBezt/2IAFRvNEm+bqmWJTN9ypb50lHnYkX41oYTpV5sTBy\nB7XxF4ZKAQegS35r866U5CXBUioMNAJRhFA58keLPqra/6cuSdlXtWFnP/WQPOnE\nTICNNrlgE4d+eae8oaDEq3RyTAE/kDmFFncebkVktd9Swl2zElLAYeqfIwKBgQCH\nFljpYv1U04JKXfdO91HHjONvC91GqOB56dU+YJzjf4/+RBqS67o7cMkZjZhAaS3w\n0YvfO9EWEb9YJaLuNmiVyLwHlYjeOi22ds4TryX5XebQ7+QbGyXRjrUbxsD3ypA3\nUbzk8SAi/2izGvzJxO41GhmtQ7azUM1A0v8K5zI7bQKBgFpvsfPRRUmZo+CjTz6u\nolkyVMWWUNRxtZmTnuvJH8LxHYpzCsuVd1K1dmogTgUFgPOqVhwYqWqSfkKO/z3j\nid/yygTTYquGo9gDnwjlBIHXbMY6j4maoEjeIkrqSSqDwUsuV7Ez8MvAE4K7HYdD\nCYQim/Y5QfuSMKrGLDOWa08M\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-fbsvc@chatup-9c474.iam.gserviceaccount.com",
          "client_id": "108227302146022101333",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40chatup-9c474.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
