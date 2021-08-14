import 'package:cached_network_image/cached_network_image.dart';
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
  bool getData = false;

  Future getBoardData(dynamic arg, int page) async {
    String getUrl;
    // List<Widget> buttons = [];

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
          // buttons = [pageButton(1)];
          // pageButtons = buttons;
          setState(() {});

          break;

        default:
          c.changeIsBoardEmpty(false);
      }
      return value;
    });

    // for (int i = 0; i < json.decode(res.body)['pageAmount']; i++) {
    //   buttons.add(pageButton(i + 1));
    // }
    //여기때메 계속 정보 받아옴
    if (!getData) {
      setState(() {
        response = res;
        // pageButtons = buttons;
      });
      getData = true;
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
    List<Widget> boardContentList = [];
    // print(body);

    for (Map<String, dynamic> item in body) {
      boardContentList.add(getPosts(item));
    }

    return Column(
      children: boardContentList,
    );
  }

  Widget boardContent(Map<String, dynamic> data) {
    // print(data);
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
                            arguments: {'COMMUNITY_ID': arg.toString()});
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
                                        'COMMUNITY_ID':
                                            jsonDecode(response.body)[0]
                                                ['COMMUNITY_ID']
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pageButtons,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget getPosts(json) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: 200,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            primary: Colors.black,
          ),
          onPressed: () {
            String boardUrl =
                '/board/${json["COMMUNITY_ID"]}/read/${json["BOARD_ID"]}';
            Map argument = {'boardUrl': boardUrl};
            Get.toNamed('/post', arguments: argument);
          },
          child: Row(
            children: [
              Spacer(
                flex: 6,
              ),
              Expanded(
                  flex: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(
                        flex: 7,
                      ),
                      Expanded(
                          flex: 20,
                          child: CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.white,
                            child: Image.network(
                              'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/${json["PROFILE_PHOTO"]}',
                              fit: BoxFit.fill,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                            ),
                          )),
                      Spacer(
                        flex: 5,
                      ),
                      Expanded(
                        flex: 9,
                        child: Text(
                          "${json["PROFILE_NICKNAME"]}",
                          textScaleFactor: 0.8,
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: Text(
                          "${json["COMMUNITY_ID"]} 게시판",
                          textScaleFactor: 0.5,
                        ),
                      ),
                      Spacer(
                        flex: 8,
                      )
                    ],
                  )),
              Spacer(
                flex: 10,
              ),
              Expanded(
                  flex: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(
                        flex: 11,
                      ),
                      Expanded(
                          flex: 18,
                          child: Text(
                            json["TITLE"],
                            textScaleFactor: 1.5,
                          )),
                      Spacer(
                        flex: 11,
                      ),
                      Expanded(
                          flex: 12,
                          child: Text(
                            json["CONTENT"],
                            textScaleFactor: 1.0,
                          )),
                      Spacer(
                        flex: 7,
                      )
                    ],
                  )),
              json["PHOTO"] == "" || json["PHOTO"] == null //빈 문자열 처리해야함
                  ? Expanded(
                      flex: 80,
                      child: Column(children: [
                        Spacer(
                          flex: 40,
                        ),
                        Expanded(
                          child: Text(
                            "좋아요${json["LIKES"]} 댓글${json["COMMENTS"]} 스크랩${json["SCRAPS"]}",
                            textScaleFactor: 0.5,
                          ),
                          flex: 9,
                        )
                      ]))
                  : Expanded(
                      flex: 80,
                      child: Column(children: [
                        Expanded(
                          flex: 40,
                          child: CachedNetworkImage(
                              imageUrl:
                                  'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/board/${json["PHOTO"]}',
                              fadeInDuration: Duration(milliseconds: 0),
                              progressIndicatorBuilder: (context, url,
                                      downloadProgress) =>
                                  Image(image: AssetImage('image/spinner.gif')),
                              errorWidget: (context, url, error) {
                                print(error);
                                return Icon(Icons.error);
                              }),
                        ),
                        /*loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              }*/

                        Expanded(
                          child: Text(
                            "좋아요${json["LIKES"]} 댓글${json["COMMENTS"]} 스크랩${json["SCRAPS"]}",
                            textScaleFactor: 0.5,
                          ),
                          flex: 9,
                        )
                      ])),
              Spacer(
                flex: 4,
              )
            ],
          ),
        ),
      ),
    );
  }
}
