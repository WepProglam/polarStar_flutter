import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'crypt.dart';
import 'package:get/get.dart';

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

  // login 함수
  Future userLogin() async {
    Session.cookies = {};
    Session.headers['Cookie'] = '';

    String user_id = loginIdContoller.text;
    String user_pw = loginPwContoller.text;

    Map<String, String> data = {
      'id': user_id,
      'pw': user_pw,
    };

    //var url_login =    'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/login';
    // get
    var response_get = await Session().getX('/login');

    var getHeaders = response_get.headers;
    var getBody = utf8.decode(response_get.bodyBytes);

    // 사실 Session.salt는 필요없는데 값 확인하려고 만듦
    Session.salt = Session().updateCookie(response_get, 'salt');

    // print('salt: ${Session.cookies['salt']}');

    data['pw'] = crypto_login(user_id, user_pw);

    //post
    var response_post = await Session().postX('/login', data);

    // var statusCode = response.statusCode;
    var postHeaders = response_post.headers;
    var postBody = utf8.decode(response_post.bodyBytes);

    // print('status code: $statusCode');
    // print('body: $postBody');
    // print('postHeader: $postHeaders');

    Session.session = Session().updateCookie(response_post, 'connect.sid');

    if (postHeaders['location'] == '../') {
      // Navigator.popAndPushNamed(context, '/mainPage');
      Get.offNamed('/mainPage');
    } else {
      Session.cookies['connect.sid'] = '';
    }
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
                obscureText: true,
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
                    // Navigator.pushNamed(context, '/signUp');
                    Get.toNamed('/signUp');
                  },
                  child: Text('SIGN UP'))
            ],
          ),
        )
      ],
    ));
  }
}
