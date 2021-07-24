import 'package:http/http.dart' as http;
import 'dart:convert';

class Session {
  static String accessToken = '';

  void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      int index2 = rawCookie.indexOf('=') + 1;
      accessToken =
          (index == -1) ? rawCookie : rawCookie.substring(index2, index);
      // print(accessToken);
    }
  }
}
