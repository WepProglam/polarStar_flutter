import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'session.dart';
import 'getXController.dart';

class MainPageScroll extends StatelessWidget {
  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceheight = MediaQuery.of(context).size.height;

    Future<Map> getBoardInfo() async {
      var getResponse = await Session().getX('/');
      var body = jsonDecode(getResponse.body);
      box.write("boardInfo", body["board"]);
      return body;
    }

    TextEditingController searchText = TextEditingController();

    return SingleChildScrollView(
      child: Center(
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
                      controller: searchText,
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
                          onPressed: () {
                            Map arg = {
                              'search': searchText.text,
                              'from': 'home'
                            };
                            Get.toNamed('/searchBoard', arguments: arg);
                          },
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
                    return InkWell(
                      child: Container(
                        width: deviceWidth - 16,
                        color: Colors.amber[600],
                        child: Center(
                          child: Text("취업 정보$index"),
                        ),
                      ),
                    );
                    // return RecruitPostPreview(body: );
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
                    } else if (snapshot.data.isEmpty) {
                      return Text("아직 데이터가 없음");
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
                                '핫보드',
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
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '핫보드',
                                )),
                          ),
                          for (var item in snapshot.data["HotBoard"])
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                child: billboardContent(item),
                                width: deviceWidth,
                                height: 50,
                                decoration: BoxDecoration(color: Colors.orange),
                              ),
                            ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),

            // 게시판
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '게시판',
                        ),
                      ),
                    ),
                    FutureBuilder(
                        future: getBoardInfo(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData == false) {
                            return CircularProgressIndicator();
                          } else if (snapshot.data.isEmpty) {
                            return Text("아직 데이터가 없음");
                          } else if (snapshot.hasError) {
                            return boards(snapshot.data['board']);
                          } else {
                            return Container(
                                child: boards(snapshot.data['board']));
                          }
                        }),
                  ],
                ),
              ),
            ),

            //시간표 & 강의평가
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '시간표/강의평가',
                      ),
                    ),
                  ),
                  Container(
                    width: deviceWidth - 16,
                    height: 200,
                    margin: EdgeInsets.only(top: 2, bottom: 2),
                    decoration: BoxDecoration(border: Border.all()),
                    child: null,
                  ),
                ],
              ),
            ),

            // 유니티
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '유니티',
                      ),
                    ),
                  ),
                  Container(
                    width: deviceWidth - 16,
                    height: 200,
                    margin: EdgeInsets.only(top: 2, bottom: 2),
                    decoration: BoxDecoration(border: Border.all()),
                    child: null,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// 핫게 위젯
Widget billboardContent(var data) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      primary: Colors.black,
    ),
    onPressed: () {
      // print('url: ${data['url']}');
      Map argument = {
        "BOARD_ID": data['BOARD_ID'],
        "COMMUNITY_ID": data['COMMUNITY_ID']
      };
      // print(argument);
      Get.toNamed('/post', arguments: argument);
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(data['COMMUNITY_NAME'].toString())),
        Spacer(),
        Container(
          width: 200,
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  data['TITLE'],
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  data['CONTENT'],
                  textAlign: TextAlign.left,
                  maxLines: 1,
                ),
              )
            ],
          ),
        ),
        Spacer(),
      ],
    ),
  );
}

// 게시판 목록 위젯
Widget boards(List<dynamic> data) {
  print(data);
  List<Widget> boardList = [];

  data.forEach((value) {
    boardList
        .add(board(value["COMMUNITY_ID"].toString(), value["COMMUNITY_NAME"]));
  });

  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: boardList,
  );
}

// 게시판 위젯
Widget board(String boardtype, dynamic boardName) {
  return Padding(
    padding: const EdgeInsets.all(1),
    child: Container(
      decoration: BoxDecoration(color: Colors.lightGreen),
      width: Get.mediaQuery.size.width - 18,
      height: 25,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          primary: Colors.black,
        ),
        onPressed: () {
          Get.toNamed('/board', arguments: boardtype);
        },
        child: Text(
          boardName.toString(),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
