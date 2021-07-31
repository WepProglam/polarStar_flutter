import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'session.dart';
import 'dart:convert';
import 'getXController.dart';

class Board extends StatefulWidget {
  const Board({Key key}) : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  List<Widget> boardContentList = [];
  List<Widget> pageButtons = [];
  var response;
  var arg = Get.arguments;

  final Controller c = Get.put(Controller());

  Future getBoardData(String type, int page) async {
    String getUrl;
    if (type != '') {
      getUrl = '/board/$type/page/$page';
    }
    var res = await Session().getX(getUrl);

    print(json.decode(res.body));

    List<Widget> buttons = [];
    for (int i = 0; i < json.decode(res.body)['pageAmount']; i++) {
      buttons.add(pageButton(i + 1));
    }

    setState(() {
      response = res;
      pageButtons = buttons;
    });

    // print(response.headers['content-type']);
    return res;
  }

  Widget pageButton(int index) {
    return InkWell(
      child: Container(
          height: 40,
          width: 40,
          child: Center(
            child: Text(
              '$index',
              textAlign: TextAlign.center,
              textScaleFactor: 2,
            ),
          )),
      onTap: () {
        c.updatePageIndex(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
        ),
        body: Obx(() => FutureBuilder(
              future: getBoardData(arg, c.pageIndex.value),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return CircularProgressIndicator();
                } else {
                  return Column(
                    children: [
                      Container(
                        child: boardContents(json.decode(response.body)),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: pageButtons,
                          ),
                        ),
                      )
                    ],
                  );
                }
              },
            )));
  }
}

Widget boardContents(Map<String, dynamic> body) {
  List<Widget> boardContentList = [];

  for (Map<String, dynamic> item in body['rows']) {
    boardContentList.add(boardContent(item));
  }

  return Column(
    children: boardContentList,
  );
}

Widget boardContent(Map<String, dynamic> data) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Container(
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          primary: Colors.black,
        ),
        onPressed: () {
          // print('url: ${data['url']}');
          String boardUrl = '/board/${data['type']}/read/${data['bid']}';
          Get.toNamed('/post', arguments: boardUrl);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 200,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data['title'],
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data['content'],
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
      ),
    ),
  );
}
