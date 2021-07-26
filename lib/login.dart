import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'session.dart';
import 'dart:io';

// void main() {
//   runApp(Login());
// }

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
      ),
      body: LoginInputs(),
    );
  }
}

class LoginInputs extends StatefulWidget {
  LoginInputs({Key key}) : super(key: key);

  @override
  _LoginInputsState createState() => _LoginInputsState();
}

class _LoginInputsState extends State<LoginInputs> {
  final loginIdContoller = TextEditingController();
  final loginPwContoller = TextEditingController();

  Future userLogin() async {
    //var url_login =    'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/login';

    var url_login = 'http://10.0.2.2:52324/login'; //자기 포트 번호 직접 입력

    String user_id = loginIdContoller.text;
    String user_pw = loginPwContoller.text;
    Map<String, String> data = {
      'id': user_id,
      'pw': user_pw,
    };

    // get
    var response_get = await Session().get(url_login);

    var getHeaders = response_get.headers;
    var getBody = utf8.decode(response_get.bodyBytes);

    Session.salt = Session().updateCookie(response_get, 'salt');

    print('salt: ${Session.salt}');

    crypto();

    //post
    var response_post = await Session().post(url_login, data);
    // var statusCode = response.statusCode;
    var postHeaders = response_post.headers;
    var postBody = utf8.decode(response_post.bodyBytes);

    print(response_post.headers);
    // var responseBody = response.bodyBytes;

    // print('status code: $statusCode');
    print('body: $postBody');
    // print('postHeader: $postHeaders');

    Session.session = Session().updateCookie(response_post, 'connect.sid');

    // print(Session.accessToken);
    if (Session.session != '') {
      // Navigator.popAndPushNamed(context, '/mainPage');
      // Navigator.pushNamed(context, '/mainPage');
    }

    // return response;
  }

  String pwCrypto(String id, String pw) {
    var pwSalt = pw + id;
    var cryptedPw = sha512.convert(utf8.encode(pwSalt)).toString();

    for (int i = 0; i < 1000; i++) {
      cryptedPw = sha512.convert(utf8.encode(cryptedPw + id)).toString();
    }

    return cryptedPw;
  }

  bool crypto() {
    var salt = Session.salt;
    salt = Uri.decodeFull(salt);

    var pwSalt = pwCrypto(loginIdContoller.text, loginPwContoller.text) + salt;

    var cryptedPw = sha512.convert(utf8.encode(pwSalt)).toString();

    for (int i = 0; i < 1000; i++) {
      cryptedPw = sha512.convert(utf8.encode(cryptedPw + salt)).toString();
    }

    loginPwContoller.text = cryptedPw;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
            child: Column(
          children: [
            Text('아이디를 입력하세요'),
            Container(
              height: 10,
            ),
            TextFormField(
              controller: loginIdContoller,
              textAlign: TextAlign.center,
              decoration:
                  InputDecoration(border: OutlineInputBorder(), hintText: 'ID'),
            ),
          ],
        )),
        Container(
          child: Column(
            children: [
              Text('비밀번호를 입력하세요'),
              Container(
                height: 10,
              ),
              TextFormField(
                controller: loginPwContoller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'PW'),
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                  onPressed: () {
                    userLogin();
                  },
                  child: Text('LOGIN')),
              OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signUp');
                  },
                  child: Text('SIGN UP'))
            ],
          ),
        )
      ],
    ));
  }
}
