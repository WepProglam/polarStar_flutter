import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:polarstar_flutter/login.dart';
import 'package:polarstar_flutter/main_page.dart';
import 'package:polarstar_flutter/sign_up.dart';
import 'session.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'polarStar',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => Login(),
        '/login': (context) => Login(),
        '/signUp': (context) => SignUp(),
        '/mainPage': (context) => MainPage(),
      },
      // home: MyHomePage(title: 'Main'),
    );
  }
}
