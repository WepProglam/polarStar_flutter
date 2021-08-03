import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'session.dart';

import 'package:polarstar_flutter/login.dart';
import 'package:polarstar_flutter/mainPage.dart';
import 'package:polarstar_flutter/session.dart';
import 'package:polarstar_flutter/sign_up.dart';
import 'package:polarstar_flutter/profile.dart';
import 'package:polarstar_flutter/board.dart';
import 'package:polarstar_flutter/post.dart';
import 'package:polarstar_flutter/writePost.dart';
import 'package:polarstar_flutter/searchBoard.dart';

void main() async {
  await GetStorage.init();
  if (GetStorage().hasData('token')) {
    Session.headers['Cookie'] = await GetStorage().read('token');
    print(Session.headers['Cookie']);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final box = GetStorage();
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
            name: '/', page: () => box.hasData('token') ? MainPage() : Login()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/signUp', page: () => SignUp()),
        GetPage(name: '/mainPage', page: () => MainPage()),
        GetPage(name: '/myPage', page: () => Mypage()),
        GetPage(name: '/myPage/profile', page: () => Profile()),
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
