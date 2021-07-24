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
        '/': (context) => Session.accessToken == '' ? Login() : MainPage(),
        '/login': (context) => Login(),
        '/signUp': (context) => SignUp(),
        '/mainPage': (context) => MainPage(),
      },
      // home: MyHomePage(title: 'Main'),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             //검색 바
//             Row(
//               children: [
//                 Spacer(),
//                 Expanded(
//                   flex: 6,
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                         border: OutlineInputBorder(), hintText: 'Search'),
//                   ),
//                 ),
//                 Spacer(),
//                 Expanded(
//                     flex: 2,
//                     child: OutlinedButton(onPressed: null, child: Text('검색'))),
//                 Spacer(),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
