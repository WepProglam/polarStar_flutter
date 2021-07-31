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
      body: PostScroll(arg: arg),
    );
  }
}

class PostScroll extends StatefulWidget {
  PostScroll({Key key, this.arg}) : super(key: key);

  final String arg;

  @override
  _PostScrollState createState() => _PostScrollState();
}

class _PostScrollState extends State<PostScroll> {
  Future getPostData(String url) async {
    String getUrl;
    // print(url);
    if (url != '') {
      getUrl = url;
    }

    var response = await Session().getX(getUrl);

    // print(jsonDecode(utf8.decode(response.bodyBytes))['comments'].toString());

    // print(response.headers['content-type']);

    if (response.headers['content-type'] == 'text/html; charset=utf-8') {
      Session().getX('/logout');
      Get.offAllNamed('/login');
      return null;
    } else {
      return response;
    }
  }

  @override
  void initState() {
    // http.get 여기서 하면 될 듯
    super.initState();
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
  var body = json.decode(response.body);
  var item = body['item'];
  var title = item['title'];
  var content = item['content'];
  var nickname = item['nickname'];
  var time = item['time'].substring(2, 16).replaceAll(RegExp(r'-'), '/');

  List<Widget> commentWidgetList = [];

  Widget commentWidget(Map<String, dynamic> comment) {
    List<Widget> ccommentWidgetList = [];
    List<Map> ccommentList = [];

    var commentTime = comment['comment']['time']
        .substring(2, 16)
        .replaceAll(RegExp(r'-'), '/');

    //대댓
    Widget ccommentWidget(Map<String, dynamic> ccomment) {
      var ccommentTime =
          ccomment['time'].substring(2, 16).replaceAll(RegExp(r'-'), '/');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0, left: 40),
            child: Container(
              // decoration:
              //     BoxDecoration(border: BorderDirectional(top: BorderSide())),
              child: Row(
                children: [
                  // 프사
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      height: 20,
                      width: 20,
                      child: Image.network(
                          'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000${ccomment['profile_photo']}'),
                    ),
                  ), // 프로필 사진
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ccomment['nickname']),
                      Text(
                        ccommentTime,
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
            padding: const EdgeInsets.only(left: 50.0, bottom: 5.0),
            child: Text(ccomment['content']),
          ),
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide())),
          ),
        ],
      );
    }

    // 대댓 리스트 생성
    if (comment['cc'] != []) {
      for (int i = 0; i < comment['cc'].length; i++) {
        // ccommentWidgetList.add(ccommentWidget(comment['cc'][i]));
        ccommentList.add(comment['cc'][i]);
      }
      ccommentList.sort((a, b) => a['time'].compareTo(b['time']));
      print(ccommentList);

      for (var item in ccommentList) {
        ccommentWidgetList.add(ccommentWidget(item));
      }
    } else {
      ccommentWidgetList.add(Container(child: null));
    }

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
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    height: 20,
                    width: 20,
                    child: Image.network(
                        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000${comment['comment']['profile_photo'].toString()}'),
                  ),
                ), // 프로필 사진
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment['comment']['nickname']),
                    Text(
                      commentTime,
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
          child: Text(comment['comment']['content']),
        ),
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide())),
        ),

        // 대댓글
        Container(
            child: Column(
          children: ccommentWidgetList,
        ))
      ],
    );
  }

  // 댓글 리스트 생성
  if (body['comments'] != null) {
    for (var item in body['comments'].keys) {
      commentWidgetList.add(commentWidget(body['comments'][item]));
    }
  } else {
    commentWidgetList.add(Container(child: null));
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
                // 프로필 사진
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 30,
                    width: 30,
                    child: Image.network(
                        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000${item['profile_photo']}'),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nickname),
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
        Container(
          child: item['photo'] != ''
              ? Image.network(
                  'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${item['photo']}')
              : null,
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
          children: commentWidgetList,
        )
      ],
    ),
  );
}
