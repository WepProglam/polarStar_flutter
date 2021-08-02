import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polarstar_flutter/searchBoard.dart';

import 'session.dart';

import 'package:polarstar_flutter/login.dart';
import 'package:polarstar_flutter/mainPage.dart';
import 'package:polarstar_flutter/session.dart';
import 'package:polarstar_flutter/sign_up.dart';
import 'package:polarstar_flutter/profile.dart';
import 'package:polarstar_flutter/board.dart';
import 'package:polarstar_flutter/post.dart';
import 'package:polarstar_flutter/writePost.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'polarStar',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/',
      getPages: [
        GetPage(
            name: '/',
            page: () => Session.headers['Cookie'] == '' ? Login() : MainPage()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/signUp', page: () => SignUp()),
        GetPage(name: '/mainPage', page: () => MainPage()),
        GetPage(name: '/profile', page: () => Profile()),
        GetPage(name: '/profile/setting', page: () => ProfileSetting()),
        GetPage(name: '/board', page: () => Board()),
        GetPage(name: '/searchBoard', page: () => SearchBoard()),
        GetPage(name: '/post', page: () => Post()),
        GetPage(name: '/writePost', page: () => WritePost())
      ],

      // routes: {
      //   '/': (context) => Login(),
      //   '/login': (context) => Login(),
      //   '/signUp': (context) => SignUp(),
      //   '/mainPage': (context) => MainPage(),
      // },
      // home: MyHomePage(title: 'Main'),
    );
  }
}
