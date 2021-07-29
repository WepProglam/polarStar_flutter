import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'session.dart';

class Post extends StatelessWidget {
  const Post({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String arg = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
      ),
      body: PostState(arg: arg),
    );
  }
}

class PostState extends StatefulWidget {
  final String arg;
  PostState({Key key, this.arg}) : super(key: key);

  @override
  _PostStateState createState() => _PostStateState();
}

class _PostStateState extends State<PostState> {
  String getUrl;
  Future getPostData(String url) async {
    // print(url);
    if (url != '') {
      getUrl = 'http://10.0.2.2:3000' + url;
    }
    var response = await Session().getX(getUrl);
    // print(jsonDecode(utf8.decode(response.bodyBytes))['comments']);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getPostData(widget.arg),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Container(child: Text(snapshot.data.bodyBytes));
          } else {
            return Container(child: postWidget(snapshot.data));
          }
        });
  }
}

Widget postWidget(dynamic response) {
  var body = jsonDecode(utf8.decode(response.bodyBytes));
  var item = body['item'];
  var title = item['title'];
  var content = item['content'];
  var nickname = item['nickname'];
  var time = item['time'].substring(2, 16).replaceAll(RegExp(r'-'), '/');

  List<Widget> commentList = [];

  Widget commentWidget(Map<String, dynamic> comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Container(
            decoration:
                BoxDecoration(border: BorderDirectional(top: BorderSide())),
            child: Row(
              children: [
                // 프사
                Container(
                  height: 20,
                  width: 20,
                ), // 프로필 사진
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment['nickname']),
                    Text(
                      time,
                      textScaleFactor: 0.6,
                    ),
                  ],
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.thumb_up,
                      size: 10,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.add_comment,
                      size: 10,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.settings,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
          child: Text(comment['content']),
        ),
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide())),
        )
      ],
    );
  }

  for (var item in body['comments'].keys) {
    commentList.add(commentWidget(body['comments'][item]['comment']));
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 게시글
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            decoration:
                BoxDecoration(border: BorderDirectional(top: BorderSide())),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                ), // 프로필 사진
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(body['myself'] ? '나($nickname)' : nickname),
                    Text(
                      time,
                      textScaleFactor: 0.6,
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    if (body['myself']) {}
                  },
                  icon: Icon(Icons.thumb_up),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () {
                    if (body['myself']) {}
                  },
                  icon: Icon(Icons.bookmark),
                  iconSize: 20,
                ),

                IconButton(
                  onPressed: () {
                    if (body['myself']) {}
                  },
                  icon: Icon(Icons.settings),
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
        // 제목
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // decoration: BoxDecoration(border: Border.all()),
            child: Text(
              title,
              textScaleFactor: 2,
            ),
          ),
        ),
        // 내용
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // decoration: BoxDecoration(border: Border.all()),
            child: Text(
              content,
              textScaleFactor: 1.5,
            ),
          ),
        ),
        // 좋아요, 댓글, 스크랩 수
        Container(
          decoration:
              BoxDecoration(border: BorderDirectional(bottom: BorderSide())),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Row(
              children: [
                TextButton.icon(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: () {},
                  icon: Icon(
                    Icons.thumb_up,
                    size: 20,
                  ),
                  label: Text(item['like'].toString()),
                ),
                TextButton.icon(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black)),
                  onPressed: () {},
                  icon: Icon(
                    Icons.comment,
                    size: 20,
                  ),
                  label: Text(body['comments'] != {}
                      ? body['comments'].length.toString()
                      : '0'),
                ),
                TextButton.icon(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellow[700])),
                  onPressed: () {},
                  icon: Icon(
                    Icons.bookmark,
                    size: 20,
                  ),
                  label: Text('0'),
                ),
                Spacer(),
              ],
            ),
          ),
        ),

        // 여기부턴 댓글
        Column(
          // children: [commentWidget(body['comments']['77']['comment'])],
          children: commentList,
        )
      ],
    ),
  );
}
