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
// import 'package:polarstar_flutter/board.dart';
import 'package:polarstar_flutter/post.dart';
import 'package:polarstar_flutter/writePost.dart';
import 'package:polarstar_flutter/searchBoard.dart';
import 'package:polarstar_flutter/mailBox.dart';
import 'package:polarstar_flutter/board/recruit_board.dart';
import 'package:polarstar_flutter/board/board.dart';
import 'package:polarstar_flutter/recruit_information/recruit_post.dart';

import 'package:firebase_core/firebase_core.dart';
import 'getXController.dart';

void main() async {
  await GetStorage.init();
  if (GetStorage().hasData('token')) {
    Session.headers['Cookie'] = await GetStorage().read('token');
  }

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final box = GetStorage();
  final notiController = Get.put(NotiController());
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
        GetPage(name: '/writePost', page: () => WritePost()),
        GetPage(name: '/mailBox', page: () => MailBox()),
        GetPage(name: '/mailBox/sendMail', page: () => SendMail()),
        GetPage(
            name: '/recruit/:COMMUNITY_ID/page/:page',
            page: () => RecruitBoard()),
        GetPage(
            name: '/recruit/:COMMUNITY_ID/read/:BOARD_ID',
            page: () => RecruitPost())
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
