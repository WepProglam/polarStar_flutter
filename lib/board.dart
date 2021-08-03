import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'session.dart';
import 'dart:convert';
import 'getXController.dart';

class Board extends StatefulWidget {
  const Board({Key key}) : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  List<Widget> pageButtons = [];
  var response;
  dynamic arg = Get.arguments;

  TextEditingController searchText = TextEditingController();

  final Controller c = Get.put(Controller());

  int pageIndex = 1;

  Future getBoardData(dynamic arg, int page) async {
    String getUrl;
    List<Widget> buttons = [];

    if (arg is Map) {
      // 검색한경우
      if (arg['from'] == 'home') {
        getUrl = '/board/searchAll/page/$page?search=${arg['search']}';
      } else if (arg['from'] == 'board') {
        getUrl =
            '/board/${arg['type']}/search/page/$page?search=${arg['search']}';
      }
      // 핫게시판
      else {
        getUrl = '/board/hot/page/$page';
      }
    }
    // 그냥 열람
    else {
      if (arg != '') {
        getUrl = '/board/$arg/page/$page';
      }
    }
    var res = await Session().getX(getUrl).then((value) {
      switch (value.statusCode) {
        case 200:
          break;
        case 401:
          break;
        case 404:
          c.changeIsBoardEmpty(true);
          buttons = [pageButton(1)];
          pageButtons = buttons;
          setState(() {});

          break;

        default:
          c.changeIsBoardEmpty(false);
      }
      return value;
    });

    for (int i = 0; i < json.decode(res.body)['pageAmount']; i++) {
      buttons.add(pageButton(i + 1));
    }

    setState(() {
      response = res;
      pageButtons = buttons;
    });

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
        setState(() {
          pageIndex = index;
        });
      },
    );
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
            Map argument = {
              'boardUrl': '/board/${data['type']}/read/${data['bid']}'
            };
            Get.toNamed('/post', arguments: argument);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [
            Container(
              width: 40,
              child: arg is! Map // 검색창이 아닌경우
                  ? InkWell(
                      onTap: () {
                        Get.toNamed('/writePost',
                            arguments: {'type': arg.toString()});
                      },
                      child: Icon(
                        Icons.add,
                      ))
                  : null,
            )
          ],
        ),
        body: Column(
          children: [
            FutureBuilder(
              future: getBoardData(arg, pageIndex),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Text('게시글이 없습니다'),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return CircularProgressIndicator();
                } else {
                  return Column(
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
                                      Map argument = {
                                        'search': searchText.text,
                                        'from': 'board',
                                        'type':
                                            json.decode(response.body)['type']
                                      };

                                      Get.toNamed('/searchBoard',
                                          arguments: argument);
                                    },
                                    icon: Icon(Icons.search_outlined),
                                    iconSize: 20,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Container(
                        child: boardContents(json.decode(response.body)),
                      ),
                    ],
                  );
                }
              },
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
        ));
  }
}
