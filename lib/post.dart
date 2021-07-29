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
  Future getPostData(String url) async {
    // print(url);
    var response = await Session().getX('http://10.0.2.2:3000' + url);
    print(response.body);
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
            return Container(
                child: Text(jsonDecode(utf8.decode(snapshot.data.bodyBytes))
                    .toString()));
          }
        });
  }
}

Widget postWidget(dynamic response) {
  var body = jsonDecode(utf8.decode(response.bodyBytes));
  var item = body['item'];
}
