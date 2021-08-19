// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'session.dart';
import 'getXController.dart';
import '../src/post_layout.dart';

class Post extends StatelessWidget {
  final mailWriteController = TextEditingController();
  final mailController = Get.put(MailController());
  final BOTTOM_SHEET_HEIGHT = 60;
  final c = Get.isRegistered<PostController>()
      ? Get.find<PostController>()
      : Get.put(PostController(
          boardOrRecruit: 'board',
          BOARD_ID: Get.arguments["BOARD_ID"],
          COMMUNITY_ID: Get.arguments["COMMUNITY_ID"]));

  @override
  Widget build(BuildContext context) {
    var commentWriteController = TextEditingController();
    // c.getPostData();
    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
        ),
        body: Obx(() {
          if (!c.dataAvailable) {
            return CircularProgressIndicator();
          } else {
            return PostLayout(
              c: c,
            );
          }
        }),
        bottomSheet: Container(
          height: 60,
          child: Stack(children: [
            Container(
              child: Row(
                children: [
                  // 익명 체크
                  Container(
                    height: BOTTOM_SHEET_HEIGHT.toDouble(),
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Obx(() => Container(
                                height: 20,
                                width: 20,
                                child: Transform.scale(
                                  scale: 1,
                                  child: Checkbox(
                                    value: c.anonymousCheck.value,
                                    onChanged: (value) {
                                      c.changeAnonymous(value);
                                    },
                                  ),
                                ),
                              )),
                          Text(' 익명'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: Obx(
                    () => TextFormField(
                      controller: commentWriteController,
                      autofocus: c.autoFocusTextForm.value,
                      decoration: InputDecoration(
                          hintText: c.autoFocusTextForm.value
                              ? '수정하기'
                              : c.isCcomment.value
                                  ? '대댓글 작성'
                                  : '댓글 작성',
                          border: OutlineInputBorder()),
                    ),
                  )),
                ],
              ),
            ),
            Positioned(
              top: 15,
              right: 20,
              child: InkWell(
                onTap: () async {
                  Map commentData = {
                    'content': commentWriteController.text,
                    'unnamed': c.anonymousCheck.value ? '1' : '0'
                  };

                  String postUrl;

                  if (c.isCcomment.value) {
                    // 대댓 작성인경우
                    print(c.ccommentUrl);
                    postUrl = c.ccommentUrl.value;
                  } else {
                    // 댓글 작성인경우
                    print(c.commentUrl);
                    postUrl = c.commentUrl.value;
                  }

                  print(postUrl);

                  if (c.autoFocusTextForm.value) {
                    Session()
                        .putX(c.putUrl.value, commentData)
                        .then((value) => c.refreshPost());
                  } else {
                    Session()
                        .postX(postUrl, commentData)
                        .then((value) => c.refreshPost());
                  }
                },
                child: Icon(
                  Icons.send,
                  size: 30,
                ),
              ),
            ),
          ]),
        ));
  }
}
