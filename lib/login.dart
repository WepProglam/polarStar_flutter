import 'package:flutter/material.dart';
import 'package:polarstar_flutter/src/form_validator.dart';
import 'dart:convert';
import 'session.dart';
import 'crypt.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'getXController.dart';
import './src/custom_text_form_field.dart';

// void main() {
//   runApp(Login());
// }

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('polarStar'),
      ),
      body: LoginInputs(),
    );
  }
}

class LoginInputs extends StatelessWidget {
  LoginInputs({Key key}) : super(key: key);

  final loginIdContoller = TextEditingController();
  final loginPwContoller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final box = GetStorage();

  final loginController = LoginController();

  // login 함수
  Future userLogin(String token) async {
    Session.cookies = {};
    Session.headers['Cookie'] = '';

    String user_id = loginIdContoller.text;
    String user_pw = loginPwContoller.text;

    Map<String, String> data = {
      'id': user_id,
      'pw': user_pw,
      'token': token,
    };

    Session.user_id = user_id;
    Session.user_pw = user_pw;

    await box.write('id', data['id']);
    await box.write('pw', data['pw']);

    var response_get = await Session().getX('/login');

    var getHeaders = response_get.headers;
    var getBody = utf8.decode(response_get.bodyBytes);

    // 사실 Session.salt는 필요없는데 값 확인하려고 만듦
    Session.salt = Session().updateCookie(response_get, 'salt');

    data['pw'] = crypto_login(user_id, user_pw);

    //post
    Session().postX('/login', data).then((value) async {
      switch (value.statusCode) {
        case 200:
          Session.session = Session().updateCookie(value, 'connect.sid');
          if (loginController.isAutoLogin.value) {
            await box.write('isLoggined', true);
            await box.write('token', Session.headers['Cookie']);
            await box.write('tokenFCM', token);

            print(token);
          } else {
            await box.remove('id');
            await box.remove('pw');
            await box.remove('isLoggined');
            await box.remove('token');
            await box.remove('tokenFCM');
          }
          Get.offAndToNamed('/mainPage');
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notiController = Get.put(NotiController());
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 20),
          CustomTextFormField(
            hint: "ID",
            textController: loginIdContoller,
            funcValidator: (value) {
              return checkEmpty(value);
            },
          ),
          CustomTextFormField(
            hint: "PASSWORD",
            textController: loginPwContoller,
            funcValidator: (value) {
              return checkEmpty(value);
            },
          ),
          Row(children: [
            Obx(
              () => Checkbox(
                  value: loginController.isAutoLogin.value,
                  onChanged: (value) {
                    print(value);
                    loginController.updateAutoLogin(value);
                  }),
            ),
            Text('자동 로그인')
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    print("??");
                    print(_formKey.currentState.validate());
                    if (_formKey.currentState.validate()) {
                      await userLogin(notiController.tokenFCM.value);
                    }
                  },
                  child: Text("로그인")),
              ElevatedButton(
                  onPressed: () => Get.toNamed('/signUp'), child: Text("회원가입"))
            ],
          )
        ],
      ),
    );
  }
}
