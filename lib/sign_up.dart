import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// void main() {
//   runApp(SignUp());
// }

class SignUp extends StatelessWidget {
  const SignUp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SignUpInput(),
    );
  }
}

class SignUpInput extends StatefulWidget {
  SignUpInput({Key key}) : super(key: key);

  @override
  _SignUpInputState createState() => _SignUpInputState();
}

class _SignUpInputState extends State<SignUpInput> {
  final idController = TextEditingController();
  final pwController = TextEditingController();
  final nicknameController = TextEditingController();
  final studentIDController = TextEditingController();

  Future userSignUp() async {
    var url =
        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/admin';

    String sign_id = idController.text;
    String sign_pw = pwController.text;
    String sign_nickname = nicknameController.text;
    String sign_studentID = studentIDController.text;

    var data = {
      'id': sign_id,
      'pw': sign_pw,
      'nickname': sign_nickname,
      'studentID': sign_studentID
    };

    var response = await http.post(Uri.parse(url), body: data);

    print(response);
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
                controller: idController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'ID'),
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
                controller: pwController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'PW'),
              ),
            ],
          )),
          Container(
              child: Column(
            children: [
              Text('닉네임을 입력하세요'),
              Container(
                height: 10,
              ),
              TextFormField(
                controller: nicknameController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Nickname'),
              ),
            ],
          )),
          Container(
              child: Column(
            children: [
              Text('학생번호를 입력하세요'),
              Container(
                height: 10,
              ),
              TextFormField(
                controller: studentIDController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Student ID'),
              ),
            ],
          )),
          OutlinedButton(
              onPressed: () {
                userSignUp();
              },
              child: Text('sign up'))
        ],
      ),
    );
  }
}