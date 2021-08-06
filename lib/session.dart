import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'login.dart';
import 'getXController.dart';
import 'crypt.dart';

class Session extends GetConnect {
  final box = GetStorage();
  final notiController = Get.put(NotiController());
  final loginController = LoginController();
  static Map<String, String> headers = {
    'User-Agent': 'PolarStar',
    'polar': 'star',
    'Cookie': '',
  };
  static Map<String, String> cookies = {};

  static String session;
  static String salt;

  final String _basicUrl =
      'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000';

  reLogin() async {
    String id = await box.read('id');
    String pw = await box.read('pw');

    print('relogin...');

    Map<String, String> data = {
      'id': id,
      'pw': pw,
      'token': notiController.tokenFCM.value,
    };

    Session().getX('/login').then((value) {
      switch (value.statusCode) {
        case 200: // 정상
          Session.salt = Session().updateCookie(value, 'salt');
          data['pw'] = crypto_login(id, pw);
          Session().postX('/login', data).then((value) async {
            switch (value.statusCode) {
              case 200:
                Session.session = Session().updateCookie(value, 'connect.sid');

                break;
              default:
            }
          });

          break;
        case 401:
          break;
        default:
      }
    });
  }

  Future<http.Response> getX(String url) =>
      http.get(Uri.parse(_basicUrl + url), headers: headers).then((value) {
        switch (value.statusCode) {
          case 401: // login error
            Get.toNamed("/login");
            // reLogin()
            //     .then(http.get(Uri.parse(_basicUrl + url), headers: headers));

            return value;
          default:
            return value;
        }
      });

  Future<http.Response> postX(String url, Map data) => http
          .post(
        Uri.parse(_basicUrl + url),
        body: data,
        headers: headers,
      )
          .then((value) {
        switch (value.statusCode) {
          case 401: // login error
            Get.toNamed("/login");
            // reLogin().then(http.post(
            //   Uri.parse(_basicUrl + url),
            //   body: data,
            //   headers: headers,
            // ));
            return value;
          default:
            return value;
        }
      });

  Future putX(String url, Map data) => put(
        _basicUrl + url,
        data,
        headers: headers,
      ).then((value) {
        switch (value.statusCode) {
          case 401:
            // Get.toNamed("/login");
            reLogin();
            return value;
          default:
            return value;
        }
      });
  Future<http.Response> patchX(String url, Map data) => http
          .patch(
        Uri.parse(_basicUrl + url),
        body: data,
        headers: headers,
      )
          .then((value) {
        switch (value.statusCode) {
          case 401:
            Get.toNamed("/login");
            return value;
          default:
            return value;
        }
      });

  Future deleteX(String url) =>
      delete(_basicUrl + url, headers: headers).then((value) {
        switch (value.statusCode) {
          case 401:
            Get.toNamed("/login");
            return value;
          default:
            return value;
        }
      });

  // 왜 안되는지 모르겠음
  // Future<Response> getQuery(String url, Map query) => get(
  //     'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000$url',
  //     query: query,
  //     headers: headers);

  multipartReq(String type, String url) {
    var request = http.MultipartRequest(
        type,
        Uri.parse(
            'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000$url'));

    request.headers['User-Agent'] = headers['User-Agent'];
    request.headers['polar'] = headers['polar'];
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

      print(headers['Cookie']);

      return cookies[str];
    }
  }
}
