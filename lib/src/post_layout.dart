// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart';

import 'package:polarstar_flutter/session.dart';

import 'package:polarstar_flutter/getXController.dart';

class PostLayout extends StatelessWidget {
  PostLayout({this.c});

  var c;

  MailController mailController = Get.find();
  final mailWriteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Widget> finalPost = [];
    c.sortedList.forEach((item) {
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
                      c.totalSend(
                          '/like/${postItem["COMMUNITY_ID"]}/id/${postItem['UNIQUE_ID']}');
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
                      c.totalSend(
                          '/scrap/${postItem['COMMUNITY_ID']}/id/${postItem['BOARD_ID']}');
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
                          .deleteX(
                              '/${c.boardOrRecruit}/${postItem['COMMUNITY_ID']}/bid/${postItem['BOARD_ID']}')
                          .then((value) {
                        print(value.statusCode);
                        switch (value.statusCode) {
                          case 200:
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
                      var ARREST_TYPE = await c.getArrestType();
                      c.totalSend(
                          '/arrest/${postItem['COMMUNITY_ID']}/id/${postItem['BOARD_ID']}?ARREST_TYPE=$ARREST_TYPE');
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
                            c.sendMail(
                                postItem["UNIQUE_ID"],
                                postItem["COMMUNITY_ID"],
                                mailWriteController,
                                mailController);
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
        child: postItem['PHOTO'] != '' && postItem['PHOTO'] != null
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
                    c.totalSend(
                        '/like${postItem["COMMUNITY_ID"]}/id/${postItem['BOARD_ID']}');
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
                  c.totalSend(
                      '/scrap/${postItem['COMMUNITY_ID']}/id/${postItem['BOARD_ID']}');
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
    // String where = "outside";
    String cidUrl = '/${c.boardOrRecruit}/cid/${comment['UNIQUE_ID']}';

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
                      c.isCcomment.value = !c.isCcomment.value;
                      c.makeCcommentUrl(
                          comment["COMMUNITY_ID"], comment['UNIQUE_ID']);
                      c.autoFocusTextForm.value = false;
                    },
                    child: Obx(
                      () => InkWell(
                        onTap: () {
                          c.changeCcomment(
                              '${c.boardOrRecruit}/${comment["COMMUNITY_ID"]}/cid/${comment["UNIQUE_ID"]}');
                          c.makeCcommentUrl(
                              comment["COMMUNITY_ID"], comment["UNIQUE_ID"]);
                          c.autoFocusTextForm.value = false;
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
                  onTap: () async {
                    if (comment['MYSELF']) {
                      if (c.autoFocusTextForm.value &&
                          c.putUrl.value == cidUrl) {
                        c.putUrl.value = c.boardOrRecruit;
                        c.updatePutUrl(c.boardOrRecruit);
                      } else {
                        c.putUrl.value = cidUrl;
                        c.updatePutUrl(cidUrl);
                      }
                      c.getPostData();
                    } else {
                      c.isCcomment.value = !c.isCcomment.value;
                      await c.totalSend(
                          '/like/${comment["COMMUNITY_ID"]}/id/${comment['UNIQUE_ID']}');
                    }
                  },
                  child: comment['MYSELF']
                      ? Obx(() => Icon(
                            c.autoFocusTextForm.value &&
                                    c.putUrl.value ==
                                        '/${c.boardOrRecruit}/cid/${comment['UNIQUE_ID']}'
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
                          .deleteX(
                              '/${c.boardOrRecruit}/${comment['COMMUNITY_ID']}/cid/${comment['UNIQUE_ID']}')
                          .then((value) {
                        switch (value.statusCode) {
                          case 200:
                            Get.snackbar("댓글 삭제 성공", "댓글 삭제 성공",
                                snackPosition: SnackPosition.BOTTOM);
                            c.getPostData();
                            break;
                          default:
                            Get.snackbar("댓글 삭제 실패", "댓글 삭제 실패",
                                snackPosition: SnackPosition.BOTTOM);
                        }
                      });
                    } else {
                      var ARREST_TYPE = await c.getArrestType();
                      await c.totalSend(
                          '/arrest/${comment["COMMUNITY_ID"]}/id/${comment['UNIQUE_ID']}?ARREST_TYPE=$ARREST_TYPE');
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
                            c.sendMail(
                                comment["UNIQUE_ID"],
                                comment["COMMUNITY_ID"],
                                mailWriteController,
                                mailController);
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

  List<Widget> returningCC(item) {
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
                  onTap: () async {
                    String putUrl =
                        '/${c.boardOrRecruit}/${item['COMMUNITY_ID']}/ccid/${item['UNIQUE_ID']}';
                    if (item['MYSELF']) {
                      if (c.autoFocusTextForm.value &&
                          c.putUrl.value == putUrl) {
                        c.autoFocusTextForm.value = false;
                        c.putUrl.value = "/${c.boardOrRecruit}";
                      } else {
                        c.autoFocusTextForm.value = true;
                        c.putUrl.value = putUrl;
                      }
                    } else {
                      await c.totalSend(
                          '/like/${item["COMMUNITY_ID"]}/id/${item['UNIQUE_ID']}');
                    }
                  },
                  child: item['MYSELF']
                      ? Obx(() => Icon(
                            c.autoFocusTextForm.value &&
                                    c.putUrl.value ==
                                        '//${c.boardOrRecruit}/${item['COMMUNITY_ID']}/ccid/${item['UNIQUE_ID']}'
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
                                '/${c.boardOrRecruit}/${item['COMMUNITY_ID']}/ccid/${item['UNIQUE_ID']}')
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
                        var ARREST_TYPE = await c.getArrestType();
                        await c.totalSend(
                            '/arrest/${item["COMMUNITY_ID"]}/id/${item['UNIQUE_ID']}?ARREST_TYPE=$ARREST_TYPE');
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
                        onTap: () {
                          c.sendMail(item["UNIQUE_ID"], item["COMMUNITY_ID"],
                              mailWriteController, mailController);
                        },
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
}
