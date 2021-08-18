import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'crypt.dart';
import 'package:get/get.dart';
import './src/custom_text_form_field.dart';
import './src/form_validator.dart';
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
  final _formKey = GlobalKey<FormState>();

  Future userSignUp() async {
    var url =
        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/admin';

    String sign_id = idController.text;
    String sign_pw = pwController.text;
    String sign_nickname = nicknameController.text;
    String sign_studentID = studentIDController.text;

    Map<String, String> data = {
      'id': sign_id,
      'pw': sign_pw,
      'nickname': sign_nickname,
      'studentID': sign_studentID
    };

    data['pw'] = crypto_sign_up(sign_id, sign_pw);

    var response = await http.post(Uri.parse(url), body: data);

    print(response.headers);

    if (response.headers['location'] == '/login') {
      // Navigator.pop(context);
      Get.back();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('동일한 ID가 있습니다')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 20),
          CustomTextFormField(
            hint: "ID",
            textController: idController,
            funcValidator: (value) {
              return checkEmpty(value);
            },
          ),
          CustomTextFormField(
            hint: "PASSWORD",
            textController: pwController,
            funcValidator: (value) {
              return checkEmpty(value);
            },
          ),
          CustomTextFormField(
            hint: "NICKNAME",
            textController: nicknameController,
            funcValidator: (value) {
              return checkEmpty(value);
            },
          ),
          CustomTextFormField(
            hint: "SCHOOL",
            textController: studentIDController,
            funcValidator: (value) {
              return checkEmpty(value);
            },
          ),
          OutlinedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) userSignUp();
              },
              child: Text('회원가입'))
        ],
      ),
    );
  }
}
