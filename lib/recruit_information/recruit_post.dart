// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:polarstar_flutter/session.dart';

import 'recruit_controller.dart';
import 'package:polarstar_flutter/getXController.dart';
import '../src/post_layout.dart';

class RecruitPost extends GetView<PostController> {
  RecruitPost({Key key}) : super(key: key);

  //post는 종류와 상관없이 그냥 PostController 쓰면 됨
  final c = Get.put(PostController(
      BOARD_ID: Get.arguments["BOARD_ID"],
      COMMUNITY_ID: Get.arguments["COMMUNITY_ID"]));

  final mailController = Get.put(MailController());

  @override
  Widget build(BuildContext context) {
    // c.getPostData();

    return Scaffold(
        appBar: AppBar(title: Text('polarStar')),
        body: RefreshIndicator(
            onRefresh: c.refreshPost,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                Obx(() {
                  if (c.dataAvailable) {
                    /**
                     * PostLayout에 controller만 넘겨주면 됨
                     * controller 형식은 RecruitPostController(recruit_controller.dart)와 동일하게
                     * sorted_list에 무조건 정렬해서 넣어야됨
                     * => PostController 써도 되게 만들어놓음_ 2021_08_16
                     * => PostController 갖다 박아놓음_ 2021_08_17
                     */
                    return PostLayout(
                      c: c,
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
              ]),
            )),
        bottomSheet: WriteComment());
  }
}

// 댓글 작성(bottomSheet)
class WriteComment extends StatelessWidget {
  WriteComment({
    Key key,
  }) : super(key: key);

  final PostController c = Get.find();
  String commentPostUrl(String COMMUNITY_ID, String UNIQUE_ID) {
    String commentWriteUrl = '/outside/$COMMUNITY_ID/bid/$UNIQUE_ID';

    return commentWriteUrl;
  }

  @override
  Widget build(BuildContext context) {
    final commentWriteController = TextEditingController();

    return Container(
      height: 60,
      child: Stack(children: [
        Container(
          child: Row(
            children: [
              // 익명 체크
              Container(
                height: 60,
                decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        child: Transform.scale(
                          scale: 1,
                          child: Obx(() => Checkbox(
                                value: c.anonymousCheck.value,
                                onChanged: (value) {
                                  c.changeAnonymous(value);
                                },
                              )),
                        ),
                      ),
                      Text(' 익명'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Obx(() => TextFormField(
                      controller: commentWriteController,
                      decoration: InputDecoration(
                          hintText: c.autoFocusTextForm.value
                              ? '수정하기'
                              : c.isCcomment.value
                                  ? '대댓글 작성'
                                  : '댓글 작성',
                          border: OutlineInputBorder()),
                    )),
              ),
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
                postUrl = c.ccommentUrl.value;
              } else {
                postUrl = commentPostUrl(
                    c.sortedList[0]["COMMUNITY_ID"].toString(),
                    c.sortedList[0]["UNIQUE_ID"].toString());
              }

              print(postUrl);
              commentWriteController.clear();

              if (c.autoFocusTextForm.value) {
                Session()
                    .putX(c.putUrl.value, commentData)
                    .then((value) => c.getPostData());
              } else {
                Session()
                    .postX(postUrl, commentData)
                    .then((value) => c.getPostData());
              }
            },
            child: Icon(
              Icons.send,
              size: 30,
            ),
          ),
        ),
      ]),
    );
  }
}
