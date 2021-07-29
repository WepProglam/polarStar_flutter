import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session.dart';
import 'package:get/get.dart';

import 'package:polarstar_flutter/login.dart';
import 'package:polarstar_flutter/mainPage.dart';
import 'package:polarstar_flutter/sign_up.dart';
import 'package:polarstar_flutter/profile.dart';

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
        GetPage(name: '/', page: () => Login()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/signUp', page: () => SignUp()),
        GetPage(name: '/mainPage', page: () => MainPage()),
        GetPage(name: '/profile', page: () => Profile()),
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
