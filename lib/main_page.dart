import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
        actions: [
          IconButton(
              onPressed: () {
                Session().get('http://10.0.2.2:3000/logout');
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false);
                Session.cookies = {};
                Session.headers['Cookie'] = '';
              },
              icon: Text('LOGOUT')),
          IconButton(onPressed: () {}, icon: Icon(Icons.person)),
        ],
      ),
      body: MainPageScroll(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'boards',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'unity',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.work_outlined),
              label: 'work',
              backgroundColor: Colors.black),
        ],
        // currentIndex: ,
        selectedItemColor: Colors.amber[800],
        onTap: null,
      ),
    );
  }
}

class MainPageScroll extends StatefulWidget {
  MainPageScroll({Key key}) : super(key: key);

  @override
  _MainPageScrollState createState() => _MainPageScrollState();
}

class _MainPageScrollState extends State<MainPageScroll> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // 검색창
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 8,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Search'),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      onPressed: () {}, icon: Icon(Icons.search_outlined))),
              Spacer(
                flex: 1,
              ),
            ],
          ),

          // 광고

          // 빌보드(핫게)

          // 게시판들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              OutlinedButton(onPressed: () {}, child: Text('board1')),
              Spacer(),
              OutlinedButton(onPressed: () {}, child: Text('board2')),
              Spacer(),
              OutlinedButton(onPressed: () {}, child: Text('board3')),
              Spacer(),
              OutlinedButton(onPressed: () {}, child: Text('board4')),
              Spacer(),
            ],
          ),

          //시간표 & 강의평가

          // 유니티
        ],
      ),
    );
  }
}
