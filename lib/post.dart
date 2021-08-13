import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'session.dart';
import 'getXController.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Post extends StatefulWidget {
  const Post({Key key}) : super(key: key);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  dynamic arg = Get.arguments;
  final mailWriteController = TextEditingController();
  final mailController = Get.put(MailController());
  final c = Get.put(PostController());

  Future getPostData(String url) async {
    String getUrl;
    // print(url);
    if (url != '') {
      getUrl = url;
    }
    var response = await Session().getX(getUrl);

    print(json.decode(response.body));

    if (response.headers['content-type'] == 'text/html; charset=utf-8') {
      Session().getX('/logout');
      Get.offAllNamed('/login');
      return null;
    } else {
      return response;
    }
  }

  String commentPostUrl(String arg) {
    List<String> argList = arg.split('/');
    String commentWriteUrl = '/board/bid/${argList[4]}';

    return commentWriteUrl;
  }

  void sendMail(item, bid, cid, ccid) {
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
                  "mem_unnamed": c.mailAnonymous.value ? '1' : '0',
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
                        jsonDecode(response.body)["message_box_id"];
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

                print(c.mailAnonymous.value);
                /*Get.offAndToNamed("/mailBox",
                                                arguments: {"unnamed": 1});*/
              },
              child: Text("발송"))
        ],
      ),
    );
    c.mailAnonymous.value = true;
    mailWriteController.clear();
  }

  Widget postWidget(dynamic response) {
    var body = json.decode(response.body);
    var item = body['item'];
    var title = item['title'];
    var content = item['content'];
    var nickname = item['nickname'];
    var time = item['time'].substring(2, 16).replaceAll(RegExp(r'-'), '/');

    final c = Get.put(PostController());

    List<Widget> commentWidgetList = [];

    Widget commentWidget(Map<String, dynamic> comment) {
      List<Widget> ccommentWidgetList = [];
      List<Map> ccommentList = [];

      String ccommentCidUrl = '/board/cid/${comment['comment']['cid']}';

      var commentTime = comment['comment']['time']
          .substring(2, 16)
          .replaceAll(RegExp(r'-'), '/');
      // 대댓
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
                    ),
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
                            ccomment['like'].toString(),
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
                          String putUrl = '/board/ccid/${ccomment['ccid']}';
                          if (ccomment['myself']) {
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
                                .getX('/board/like/ccid/${ccomment['ccid']}')
                                .then((value) {
                              print(value.statusCode);
                              switch (value.statusCode) {
                                case 200:
                                  Get.snackbar('좋아요 성공', '좋아요 성공',
                                      snackPosition: SnackPosition.BOTTOM);
                                  setState(() {});
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
                        child: ccomment['myself']
                            ? Obx(() => Icon(
                                  c.autoFocusTextForm.value &&
                                          c.putUrl.value ==
                                              '/board/ccid/${ccomment['ccid']}'
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
                          onTap: () {
                            if (ccomment['myself']) {
                              Session()
                                  .deleteX('/board/ccid/${ccomment['ccid']}')
                                  .then((value) {
                                switch (value.statusCode) {
                                  case 200:
                                    Get.snackbar("댓글 삭제 성공", "댓글 삭제 성공",
                                        snackPosition: SnackPosition.BOTTOM);
                                    setState(() {});
                                    break;
                                  default:
                                    Get.snackbar("댓글 삭제 실패", "댓글 삭제 실패",
                                        snackPosition: SnackPosition.BOTTOM);
                                }
                              });
                            } else {
                              Session()
                                  .getX(
                                      '/board/arrest/ccid/${ccomment['ccid']}')
                                  .then((value) {
                                switch (value.statusCode) {
                                  case 200:
                                    Get.snackbar("신고 성공", "신고 성공",
                                        snackPosition: SnackPosition.BOTTOM);
                                    setState(() {});
                                    break;
                                  default:
                                    Get.snackbar("신고 실패", "신고 실패",
                                        snackPosition: SnackPosition.BOTTOM);
                                }
                              });
                            }
                          },
                          child: ccomment['myself']
                              ? Icon(
                                  Icons.delete,
                                  size: 15,
                                )
                              : Icon(
                                  Icons.report,
                                  size: 15,
                                )),
                    ),
                    ccomment['myself']
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: InkWell(
                              onTap: () {
                                sendMail(ccomment, ccomment["bid"],
                                    ccomment["cid"], 0);
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
        // print(ccommentList);

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
                  ),
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
                          comment['comment']['like'].toString(),
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
                          c.changeCcomment(ccommentCidUrl);
                          c.makeCcommentUrl('board', comment['comment']['cid']);
                          c.updateAutoFocusTextForm(false);
                        },
                        child: Obx(
                          () => Icon(
                            c.isCcomment.value &&
                                    c.ccommentUrl.value == ccommentCidUrl
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
                        String putUrl =
                            '/board/cid/${comment['comment']['cid']}';
                        if (comment['comment']['myself']) {
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
                                  '/board/like/cid/${comment['comment']['cid']}')
                              .then((value) {
                            print(value.statusCode);
                            switch (value.statusCode) {
                              case 200:
                                setState(() {});
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
                      child: comment['comment']['myself']
                          ? Obx(() => Icon(
                                c.autoFocusTextForm.value &&
                                        c.putUrl.value ==
                                            '/board/cid/${comment['comment']['cid']}'
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
                        if (comment['comment']['myself']) {
                          Session()
                              .deleteX(
                                  '/board/cid/${comment['comment']['cid']}')
                              .then((value) {
                            switch (value.statusCode) {
                              case 200:
                                Get.snackbar("댓글 삭제 성공", "댓글 삭제 성공",
                                    snackPosition: SnackPosition.BOTTOM);
                                setState(() {});
                                break;
                              default:
                                Get.snackbar("댓글 삭제 실패", "댓글 삭제 실패",
                                    snackPosition: SnackPosition.BOTTOM);
                            }
                          });
                        } else {
                          Session()
                              .getX(
                                  '/board/arrest/cid/${comment['comment']['cid']}')
                              .then((value) {
                            switch (value.statusCode) {
                              case 200:
                                Get.snackbar("댓글 신고 성공", "댓글 신고 성공",
                                    snackPosition: SnackPosition.BOTTOM);

                                break;
                              default:
                                Get.snackbar("댓글 신고 실패", "댓글 신고 실패",
                                    snackPosition: SnackPosition.BOTTOM);
                            }
                          });
                        }
                      },
                      child: comment['comment']['myself']
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
                  comment['comment']['myself']
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: InkWell(
                              onTap: () {
                                sendMail(
                                    comment['comment'],
                                    comment['comment']["bid"],
                                    comment['comment']["cid"],
                                    0);
                              },
                              child: Icon(Icons.mail)),
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
                  // 게시글 좋아요 버튼
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: InkWell(
                      onTap: () {
                        if (body['myself']) {
                        } else {
                          Session()
                              .getX('/board/like/bid/${body['item']['bid']}')
                              .then((value) {
                            switch (value.statusCode) {
                              case 200:
                                Get.snackbar("좋아요 성공", "좋아요 성공",
                                    snackPosition: SnackPosition.BOTTOM);
                                setState(() {});

                                break;
                              case 403:
                                Get.snackbar(
                                    '이미 좋아요를 누른 게시글입니다', '이미 좋아요를 누른 게시글입니다',
                                    snackPosition: SnackPosition.BOTTOM);
                                break;
                              default:
                            }
                          });
                        }
                      },
                      child:
                          body['myself'] ? Container() : Icon(Icons.thumb_up),
                    ),
                  ),
                  // 게시글 수정, 스크랩 버튼
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        if (body['myself']) {
                          Get.toNamed('/writePost', arguments: body);
                        } else {
                          Session()
                              .getX('/board/scrap/bid/${body['item']['bid']}')
                              .then((value) {
                            switch (value.statusCode) {
                              case 200:
                                Get.snackbar("스크랩 성공", "스크랩 성공",
                                    snackPosition: SnackPosition.BOTTOM);
                                setState(() {});
                                break;
                              case 403:
                                Get.snackbar(
                                    '이미 스크랩 한 게시글입니다', '이미 스크랩 한 게시글입니다',
                                    snackPosition: SnackPosition.BOTTOM);
                                break;
                              default:
                            }
                          });
                        }
                      },
                      child: body['myself']
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
                        if (body['myself']) {
                          Session()
                              .deleteX('/board/bid/${body['item']['bid']}')
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
                          Session()
                              .getX('/board/arrest/bid/${body['item']['bid']}')
                              .then((value) {
                            print(value.statusCode);
                            switch (value.statusCode) {
                              case 200:
                                Get.snackbar("게시글 신고 성공", "게시글 신고 성공",
                                    snackPosition: SnackPosition.BOTTOM);

                                break;
                              case 403:
                                Get.snackbar('이미 신고한 게시글입니다', '이미 신고한 게시글입니다',
                                    snackPosition: SnackPosition.BOTTOM);
                                break;
                              default:
                            }
                          });
                        }
                      },
                      child: body['myself']
                          ? Icon(Icons.delete)
                          : Icon(Icons.report),
                    ),
                  ),
                  //쪽지
                  body['myself']
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                              onTap: () {
                                sendMail(item, item["bid"], 0, 0);
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
          //사진
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
                  // 게시글 좋아요 수 버튼
                  TextButton.icon(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.red)),
                    onPressed: () {
                      if (body['myself']) {
                      } else {
                        Session()
                            .getX('/board/like/bid/${item['bid']}')
                            .then((value) {
                          switch (value.statusCode) {
                            case 200:
                              Get.snackbar("좋아요 성공", "좋아요 실패",
                                  snackPosition: SnackPosition.BOTTOM);
                              setState(() {});

                              break;
                            case 403:
                              Get.snackbar(
                                  '이미 좋아요를 누른 게시글입니다', '이미 좋아요를 누른 게시글입니다',
                                  snackPosition: SnackPosition.BOTTOM);
                              break;
                            default:
                          }
                        });
                      }
                    },
                    icon: Icon(
                      Icons.thumb_up,
                      size: 20,
                    ),
                    label: Text(item['like'].toString()),
                  ),
                  // 게시글 댓글 수 버튼
                  TextButton.icon(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    onPressed: () {
                      c.updateAutoFocusTextForm(false);
                    },
                    icon: Icon(
                      Icons.comment,
                      size: 20,
                    ),
                    label: Text(body['item']['comments']),
                  ),
                  // 게시글 스크랩 수 버튼
                  TextButton.icon(
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.yellow[700])),
                    onPressed: () {
                      Session()
                          .getX('/board/scrap/bid/${body['item']['bid']}')
                          .then((value) {
                        switch (value.statusCode) {
                          case 200:
                            Get.snackbar("게시글 스크랩 성공", "게시글 스크랩 성공",
                                snackPosition: SnackPosition.BOTTOM);
                            setState(() {});

                            break;
                          case 403:
                            Get.snackbar('이미 스크랩 한 게시글입니다', '이미 스크랩 한 게시글입니다',
                                snackPosition: SnackPosition.BOTTOM);
                            break;
                          default:
                        }
                      });
                    },
                    icon: Icon(
                      Icons.bookmark,
                      size: 20,
                    ),
                    label: Text(body['item']['scrap']),
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
          ),
          Container(
            height: 60,
            child: null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var commentWriteController = TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
        ),
        body: FutureBuilder(
            future: getPostData(arg['boardUrl']),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return CircularProgressIndicator();
              } else {
                return Container(child: postWidget(snapshot.data));
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
                    height: 60,
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
                      autovalidate: c.autoFocusTextForm.value,
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
                    postUrl = c.ccommentUrl.value;
                  } else {
                    postUrl = commentPostUrl(arg['boardUrl']);
                  }

                  if (c.autoFocusTextForm.value) {
                    Session()
                        .putX(c.putUrl.value, commentData)
                        .then((value) => setState(() {}));
                  } else {
                    Session()
                        .postX(postUrl, commentData)
                        .then((value) => setState(() {}));
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
