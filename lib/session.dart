import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Session extends GetConnect {
  static Map<String, String> headers = {
    'User-Agent': 'PolarStar',
    'Cookie': '',
  };
  static Map<String, String> cookies = {};

  static String session;
  static String salt;

  Future<http.Response> getX(String url) => http
          .get(
              Uri.parse(
                  'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000$url'),
              headers: headers)
          .then((value) {
        switch (value.statusCode) {
          case 403:
            getX('/logout');
            Get.offAllNamed('/logout');
            break;
          default:
            return value;
        }
        return value;
      });
  Future<http.Response> postX(String url, Map data) => http.post(
      Uri.parse(
          'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000$url'),
      body: data,
      headers: headers);

  multipartReq(String url) {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000$url'));

    request.headers['user-agent'] = headers['user-agent'];
    request.headers['Cookie'] = headers['Cookie'];

    return request;
  }

  GetSocket socketX(String url) {
    return socket(
        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000$url');
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
