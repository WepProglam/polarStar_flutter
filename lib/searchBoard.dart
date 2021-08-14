import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'session.dart';
import 'dart:convert';
import 'getXController.dart';

class SearchBoard extends StatefulWidget {
  const SearchBoard({Key key}) : super(key: key);

  @override
  _SearchBoardState createState() => _SearchBoardState();
}

class _SearchBoardState extends State<SearchBoard> {
  List<Widget> pageButtons = [];
  var response;
  dynamic arg = Get.arguments;
  bool DID_FETCHED = false;

  TextEditingController searchText = TextEditingController();

  final Controller c = Get.put(Controller());

  int pageIndex = 1;

  Future getBoardData(dynamic arg, int page) async {
    String getUrl;
    List<Widget> buttons = [];

    if (arg is Map) {
      if (arg['from'] == 'home') {
        getUrl = '/board/searchAll/page/$page?search=${arg['search']}';
      } else if (arg['from'] == 'board') {
        getUrl =
            '/board/${arg['COMMUNITY_ID']}/search/page/$page?search=${arg['search']}';
      }
    } else {
      if (arg != '') {
        getUrl = '/board/$arg/page/$page';
      }
    }

    var res = await Session().getX(getUrl).then((value) {
      // print(jsonDecode(value.body));
      if (value.statusCode == 404) {
        c.changeIsBoardEmpty(true);
        buttons = [pageButton(1)];
        pageButtons = buttons;
        setState(() {});
        return value;
      } else {
        c.changeIsBoardEmpty(false);
        print(value);
        return value;
      }
    });

    // for (int i = 0; i < json.decode(res.body)['pageAmount']; i++) {
    //   buttons.add(pageButton(i + 1));
    // }
    if (!DID_FETCHED) {
      setState(() {
        response = res;
        // pageButtons = buttons;
      });
      DID_FETCHED = true;
    }

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

  Widget boardContents(List<dynamic> body) {
    print('boardContentsboardContentsboardContentsboardContentsboardContents');
    List<Widget> boardContentList = [];

    for (var item in body) {
      boardContentList.add(boardContent(item));
    }

    return Column(
      children: boardContentList,
    );
  }

  Widget boardContent(Map<dynamic, dynamic> data) {
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
            String boardUrl =
                '/board/${data['COMMUNITY_ID']}/read/${data['UNIQUE_ID']}';
            Map postArg = {'boardUrl': boardUrl};
            Get.toNamed('/post', arguments: postArg);
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
              child: arg is! Map
                  ? InkWell(
                      onTap: () {
                        Get.toNamed('/writePost', arguments: arg);
                      },
                      child: Icon(
                        Icons.add,
                      ))
                  : null,
            )
          ],
        ),
        body: FutureBuilder(
          future: getBoardData(arg, pageIndex),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print(snapshot.data);

            if (snapshot.hasData == false) {
              return Column(
                children: [
                  // Container(
                  //     // child: boardContents(json.decode(response.body)),
                  //     ),
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
            } else if (snapshot.hasError) {
              return CircularProgressIndicator();
            } else {
              return Column(
                children: [
                  Container(
                    child: boardContents(jsonDecode(response.body)),
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
        ));
  }
}
