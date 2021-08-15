// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:polarstar_flutter/session.dart';

import 'recruit_controller.dart';
import 'package:polarstar_flutter/getXController.dart';

class RecruitPost extends GetView<RecruitPostController> {
  RecruitPost({Key key}) : super(key: key);
  final recruitPostController = Get.put(RecruitPostController());

  final mailController = Get.put(MailController());
  final mailWriteController = TextEditingController();
  final c = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('polarStar')),
        body: RefreshIndicator(
            onRefresh: recruitPostController.refreshPost,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                Obx(() {
                  if (recruitPostController.dataAvailableRecruitPost) {
                    List<Widget> finalPost = [];
                    recruitPostController.sortedList.forEach((item) {
                      finalPost.addAll(item["DEPTH"] == 0
                          ? returningPost(item)
                          : item["DEPTH"] == 1
                              ? returningComment(item)
                              : returningCC(item));
                    });
                    return Container(
                      height: MediaQuery.of(context).size.height - 60 - 100,
                      child: SingleChildScrollView(
                        child: Column(
                          children: finalPost,
                        ),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
              ]),
            )),
        bottomSheet: WriteComment());
  }

  void totalSend(String url) {
    Session().getX(url).then((value) {
      switch (value.statusCode) {
        case 200:
          Get.snackbar("좋아요 성공", "좋아요 성공", snackPosition: SnackPosition.BOTTOM);
          recruitPostController.getPostData();
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

  List<Widget> returningPost(postItem) {
    return [
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
                          'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/${postItem['PROFILE_PHOTO']}'),
                ),
              ),
              //닉네임, 작성 시간
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(postItem['PROFILE_NICKNAME']),
                  Text(
                    postItem['TIME_CREATED']
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
                    if (postItem['MYSELF']) {
                    } else {
                      totalSend(
                          '/outside/like/${postItem["COMMUNITY_ID"]}/id/${postItem['UNIQUE_ID']}');
                    }
                  },
                  child:
                      postItem['MYSELF'] ? Container() : Icon(Icons.thumb_up),
                ),
              ),
              // 게시글 수정, 스크랩 버튼
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    if (postItem['MYSELF']) {
                      Get.toNamed('/writePost', arguments: postItem);
                    } else {
                      totalSend(
                          '/outside/scrap/${postItem['COMMUNITY_ID']}/id/${postItem['BOARD_ID']}');
                    }
                  },
                  child: postItem['MYSELF']
                      ? Icon(Icons.edit)
                      : Icon(Icons.bookmark),
                ),
              ),
              // 게시글 삭제, 신고 버튼
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () async {
                    // 게시글 삭제
                    if (postItem['MYSELF']) {
                      Session()
                          .deleteX('/outside/bid/${postItem['BOARD_ID']}')
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
                      var ARREST_TYPE = await getArrestType();
                      totalSend(
                          '/outside/arrest/${postItem['COMMUNITY_ID']}/id/${postItem['BOARD_ID']}?ARREST_TYPE=$ARREST_TYPE');
                    }
                  },
                  child: postItem['MYSELF']
                      ? Icon(Icons.delete)
                      : Icon(Icons.report),
                ),
              ),
              //쪽지
              postItem['MYSELF']
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                          onTap: () {
                            sendMail(postItem, postItem["BOARD_ID"], 0, 0,
                                mailWriteController, mailController, c);
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
            postItem['TITLE'],
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
            postItem['CONTENT'],
            textScaleFactor: 1.5,
          ),
        ),
      ),
      //사진
      Container(
        child: postItem['PHOTO'] != '' && postItem['PHOTO'] != "/uploads/board/"
            ? CachedNetworkImage(
                imageUrl:
                    'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${postItem['PHOTO']}')
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
                  if (postItem['MYSELF']) {
                  } else {
                    totalSend(
                        '/outside/like${postItem["COMMUNITY_ID"]}/id/${postItem['BOARD_ID']}');
                  }
                },
                icon: Icon(
                  Icons.thumb_up,
                  size: 20,
                ),
                label: Text(postItem['LIKES'].toString()),
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
                label: Text(postItem['COMMENTS'].toString()),
              ),
              // 게시글 스크랩 수 버튼
              TextButton.icon(
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.yellow[700])),
                onPressed: () {
                  totalSend(
                      '/outSide/scrap/${postItem['COMMUNITY_ID']}/id/${postItem['BOARD_ID']}');
                },
                icon: Icon(
                  Icons.bookmark,
                  size: 20,
                ),
                label: Text(postItem['SCRAPS'].toString()),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> returningComment(comment) {
    String where = "outside";
    String cidUrl = '/$where/cid/${comment['UNIQUE_ID']}';

    return [
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
                          'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/${comment['PROFILE_PHOTO']}'),
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
                      recruitPostController.makeCcommentUrl(
                          where, comment["COMMUNITY_ID"], comment['UNIQUE_ID']);
                      c.updateAutoFocusTextForm(false);
                    },
                    child: Obx(
                      () => InkWell(
                        onTap: () {
                          c.changeCcomment(
                              'outside/${comment["COMMUNITY_ID"]}/cid/${comment["UNIQUE_ID"]}');
                          recruitPostController.makeCcommentUrl(
                              'board',
                              comment["COMMUNITY_ID"].toString(),
                              comment["UNIQUE_ID"].toString());
                          c.updateAutoFocusTextForm(false);
                        },
                        child: Icon(
                          c.isCcomment.value && c.ccommentUrl.value == cidUrl
                              ? Icons.comment
                              : Icons.add,
                          size: 15,
                        ),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: InkWell(
                  onTap: () {
                    if (comment['MYSELF']) {
                      if (c.autoFocusTextForm.value &&
                          c.putUrl.value == cidUrl) {
                        c.updatePutUrl(where);
                      } else {
                        c.updatePutUrl(cidUrl);
                      }
                      recruitPostController.getPostData();
                    } else {
                      Session()
                          .getX(
                              '/$where/like/${comment["COMMUNITY_ID"]}/id/${comment['UNIQUE_ID']}')
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
                  child: comment['MYSELF']
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
                  onTap: () async {
                    if (comment['MYSELF']) {
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
                      var ARREST_TYPE = await getArrestType();
                      Session()
                          .getX(
                              '/outside/arrest/${comment['COMMUNITY_ID']}/id/${comment['UNIQUE_ID']}?ARREST_TYPE=${ARREST_TYPE}')
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
                  child: comment['MYSELF']
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
              comment['MYSELF']
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
        child: Text(comment['CONTENT']),
      ),
      Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide())),
      ),
    ];
  }

  List<Widget> returningCC(var item) {
    return <Widget>[
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
                      'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/${item['PROFILE_PHOTO']}'),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['PROFILE_NICKNAME']),
                  Text(
                    item["TIME_CREATED"],
                    textScaleFactor: 0.6,
                  ),
                ],
              ),
              // 좋아요 개수 표시
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
                      item['LIKES'].toString(),
                      textScaleFactor: 0.8,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              Spacer(),
              // 대댓 수정 or 좋아요
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: InkWell(
                  onTap: () {
                    String putUrl =
                        '/board/${item['COMMUNITY_ID']}/id/${item['UNIQUE_ID']}';
                    if (item['MYSELF']) {
                      if (c.autoFocusTextForm.value &&
                          c.putUrl.value == putUrl) {
                        c.updateAutoFocusTextForm(false);
                        c.updatePutUrl('/board');
                      } else {
                        c.updateAutoFocusTextForm(true);
                        c.updatePutUrl(putUrl);
                      }
                    } else {
                      Session()
                          .getX(
                              '/outside/like/${item['COMMUNITY_ID']}/id/${item['UNIQUE_ID']}')
                          .then((value) {
                        print(value.statusCode);
                        switch (value.statusCode) {
                          case 200:
                            Get.snackbar('좋아요 성공', '좋아요 성공',
                                snackPosition: SnackPosition.BOTTOM);
                            // setState(() {});
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
                  child: item['MYSELF']
                      ? Obx(() => Icon(
                            c.autoFocusTextForm.value &&
                                    c.putUrl.value ==
                                        '/board/${item['COMMUNITY_ID']}/ccid/${item['UNIQUE_ID']}'
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
              // 대댓 삭제 or 신고
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: InkWell(
                    onTap: () async {
                      if (item['MYSELF']) {
                        Session()
                            .deleteX(
                                '/board/${item['COMMUNITY_ID']}/ccid/${item['UNIQUE_ID']}')
                            .then((value) {
                          switch (value.statusCode) {
                            case 200:
                              Get.snackbar("댓글 삭제 성공", "댓글 삭제 성공",
                                  snackPosition: SnackPosition.BOTTOM);
                              // setState(() {});
                              break;
                            default:
                              Get.snackbar("댓글 삭제 실패", "댓글 삭제 실패",
                                  snackPosition: SnackPosition.BOTTOM);
                          }
                        });
                      } else {
                        var ARREST_TYPE = await getArrestType();
                        Session()
                            .getX(
                                '/outside/arrest/${item['COMMUNITY_ID']}/id/${item['UNIQUE_ID']}?ARREST_TYPE=${ARREST_TYPE}')
                            .then((value) {
                          switch (value.statusCode) {
                            case 200:
                              Get.snackbar("신고 성공", "신고 성공",
                                  snackPosition: SnackPosition.BOTTOM);
                              // setState(() {});
                              break;
                            default:
                              Get.snackbar("신고 실패", "신고 실패",
                                  snackPosition: SnackPosition.BOTTOM);
                          }
                        });
                      }
                    },
                    child: item['MYSELF']
                        ? Icon(
                            Icons.delete,
                            size: 15,
                          )
                        : Icon(
                            Icons.report,
                            size: 15,
                          )),
              ),
              item['MYSELF']
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: InkWell(
                        // onTap: () {
                        //   sendMail(
                        //       item, item["COMMUNITY_ID"], item["UNIQUE_ID"], 0);
                        // },
                        child: Icon(Icons.mail),
                      ),
                    )
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 50.0, bottom: 5.0),
        child: Text(item['CONTENT']),
      ),
      Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide())),
      ),
    ];
  }

  Future<int> getArrestType() async {
    var response = await Get.defaultDialog(
        title: "신고 사유 선택",
        content: Column(
          children: [
            InkWell(
              child: Text("게시판 성격에 안맞는 글"),
              onTap: () {
                Get.back(result: 0);
              },
            ),
            InkWell(
              child: Text("선정적인 글"),
              onTap: () {
                Get.back(result: 1);
              },
            ),
            InkWell(
              child: Text("거짓 선동"),
              onTap: () {
                Get.back(result: 2);
              },
            ),
            InkWell(
              child: Text("비윤리적인 글"),
              onTap: () {
                Get.back(result: 3);
              },
            ),
            InkWell(
              child: Text("사기"),
              onTap: () {
                Get.back(result: 4);
              },
            ),
            InkWell(
              child: Text("광고"),
              onTap: () {
                Get.back(result: 5);
              },
            ),
            InkWell(
              child: Text("혐오스러운 글"),
              onTap: () {
                Get.back(result: 6);
              },
            ),
          ],
        ));
    return response;
  }
}

// 댓글 작성(bottomSheet)
class WriteComment extends StatelessWidget {
  const WriteComment({
    Key key,
  }) : super(key: key);

  String commentPostUrl(String COMMUNITY_ID, String UNIQUE_ID) {
    String commentWriteUrl = '/outside/$COMMUNITY_ID/bid/$UNIQUE_ID';

    return commentWriteUrl;
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PostController());
    final recruitPostController = Get.put(RecruitPostController());
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
                postUrl = recruitPostController.ccommentUrl.value;
              } else {
                postUrl = commentPostUrl(
                    recruitPostController.sortedList[0]["COMMUNITY_ID"]
                        .toString(),
                    recruitPostController.sortedList[0]["UNIQUE_ID"]
                        .toString());
              }

              print(postUrl);
              commentWriteController.clear();

              if (c.autoFocusTextForm.value) {
                Session()
                    .putX(c.putUrl.value, commentData)
                    .then((value) => recruitPostController.getPostData());
              } else {
                Session()
                    .postX(postUrl, commentData)
                    .then((value) => recruitPostController.getPostData());
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
