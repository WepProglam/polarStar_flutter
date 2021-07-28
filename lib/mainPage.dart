import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session.dart';
import 'package:get/get.dart';

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
                Session.cookies = {};
                Session.headers['Cookie'] = '';
                // Navigator.pushNamedAndRemoveUntil(
                //     context, '/login', (Route<dynamic> route) => false);
                Get.offAllNamed('/login');
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

    Future<String> getBoardInfo() async {
      // var response = await Session().getN('http://10.0.2.2:3000/');
      var response = await Session().getN('http://10.0.2.2:3000/');
      var body = utf8.decode(response.bodyBytes);

      print(body);

      print(jsonDecode(jsonDecode(body)['hotboard'])[0]); // Map<String,Dynamic>

      // billboardContent(jsonDecode(jsonDecode(body)['hotboard'])[0]);

      return body;
    }

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
              child: FutureBuilder(
                future: getBoardInfo(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData == false) {
                    return CircularProgressIndicator();
                  }
                  //error가 발생하게 될 경우 반환하게 되는 부분
                  else if (snapshot.hasError) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '빌보드',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            // child: Center(child: Text('빌보드1')),
                            width: deviceWidth,
                            height: 50,
                            decoration: BoxDecoration(color: Colors.red),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            // child: Center(
                            //   child: Text('빌보드2'),
                            // ),
                            width: deviceWidth,
                            height: 50,
                            decoration: BoxDecoration(color: Colors.orange),
                          ),
                        )
                      ],
                    );
                  }
                  // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
                  else {
                    return Column(
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
                            child: billboardContent(jsonDecode(
                                jsonDecode(snapshot.data)['hotboard'])[0]),
                            width: deviceWidth,
                            height: 50,
                            decoration: BoxDecoration(color: Colors.red),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            child: billboardContent(jsonDecode(
                                jsonDecode(snapshot.data)['hotboard'])[1]),
                            width: deviceWidth,
                            height: 50,
                            decoration: BoxDecoration(color: Colors.orange),
                          ),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ),

          // 게시판
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [],
            ),
          ),

          //시간표 & 강의평가

          // 유니티
        ],
      ),
    );
  }
}

Widget billboardContent(Map<String, dynamic> data) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      primary: Colors.black,
    ),
    onPressed: () {
      print('url: ${data['url']}');
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('게시판 ${data['type']}'),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data['title'],
            ),
            Text(
              data['content'],
            )
          ],
        )
      ],
    ),
  );
}
