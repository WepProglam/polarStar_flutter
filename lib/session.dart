import 'package:http/http.dart' as http;
import 'dart:convert';

class Session {
  Map<String, String> headers = {'User-Agent': 'Mobi'};

  Map<String, String> cookies = {};

  static String session = '';
  static String salt = '';

  Future<dynamic> get(String url) async {
    http.Response response = await http.get(Uri.parse(url), headers: headers);

    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      //코드 입력
    }

    return response;
  }

  Future<dynamic> post(String url, dynamic data) async {
    http.Response response = await http.post(Uri.parse(url),
        body: json.encode(data), headers: headers);

    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      //코드 입력

    }
    return response;
  }

  String updateCookie(http.Response response, String str) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      int index2 = rawCookie.indexOf('=') + 1;
      cookies[str] =
          (index == -1) ? rawCookie : rawCookie.substring(index2, index);
      // print(accessToken);
      return cookies[str];
    }
  }
}
