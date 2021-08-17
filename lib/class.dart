// 이게 material 위젯 가져오는 거임 거의 항상 쓰인다고 보면 됨
import 'package:flutter/material.dart';

// 얘는 내가 만들어놓은 http 통신 관련 파일
import 'package:polarstar_flutter/session.dart';

// 얘는 상태 관리 해주는 패키지
// class_controller에다가 상태 변화 필요한거 있으면 만들어 쓰면 됨
import 'package:get/get.dart';

import 'classController.dart';

// json 인코드 디코드 할떄 씀(json.decode(response.body))
// 이러면 Map 반환됨
import 'dart:convert';

import '../getXController.dart';

// 클래스 이름은 알아서 하슈
class Class extends StatelessWidget {
  Class({Key key}) : super(key: key);
  final classController = Get.put(ClassController());
  final searchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 보통 MaterialApp 안에 Scaffold로 많이 함 그냥 그대로 하면 됨
    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
      ),
      body: RefreshIndicator(
          onRefresh: classController.refreshPage,
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                // decoration: BoxDecoration(border: Border.all()),
                child: Obx(() {
                  return ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: classController.scrollController.value,
                      itemCount: classController.classesBody.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ClassPreview(
                            body: classController.classesBody[index]);
                      });
                }),
              ),
            ),
            SearchClassBar(searchText: searchText),
          ])), // 여기다 원하는 위젯 만들면 됨
    );
  }
}

class ClassPreview extends StatelessWidget {
  const ClassPreview({Key key, @required this.body}) : super(key: key);
  final Map<dynamic, dynamic> body;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/class/view/${body['CLASS_ID']}');
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          // height: 200,
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  body['CLASS_NAME'],
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  body['CLASS_NUMBER'],
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  body['PROFESSOR'],
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ClassView extends StatelessWidget {
  ClassView({Key key}) : super(key: key);

  final classViewController = Get.put(ClassViewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('polarStar')),
        body: RefreshIndicator(
            onRefresh: classViewController.refreshPage,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                Obx(() {
                  if (classViewController.dataAvailable.value) {
                    return ClassLayout(
                      controller: classViewController,
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
              ]),
            )));
  }
}

class ClassLayout extends StatelessWidget {
  ClassLayout({this.controller});
  var controller;

  @override
  Widget build(BuildContext context) {
    List<Widget> finalClass = [];
    controller.classBody.forEach((item) {
      finalClass.addAll(returningClass(item));
    });
    return Container(
      height: MediaQuery.of(context).size.height - 60 - 100,
      child: SingleChildScrollView(
        child: Column(
          children: finalClass,
        ),
      ),
    );
  }

  List<Widget> returningClass(classItem) {
    return [
      Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
              decoration:
                  BoxDecoration(border: BorderDirectional(top: BorderSide())),
              child: Row(children: [
                // 제목
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // decoration: BoxDecoration(border: Border.all()),
                    child: Text(
                      classItem['CLASS_NAME'],
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
                      classItem['CLASS_NUMBER'],
                      textScaleFactor: 1.5,
                    ),
                  ),
                ),
              ])))
    ];
  }

  // List<Widget> returningClassComment(comment) {
  //   String where = "outside";
  //   String cidUrl = '/$where/cid/${comment['UNIQUE_ID']}';

  //   return [
  //     Padding(
  //       padding: const EdgeInsets.only(bottom: 2.0),
  //       child: Container(
  //         // height: 200,
  //         decoration:
  //             BoxDecoration(border: BorderDirectional(top: BorderSide())),
  //         child: Row(
  //           children: [
  //             // 프사
  //             Padding(
  //               padding: const EdgeInsets.all(4.0),
  //               child: Container(
  //                 height: 20,
  //                 width: 20,
  //                 child: CachedNetworkImage(
  //                     imageUrl:
  //                         'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/${comment['PROFILE_PHOTO']}'),
  //               ),
  //             ),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(comment['PROFILE_NICKNAME']),
  //                 // 댓글 작성 시간
  //                 // Text(
  //                 //   commentTime,
  //                 //   textScaleFactor: 0.6,
  //                 // ),
  //               ],
  //             ),
  //             // 댓글 좋아요 개수 표시
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Row(
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.all(4.0),
  //                     child: Icon(
  //                       Icons.thumb_up,
  //                       size: 15,
  //                       color: Colors.red,
  //                     ),
  //                   ),
  //                   Text(
  //                     comment['LIKES'].toString(),
  //                     textScaleFactor: 0.8,
  //                     style: TextStyle(color: Colors.red),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             Spacer(),

  //             Padding(
  //               padding: const EdgeInsets.all(2.0),
  //               child: InkWell(
  //                   onTap: () {
  //                     c.changeCcomment(cidUrl);
  //                     controller.makeCcommentUrl(
  //                         where, comment["COMMUNITY_ID"], comment['UNIQUE_ID']);
  //                     c.updateAutoFocusTextForm(false);
  //                   },
  //                   child: Obx(
  //                     () => InkWell(
  //                       onTap: () {
  //                         c.changeCcomment(
  //                             'outside/${comment["COMMUNITY_ID"]}/cid/${comment["UNIQUE_ID"]}');
  //                         controller.makeCcommentUrl(
  //                             'board',
  //                             comment["COMMUNITY_ID"].toString(),
  //                             comment["UNIQUE_ID"].toString());
  //                         c.updateAutoFocusTextForm(false);
  //                       },
  //                       child: Icon(
  //                         c.isCcomment.value && c.ccommentUrl.value == cidUrl
  //                             ? Icons.comment
  //                             : Icons.add,
  //                         size: 15,
  //                       ),
  //                     ),
  //                   )),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(2.0),
  //               child: InkWell(
  //                 onTap: () {
  //                   if (comment['MYSELF']) {
  //                     if (c.autoFocusTextForm.value &&
  //                         c.putUrl.value == cidUrl) {
  //                       c.updatePutUrl(where);
  //                     } else {
  //                       c.updatePutUrl(cidUrl);
  //                     }
  //                     controller.getPostData();
  //                   } else {
  //                     Session()
  //                         .getX(
  //                             '/$where/like/${comment["COMMUNITY_ID"]}/id/${comment['UNIQUE_ID']}')
  //                         .then((value) {
  //                       print(value.statusCode);
  //                       switch (value.statusCode) {
  //                         case 200:
  //                           controller.getPostData();
  //                           break;
  //                         case 403:
  //                           Get.snackbar(
  //                               '이미 좋아요를 누른 댓글입니다.', '이미 좋아요를 누른 댓글입니다.',
  //                               snackPosition: SnackPosition.BOTTOM);
  //                           break;

  //                         default:
  //                       }
  //                     });
  //                   }
  //                 },
  //                 child: comment['MYSELF']
  //                     ? Obx(() => Icon(
  //                           c.autoFocusTextForm.value &&
  //                                   c.putUrl.value ==
  //                                       '/$where/cid/${comment['UNIQUE_ID']}'
  //                               ? Icons.comment
  //                               : Icons.edit,
  //                           size: 15,
  //                         ))
  //                     : Icon(
  //                         Icons.thumb_up,
  //                         size: 15,
  //                       ),
  //               ),
  //             ),

  //             Padding(
  //               padding: const EdgeInsets.all(2.0),
  //               child: InkWell(
  //                 onTap: () async {
  //                   if (comment['MYSELF']) {
  //                     Session()
  //                         .deleteX('/$where/cid/${comment['UNIQUE_ID']}')
  //                         .then((value) {
  //                       switch (value.statusCode) {
  //                         case 200:
  //                           Get.snackbar("댓글 삭제 성공", "댓글 삭제 성공",
  //                               snackPosition: SnackPosition.BOTTOM);
  //                           controller.getPostData();
  //                           break;
  //                         default:
  //                           Get.snackbar("댓글 삭제 실패", "댓글 삭제 실패",
  //                               snackPosition: SnackPosition.BOTTOM);
  //                       }
  //                     });
  //                   } else {
  //                     var ARREST_TYPE = await getArrestType();
  //                     Session()
  //                         .getX(
  //                             '/outside/arrest/${comment['COMMUNITY_ID']}/id/${comment['UNIQUE_ID']}?ARREST_TYPE=${ARREST_TYPE}')
  //                         .then((value) {
  //                       switch (value.statusCode) {
  //                         case 200:
  //                           Get.snackbar("댓글 신고 성공", "댓글 신고 성공",
  //                               snackPosition: SnackPosition.BOTTOM);
  //                           controller.getPostData();

  //                           break;
  //                         default:
  //                           Get.snackbar("댓글 신고 실패", "댓글 신고 실패",
  //                               snackPosition: SnackPosition.BOTTOM);
  //                       }
  //                     });
  //                   }
  //                 },
  //                 child: comment['MYSELF']
  //                     ? Icon(
  //                         Icons.delete, // 댓글 삭제
  //                         size: 15,
  //                       )
  //                     : Icon(
  //                         Icons.report, // 댓글 신고
  //                         size: 15,
  //                       ),
  //               ),
  //             ),
  //             comment['MYSELF']
  //                 ? Container()
  //                 : Padding(
  //                     padding: const EdgeInsets.all(2.0),
  //                     child: InkWell(
  //                         onTap: () {
  //                           sendMail(
  //                               comment,
  //                               comment["bid"],
  //                               comment["UNIQUE_ID"],
  //                               0,
  //                               mailWriteController,
  //                               mailController,
  //                               c);
  //                         },
  //                         child: Icon(Icons.mail)),
  //                   ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     Padding(
  //       padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
  //       child: Text(comment['CONTENT']),
  //     ),
  //     Container(
  //       decoration: BoxDecoration(border: Border(bottom: BorderSide())),
  //     ),
  //   ];
  // }

}

class SearchClassBar extends StatelessWidget {
  const SearchClassBar({Key key, @required this.searchText, this.controller})
      : super(key: key);

  final controller;

  final TextEditingController searchText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          TextFormField(
            controller: searchText,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              hintText: 'search',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            ),
            style: TextStyle(),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                    child: InkWell(
                  onTap: () {
                    if (controller == null) {
                      Map arg = {
                        'search': searchText.text,
                      };
                      Get.toNamed('/classSearch', arguments: arg);
                    } else {
                      Get.arguments['search'] = searchText.text;
                      controller.getSearchResult();
                    }
                  },
                  child: Icon(Icons.search_outlined),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchClass extends StatelessWidget {
  SearchClass({Key key}) : super(key: key);
  final searchText = TextEditingController();
  final classSearchController = Get.put(ClassSearchController());

  @override
  Widget build(BuildContext context) {
    classSearchController.getSearchResult();
    return Scaffold(
        appBar: AppBar(title: Text('polarStar')),
        body: RefreshIndicator(
            onRefresh: classSearchController.refreshPage,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                SearchClassBar(
                    searchText: searchText, controller: classSearchController),
                Obx(() {
                  if (classSearchController.dataAvailable.value) {
                    return SearchClassLayout(
                      controller: classSearchController,
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
              ]),
            )));
  }
}

class SearchClassLayout extends StatelessWidget {
  SearchClassLayout({this.controller});
  var controller;

  @override
  Widget build(BuildContext context) {
    List<Widget> results = [];
    controller.resultBody.forEach((item) {
      results.addAll(returningClassPreview(item));
    });
    if (results.length == 0 ? true : false) {
      results.addAll([
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // decoration: BoxDecoration(border: Border.all()),
            child: Text(
              'No Class for ${Get.arguments['search']}',
              textScaleFactor: 2,
            ),
          ),
        )
      ]);
    }
    return Container(
      height: MediaQuery.of(context).size.height - 60 - 100,
      child: SingleChildScrollView(
        child: Column(
          children: results,
        ),
      ),
    );
  }

  List<Widget> returningClassPreview(classItem) {
    return [
      Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
              decoration:
                  BoxDecoration(border: BorderDirectional(top: BorderSide())),
              child: Row(children: [
                // 제목
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // decoration: BoxDecoration(border: Border.all()),
                    child: Text(
                      classItem['CLASS_NAME'],
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
                      classItem['CLASS_NUMBER'],
                      textScaleFactor: 1.5,
                    ),
                  ),
                ),
              ])))
    ];
  }
}
