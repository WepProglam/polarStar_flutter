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
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                Obx(() {
                  if (recruitPostController.dataAvailableRecruitPost) {
                    return PostContent();
                  } else {
                    recruitPostController.getPostData();
                    return CircularProgressIndicator();
                  }
                }),
                /*Obx(() {
                  if (recruitPostController.postBody[0]['COMMENTS'] != null) {
                    List<Widget> commentList = [];
                    for (var item in recruitPostController
                        .postBody[0]['COMMENTS'].entries) {
                      commentList.addNonNull(CommentWidget(
                          comment: item.value['comment'], where: 'outside'));
                    }
                    return Column(children: commentList);
                  } else {
                    return Container();
                  }
                }),*/
              ]),
            )),
        bottomSheet: WriteComment());
  }
}

// 댓글 작성(bottomSheet)
class WriteComment extends StatelessWidget {
  const WriteComment({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PostController());
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
  PostContent({Key key}) : super(key: key);
  final RecruitPostController postController = Get.find();

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

    print(postController.postBody);

    return Container(
      child: Column(
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
                              'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000${postController.postBody['PROFILE_PHOTO']}'),
                    ),
                  ),
                  //닉네임, 작성 시간
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(postController.postBody['PROFILE_NICKNAME']),
                      Text(
                        postController.postBody['TIME_CREATED']
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
                        if (postController.postBody['MYSELF']) {
                        } else {
                          totalSend(
                              '/outside/like/bid/${postController.postBody['UNIQUE_ID']}');
                        }
                      },
                      child: postController.postBody['MYSELF']
                          ? Container()
                          : Icon(Icons.thumb_up),
                    ),
                  ),
                  // 게시글 수정, 스크랩 버튼
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        if (postController.postBody['MYSELF']) {
                          Get.toNamed('/writePost',
                              arguments: postController.postBody);
                        } else {
                          totalSend(
                              '/outside/scrap/bid/${postController.postBody['BOARD_ID']}');
                        }
                      },
                      child: postController.postBody['MYSELF']
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
                        if (postController.postBody['MYSELF']) {
                          Session()
                              .deleteX(
                                  '/outside/bid/${postController.postBody['BOARD_ID']}')
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
                              '/outside/arrest/bid/${postController.postBody['BOARD_ID']}');
                        }
                      },
                      child: postController.postBody['MYSELF']
                          ? Icon(Icons.delete)
                          : Icon(Icons.report),
                    ),
                  ),
                  //쪽지
                  postController.postBody['MYSELF']
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                              onTap: () {
                                sendMail(
                                    postController.postBody,
                                    postController.postBody["BOARD_ID"],
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
                postController.postBody['TITLE'],
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
                postController.postBody['CONTENT'],
                textScaleFactor: 1.5,
              ),
            ),
          ),
          //사진
          Container(
            child: postController.postBody['PHOTO'] != '' &&
                    postController.postBody['PHOTO'] != "/uploads/board/"
                ? CachedNetworkImage(
                    imageUrl:
                        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${postController.postBody['PHOTO']}')
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
                      if (postController.postBody['MYSELF']) {
                      } else {
                        totalSend(
                            '/outside/like/bid/${postController.postBody['BOARD_ID']}');
                      }
                    },
                    icon: Icon(
                      Icons.thumb_up,
                      size: 20,
                    ),
                    label: Text(postController.postBody['LIKES'].toString()),
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
                    label: Text(postController.postBody['COMMENTS'].toString()),
                  ),
                  // 게시글 스크랩 수 버튼
                  TextButton.icon(
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.yellow[700])),
                    onPressed: () {
                      totalSend(
                          '/outSide/scrap/bid/${postController.postBody['BOARD_ID']}');
                    },
                    icon: Icon(
                      Icons.bookmark,
                      size: 20,
                    ),
                    label: Text(postController.postBody['SCRAPS'].toString()),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 댓글 위젯
class CommentWidget extends StatelessWidget {
  const CommentWidget({Key key, this.comment, this.where}) : super(key: key);
  final comment;
  final where;

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
    final c = Get.put(PostController());
    final mailWriteController = TextEditingController();
    final mailController = Get.put(MailController());
    final recruitPostController = Get.put(RecruitPostController());

    String cidUrl = '/$where/cid/${comment['UNIQUE_ID']}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Container(
            // height: 200,
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
                    child: CachedNetworkImage(
                        imageUrl:
                            'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000${comment['PROFILE_PHOTO']}'),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment['PROFILE_NICKNAME']),
                    // 댓글 작성 시간
                    // Text(
                    //   commentTime,
                    //   textScaleFactor: 0.6,
                    // ),
                  ],
                ),
                // 댓글 좋아요 개수 표시
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.thumb_up,
                          size: 15,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        comment['LIKES'].toString(),
                        textScaleFactor: 0.8,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),

                Spacer(),

                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                      onTap: () {
                        c.changeCcomment(cidUrl);
                        c.makeCcommentUrl(where, comment["COMMUNITY_ID"],
                            comment['UNIQUE_ID']);
                        c.updateAutoFocusTextForm(false);
                      },
                      child: Obx(
                        () => Icon(
                          c.isCcomment.value && c.ccommentUrl.value == cidUrl
                              ? Icons.comment
                              : Icons.add,
                          size: 15,
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: () {
                      if (comment['myself']) {
                        if (c.autoFocusTextForm.value &&
                            c.putUrl.value == cidUrl) {
                          c.updatePutUrl(where);
                        } else {
                          c.updatePutUrl(cidUrl);
                        }
                        recruitPostController.getPostData();
                      } else {
                        Session()
                            .getX('/$where/like/cid/${comment['UNIQUE_ID']}')
                            .then((value) {
                          print(value.statusCode);
                          switch (value.statusCode) {
                            case 200:
                              recruitPostController.getPostData();
                              break;
                            case 403:
                              Get.snackbar(
                                  '이미 좋아요를 누른 댓글입니다.', '이미 좋아요를 누른 댓글입니다.',
                                  snackPosition: SnackPosition.BOTTOM);
                              break;

                            default:
                          }
                        });
                      }
                    },
                    child: comment['myself']
                        ? Obx(() => Icon(
                              c.autoFocusTextForm.value &&
                                      c.putUrl.value ==
                                          '/$where/cid/${comment['UNIQUE_ID']}'
                                  ? Icons.comment
                                  : Icons.edit,
                              size: 15,
                            ))
                        : Icon(
                            Icons.thumb_up,
                            size: 15,
                          ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: InkWell(
                    onTap: () {
                      if (comment['myself']) {
                        Session()
                            .deleteX('/$where/cid/${comment['UNIQUE_ID']}')
                            .then((value) {
                          switch (value.statusCode) {
                            case 200:
                              Get.snackbar("댓글 삭제 성공", "댓글 삭제 성공",
                                  snackPosition: SnackPosition.BOTTOM);
                              recruitPostController.getPostData();
                              break;
                            default:
                              Get.snackbar("댓글 삭제 실패", "댓글 삭제 실패",
                                  snackPosition: SnackPosition.BOTTOM);
                          }
                        });
                      } else {
                        Session()
                            .getX('/$where/arrest/cid/${comment['UNIQUE_ID']}')
                            .then((value) {
                          switch (value.statusCode) {
                            case 200:
                              Get.snackbar("댓글 신고 성공", "댓글 신고 성공",
                                  snackPosition: SnackPosition.BOTTOM);
                              recruitPostController.getPostData();

                              break;
                            default:
                              Get.snackbar("댓글 신고 실패", "댓글 신고 실패",
                                  snackPosition: SnackPosition.BOTTOM);
                          }
                        });
                      }
                    },
                    child: comment['myself']
                        ? Icon(
                            Icons.delete, // 댓글 삭제
                            size: 15,
                          )
                        : Icon(
                            Icons.report, // 댓글 신고
                            size: 15,
                          ),
                  ),
                ),
                comment['myself']
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: InkWell(
                            onTap: () {
                              sendMail(
                                  comment,
                                  comment["bid"],
                                  comment["UNIQUE_ID"],
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
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
          child: Text(comment['content']),
        ),
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide())),
        ),
      ],
    );
  }
}
