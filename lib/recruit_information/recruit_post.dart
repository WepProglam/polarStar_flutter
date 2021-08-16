// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:polarstar_flutter/session.dart';

import 'recruit_controller.dart';
import 'package:polarstar_flutter/getXController.dart';
import '../src/post_layout.dart';

class RecruitPost extends GetView<RecruitPostController> {
  RecruitPost({Key key}) : super(key: key);
  // final recruitPostController = Get.put(RecruitPostController());
  final c = Get.put(PostController(
      boardOrRecruit: "outside",
      BOARD_ID: Get.arguments["BOARD_ID"],
      COMMUNITY_ID: Get.arguments["COMMUNITY_ID"]));
  final mailController = Get.put(MailController());
  // final mailWriteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(Get.parameters);

    c.getPostData();

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
  // final RecruitPostController recruitPostController = Get.find();
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

// // 게시글 내용
// class PostContent extends StatelessWidget {
//   PostContent({Key key, this.postItem}) : super(key: key);
//   final RecruitPostController postController = Get.find();
//   final postItem;
//   // 좋아요, 스크랩, 신고 함수

//   @override
//   Widget build(BuildContext context) {

//     print(postItem);

//     return

//   }
// }

// 댓글 위젯
// class CommentWidget extends StatelessWidget {
//   CommentWidget({Key key, this.comment, this.where}) : super(key: key);
//   final comment;
//   final where;
//   final RecruitPostController recruitPostController = Get.find();

//   void sendMail(item, bid, cid, ccid, mailWriteController, mailController, c) {
//     Get.defaultDialog(
//       title: "쪽지 보내기",
//       barrierDismissible: true,
//       content: Column(
//         children: [
//           TextFormField(
//             controller: mailWriteController,
//             keyboardType: TextInputType.text,
//             maxLines: 1,
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           SizedBox(
//             height: 30,
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Container(
//                   height: 20,
//                   width: 20,
//                   child: Transform.scale(
//                     scale: 1,
//                     child: Obx(() {
//                       return Checkbox(
//                         value: c.mailAnonymous.value,
//                         onChanged: (value) {
//                           c.mailAnonymous.value = value;
//                         },
//                       );
//                     }),
//                   ),
//                 ),
//                 Text(' 익명'),
//               ],
//             ),
//           ),
//           ElevatedButton(
//               onPressed: () async {
//                 String content = mailWriteController.text;
//                 if (content.trim().isEmpty) {
//                   Get.snackbar("텍스트를 작성해주세요", "텍스트를 작성해주세요");
//                   return;
//                 }

//                 Map mailData = {
//                   "target_mem_id": '${item["pid"]}',
//                   "bid": '$bid',
//                   "cid": '$cid',
//                   "ccid": '$ccid',
//                   // "mem_unnamed": c.mailAnonymous.value ? '1' : '0',
//                   "mem_unnamed": '1',
//                   "content": '${content.trim()}',
//                   "title": '${item["title"]}'
//                 };
//                 //"target_mem_unnamed": '${item["unnamed"]}',

//                 print(mailData);
//                 var response = await Session().postX("/message", mailData);
//                 switch (response.statusCode) {
//                   case 200:
//                     Get.back();
//                     Get.snackbar("쪽지 전송 완료", "쪽지 전송 완료",
//                         snackPosition: SnackPosition.TOP);
//                     int targetMessageBoxID =
//                         json.decode(response.body)["message_box_id"];
//                     mailController.message_box_id.value = targetMessageBoxID;
//                     await mailController.getMail();
//                     Get.toNamed("/mailBox/sendMail");

//                     break;
//                   case 403:
//                     Get.snackbar("다른 사람의 쪽지함입니다.", "다른 사람의 쪽지함입니다.",
//                         snackPosition: SnackPosition.TOP);
//                     break;

//                   default:
//                     Get.snackbar("업데이트 되지 않았습니다.", "업데이트 되지 않았습니다.",
//                         snackPosition: SnackPosition.TOP);
//                 }

//                 // print(c.mailAnonymous.value);
//                 /*Get.offAndToNamed("/mailBox",
//                                                 arguments: {"unnamed": 1});*/
//               },
//               child: Text("발송"))
//         ],
//       ),
//     );
//     // c.mailAnonymous.value = true;
//     mailWriteController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = Get.put(PostController());
//     final mailWriteController = TextEditingController();
//     final mailController = Get.put(MailController());

    

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: 
//     );
//   }
// }
