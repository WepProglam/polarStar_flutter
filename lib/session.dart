import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Session extends GetConnect {
  static Map<String, String> headers = {
    'User-Agent': 'PolarStar',
    'Cookie': ''
  }; //다른 핸드폰으로 보면 정상적으로 화면 띄우려고 바꿈
  static Map<String, String> cookies = {};

  static String session = '';
  static String salt = '';

  Future<http.Response> getX(String url) =>
      http.get(Uri.parse(url), headers: headers);
  Future<http.Response> postX(String url, Map data) =>
      http.post(Uri.parse(url), body: data);
  GetSocket socketX(String url) {
    return socket(url);
  }

  Future<dynamic> getN(String url) async {
    http.Response response = await http.get(Uri.parse(url), headers: headers);

    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      //코드 입력
    }

    return response;
  }

  Future<dynamic> postN(String url, dynamic data) async {
    http.Response response =
        await http.post(Uri.parse(url), body: data, headers: headers);

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
      String strCookies = cookies.toString();
      int len = strCookies.length - 1;
      headers['Cookie'] = cookies
          .toString()
          .substring(1, len)
          .replaceAll(RegExp(r': '), '=')
          .replaceAll(RegExp(r','), ';');

      // print(headers['Cookie']);

      return cookies[str];
    }
  }
}
