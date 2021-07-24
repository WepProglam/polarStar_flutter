import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'session.dart';

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
    var url =
        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/login';
    var url2 =
        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/board/1/page/1';

    String user_id = loginIdContoller.text;
    String user_pw = loginPwContoller.text;

    var data = {'id': user_id, 'pw': user_pw};

    var response = await http.post(Uri.parse(url), body: data);
    // var response = await http.get(Uri.parse(url2));

    // var statusCode = response.statusCode;
    // var responseHeaders = response.headers;
    // var responseBody = utf8.decode(response.bodyBytes);

    // print('status code: $statusCode');
    // print('body: $responseBody');
    // print('header: $responseHeaders');
    // print('cookie: ${responseHeaders['set-cookie']}');

    Session().updateCookie(response);

    print(Session.accessToken);
    if (Session.accessToken != '') {
      Navigator.popAndPushNamed(context, '/mainPage');
    }

    // return response;
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
