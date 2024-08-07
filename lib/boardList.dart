import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'session.dart';

class Boards extends StatefulWidget {
  const Boards({Key key}) : super(key: key);

  @override
  _BoardsState createState() => _BoardsState();
}

class _BoardsState extends State<Boards> {
  Future<dynamic> getBoardInfo() async {
    var getResponse = await Session().getX('/');
    var body = jsonDecode(getResponse.body);
    return body;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController boardNameController = TextEditingController();
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              children: [
                // Hot
                Container(child: hotBoard()),
                // Recruit
                Padding(
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.lightBlue[100]),
                    width: Get.mediaQuery.size.width - 18,
                    height: 100,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        primary: Colors.black,
                      ),
                      onPressed: () {
                        Get.toNamed('/recruit/1/page/1');
                      },
                      child: Text(
                        'RECRUIT',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '전체 게시판 목록',
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: 20,
                        width: 150,
                        child: TextFormField(
                          controller: boardNameController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(9)
                          ],

                          // maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        ),
                      ),
                      // 게시판 추가
                      InkWell(
                        onTap: () {
                          Session().postX('/board', {
                            'boardName': boardNameController.text
                          }).then((value) {
                            print(value.statusCode);
                            switch (value.statusCode) {
                              case 200:
                                setState(() {});
                                break;
                              default:
                            }
                          });
                        },
                        child: Icon(Icons.add),
                      )
                    ],
                  ),
                ),
                FutureBuilder(
                    future: getBoardInfo(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      print(snapshot.data);
                      if (snapshot.hasData == false) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return CircularProgressIndicator();
                      } else {
                        return Container(child: boards(snapshot.data['board']));
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget boards(List<dynamic> data) {
  List<Widget> boardList = [];

  data.forEach((element) {
    boardList.add(
        board(element["COMMUNITY_ID"].toString(), element["COMMUNITY_NAME"]));
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
      decoration: BoxDecoration(color: Colors.lightBlue[100]),
      width: Get.mediaQuery.size.width - 18,
      height: 100,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          primary: Colors.black,
        ),
        onPressed: () {
          Get.toNamed('/board/$boardtype/page/1');
        },
        child: Text(
          boardName.toString(),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

Widget hotBoard() {
  return Padding(
    padding: const EdgeInsets.all(1),
    child: Container(
      decoration: BoxDecoration(color: Colors.lightBlue[100]),
      width: Get.mediaQuery.size.width - 18,
      height: 100,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          primary: Colors.black,
        ),
        onPressed: () {
          Map argument = {'from': 'hot'};
          Get.toNamed('/board', arguments: argument);
        },
        child: Text(
          'HOT',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
