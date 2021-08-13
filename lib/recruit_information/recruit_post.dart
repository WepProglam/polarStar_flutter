import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:polarstar_flutter/session.dart';

import 'recruit_controller.dart';
import 'package:polarstar_flutter/getXController.dart';

class RecruitPost extends GetView<RecruitPostController> {
  const RecruitPost({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recruitPostController = Get.put(RecruitPostController());
    // final mailController = Get.put(MailController());
    // final mailWriteController = TextEditingController();
    // final c = Get.put(PostController());
    recruitPostController.getPostData();

    return Scaffold(
        appBar: AppBar(title: Text('polarStar')),
        body: RefreshIndicator(
            onRefresh: recruitPostController.refreshPost,
            child: Column(children: [
              Expanded(
                child: Obx(() {
                  if (recruitPostController.postBody.isNotEmpty) {
                    return ListView(children: [
                      // 게시글 내용
                      PostContent(
                        postController: recruitPostController,
                      )

                      // 댓글, 대댓글
                    ]);
                  } else {
                    return Container();
                  }
                }),
              ),
            ])),
        bottomSheet: WriteComment());
  }
}

class WriteComment extends StatelessWidget {
  const WriteComment({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                          child: Checkbox(
                            // value: c.anonymousCheck.value
                            value: true,
                            onChanged: (value) {
                              // c.changeAnonymous(value);
                            },
                          ),
                        ),
                      ),
                      Text(' 익명'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  // controller: commentWriteController,

                  decoration: InputDecoration(
                      // hintText: c.autoFocusTextForm.value
                      //     ? '수정하기'
                      //     : c.isCcomment.value
                      //         ? '대댓글 작성'
                      //         : '댓글 작성',
                      hintText: '댓글 작성',
                      border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 15,
          right: 20,
          child: InkWell(
            onTap: () async {
              // Map commentData = {
              //   'content': commentWriteController.text,
              //   'unnamed': c.anonymousCheck.value ? '1' : '0'
              // };

              // String postUrl;
              // if (c.isCcomment.value) {
              //   postUrl = c.ccommentUrl.value;
              // } else {
              //   postUrl = commentPostUrl(arg['boardUrl']);
              // }

              // if (c.autoFocusTextForm.value) {
              //   Session()
              //       .putX(c.putUrl.value, commentData)
              //       .then((value) => setState(() {}));
              // } else {
              //   Session()
              //       .postX(postUrl, commentData)
              //       .then((value) => setState(() {}));
              // }
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

// 게시글 내용
class PostContent extends StatelessWidget {
  const PostContent({
    Key key,
    this.postController,
  }) : super(key: key);
  final postController;

  // 좋아요, 스크랩, 신고 함수
  void totalSend(String url) {
    Session().getX(url).then((value) {
      switch (value.statusCode) {
        case 200:
          Get.snackbar("좋아요 성공", "좋아요 성공", snackPosition: SnackPosition.BOTTOM);
          postController.getPostData();
          break;
        case 403:
          Get.snackbar('이미 좋아요를 누른 게시글입니다', '이미 좋아요를 누른 게시글입니다',
              snackPosition: SnackPosition.BOTTOM);
          break;
        default:
      }
    });
  }

  void sendMail(item, bid, cid, ccid, mailWriteController, mailController, c) {
    Get.defaultDialog(
      title: "쪽지 보내기",
      barrierDismissible: true,
      content: Column(
        children: [
          TextFormField(
            controller: mailWriteController,
            keyboardType: TextInputType.text,
            maxLines: 1,
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: 20,
                  child: Transform.scale(
                    scale: 1,
                    child: Obx(() {
                      return Checkbox(
                        value: c.mailAnonymous.value,
                        onChanged: (value) {
                          c.mailAnonymous.value = value;
                        },
                      );
                    }),
                  ),
                ),
                Text(' 익명'),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                String content = mailWriteController.text;
                if (content.trim().isEmpty) {
                  Get.snackbar("텍스트를 작성해주세요", "텍스트를 작성해주세요");
                  return;
                }

                Map mailData = {
                  "target_mem_id": '${item["pid"]}',
                  "bid": '$bid',
                  "cid": '$cid',
                  "ccid": '$ccid',
                  // "mem_unnamed": c.mailAnonymous.value ? '1' : '0',
                  "mem_unnamed": '1',
                  "content": '${content.trim()}',
                  "title": '${item["title"]}'
                };
                //"target_mem_unnamed": '${item["unnamed"]}',

                print(mailData);
                var response = await Session().postX("/message", mailData);
                switch (response.statusCode) {
                  case 200:
                    Get.back();
                    Get.snackbar("쪽지 전송 완료", "쪽지 전송 완료",
                        snackPosition: SnackPosition.TOP);
                    int targetMessageBoxID =
                        json.decode(response.body)["message_box_id"];
                    mailController.message_box_id.value = targetMessageBoxID;
                    await mailController.getMail();
                    Get.toNamed("/mailBox/sendMail");

                    break;
                  case 403:
                    Get.snackbar("다른 사람의 쪽지함입니다.", "다른 사람의 쪽지함입니다.",
                        snackPosition: SnackPosition.TOP);
                    break;

                  default:
                    Get.snackbar("업데이트 되지 않았습니다.", "업데이트 되지 않았습니다.",
                        snackPosition: SnackPosition.TOP);
                }

                // print(c.mailAnonymous.value);
                /*Get.offAndToNamed("/mailBox",
                                                arguments: {"unnamed": 1});*/
              },
              child: Text("발송"))
        ],
      ),
    );
    // c.mailAnonymous.value = true;
    mailWriteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mailController = Get.put(MailController());
    final mailWriteController = TextEditingController();
    final c = Get.put(PostController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    child: CachedNetworkImage(
                        imageUrl:
                            'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000${postController.postBody['item']['profile_photo']}'),
                  ),
                ),
                //닉네임, 작성 시간
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(postController.postBody['item']['nickname']),
                    Text(
                      postController.postBody['item']['time']
                          .substring(2, 16)
                          .replaceAll(RegExp(r'-'), '/'),
                      textScaleFactor: 0.6,
                    ),
                  ],
                ),
                Spacer(),
                // 게시글 좋아요 버튼
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: InkWell(
                    onTap: () {
                      if (postController.postBody['myself']) {
                      } else {
                        totalSend(
                            '/outside/like/bid/${postController.postBody['item']['bid']}');
                      }
                    },
                    child: postController.postBody['myself']
                        ? Container()
                        : Icon(Icons.thumb_up),
                  ),
                ),
                // 게시글 수정, 스크랩 버튼
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      if (postController.postBody['myself']) {
                        Get.toNamed('/writePost',
                            arguments: postController.postBody);
                      } else {
                        totalSend(
                            '/outSide/scrap/bid/${postController.postBody['item']['bid']}');
                      }
                    },
                    child: postController.postBody['myself']
                        ? Icon(Icons.edit)
                        : Icon(Icons.bookmark),
                  ),
                ),
                // 게시글 삭제, 신고 버튼
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      // 게시글 삭제
                      if (postController.postBody['myself']) {
                        Session()
                            .deleteX(
                                '/board/bid/${postController.postBody['item']['bid']}')
                            .then((value) {
                          print(value.statusCode);
                          switch (value.statusCode) {
                            case 200:
                              print("ㅁㄴㅇㄹ");
                              print("ㅁㄴㅇㄹ");
                              print("ㅁㄴㅇㄹ");
                              Get.back();
                              Get.snackbar("게시글 삭제 성공", "게시글 삭제 성공",
                                  snackPosition: SnackPosition.BOTTOM);

                              break;
                            default:
                              Get.snackbar("게시글 삭제 실패", "게시글 삭제 실패",
                                  snackPosition: SnackPosition.BOTTOM);
                          }
                        });
                      }
                      // 게시글 신고
                      else {
                        totalSend(
                            '/outside/arrest/bid/${postController.postBody['item']['bid']}');
                      }
                    },
                    child: postController.postBody['myself']
                        ? Icon(Icons.delete)
                        : Icon(Icons.report),
                  ),
                ),
                //쪽지
                postController.postBody['myself']
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                            onTap: () {
                              sendMail(
                                  postController.postBody['item'],
                                  postController.postBody['item']["bid"],
                                  0,
                                  0,
                                  mailWriteController,
                                  mailController,
                                  c);
                            },
                            child: Icon(Icons.mail)),
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
              postController.postBody['item']['title'],
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
              postController.postBody['item']['content'],
              textScaleFactor: 1.5,
            ),
          ),
        ),
        //사진
        Container(
          child: postController.postBody['item']['photo'] != ''
              ? CachedNetworkImage(
                  imageUrl:
                      'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${postController.postBody['item']['photo']}')
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
                // 게시글 좋아요 수 버튼
                TextButton.icon(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: () {
                    if (postController.postBody['myself']) {
                    } else {
                      totalSend(
                          '/outside/like/bid/${postController.postBody['item']['bid']}');
                    }
                  },
                  icon: Icon(
                    Icons.thumb_up,
                    size: 20,
                  ),
                  label:
                      Text(postController.postBody['item']['like'].toString()),
                ),
                // 게시글 댓글 수 버튼
                TextButton.icon(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black)),
                  onPressed: () {},
                  icon: Icon(
                    Icons.comment,
                    size: 20,
                  ),
                  label: Text(postController.postBody['item']['comments']),
                ),
                // 게시글 스크랩 수 버튼
                TextButton.icon(
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.yellow[700])),
                  onPressed: () {
                    totalSend(
                        '/outSide/scrap/bid/${postController.postBody['item']['bid']}');
                  },
                  icon: Icon(
                    Icons.bookmark,
                    size: 20,
                  ),
                  label: Text(postController.postBody['item']['scrap']),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
