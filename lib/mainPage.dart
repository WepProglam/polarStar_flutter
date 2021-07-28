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
      body: SingleChildScrollView(child: MainPageScroll()),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
            // backgroundColor: Colors.black
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'boards',
            // backgroundColor: Colors.black
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'unity',
            // backgroundColor: Colors.black
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outlined),
            label: 'work',
            // backgroundColor: Colors.black
          ),
        ],
        unselectedItemColor: Colors.black,
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
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceheight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Search',
                        isDense: true,
                        contentPadding: EdgeInsets.all(8)),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {},
                        icon: Icon(Icons.search_outlined),
                        iconSize: 20,
                      ),
                    )),
              ],
            ),
          ),

          // 취업정보
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: PageScrollPhysics(), // 하나씩 스크롤 되게 해줌
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: deviceWidth - 16,
                    color: Colors.amber[600],
                    child: Center(
                      child: Text("취업 정보$index"),
                    ),
                  );
                },
              ),
            ),
          ),

          // 빌보드(핫게)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '빌보드',
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      child: Center(child: Text('빌보드1')),
                      width: deviceWidth,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.red),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      child: Center(
                        child: Text('빌보드2'),
                      ),
                      width: deviceWidth,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.orange),
                    ),
                  )
                ],
              ),
            ),
          ),

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
