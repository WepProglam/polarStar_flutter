import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'session.dart';
import 'getXController.dart';

class Mypage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());
    List<String> postName = ["내가 쓴 글", "좋아요 누른 글", "저장한 글"];

    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
        ),
        body: FutureBuilder(
          future: userController.getUserProfile(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              List<dynamic> userPost = [
                userController.userProfile.value.bids,
                userController.userProfile.value.likes,
                userController.userProfile.value.scrap
              ];

              List<int> userPostLength = [
                userController.userProfile.value.bids.length,
                userController.userProfile.value.likes.length,
                userController.userProfile.value.scrap.length
              ];
              return Column(
                children: [
                  Spacer(
                    flex: 10,
                  ),
                  Expanded(
                    flex: 80,
                    child: Row(
                      children: [
                        Spacer(
                          flex: 10,
                        ),
                        Expanded(
                            flex: 80,
                            child: InkWell(
                              onTap: () {
                                Get.toNamed('/profile/setting');
                              },
                              child: Image.network(
                                'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${userController.userProfile.value.photo}', //수정해야함
                              ),
                            )),
                        Spacer(
                          flex: 20,
                        ),
                        Expanded(
                          flex: 250,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Spacer(flex: 12),
                                Expanded(
                                    flex: 20,
                                    child: Obx(() {
                                      return Text(
                                        '${userController.userProfile.value.nickname} | ${userController.userProfile.value.profilemsg}',
                                        style: TextStyle(fontSize: 20),
                                      );
                                    })),
                                Spacer(
                                  flex: 10,
                                ),
                                Expanded(
                                    flex: 12,
                                    child: Obx(() {
                                      return Text(
                                        '${userController.userProfile.value.uid}',
                                        style: TextStyle(fontSize: 20),
                                      );
                                    })),
                                Spacer(
                                  flex: 6,
                                ),
                                Expanded(
                                    flex: 12,
                                    child: Obx(() {
                                      return Text(
                                        '${userController.userProfile.value.school}',
                                        style: TextStyle(fontSize: 20),
                                      );
                                    })),
                                Spacer(
                                  flex: 8,
                                )
                              ]),
                        )
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 18,
                  ),
                  Expanded(
                      flex: 24,
                      child: Row(
                        children: [
                          Spacer(
                            flex: 10,
                          ),
                          Expanded(
                              flex: 80,
                              child: InkWell(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  child: Text(
                                    "profile",
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                onTap: () {
                                  Get.toNamed('/myPage/profile');
                                },
                              )),
                          Spacer(
                            flex: 8,
                          ),
                          Expanded(
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.black),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25))),
                                child: Text(
                                  "setting",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onTap: () => {print("text")},
                            ),
                            flex: 80,
                          ),
                          Spacer(
                            flex: 182,
                          )
                        ],
                      )),
                  Spacer(
                    flex: 26,
                  ),
                  Expanded(
                    flex: 16,
                    child: Row(
                      children: [
                        Spacer(
                          flex: 27,
                        ),
                        Expanded(
                          flex: 61,
                          child: InkWell(
                            child: Text(
                              "내가 쓴 글",
                              style: TextStyle(fontSize: 15),
                            ),
                            onTap: () {
                              userController.setProfilePostIndex(0);
                            },
                          ),
                        ),
                        Spacer(
                          flex: 63,
                        ),
                        Expanded(
                          flex: 70,
                          child: InkWell(
                            child: Text("좋아요 누른 글",
                                style: TextStyle(fontSize: 15)),
                            onTap: () {
                              userController.setProfilePostIndex(1);
                            },
                          ),
                        ),
                        Spacer(
                          flex: 45,
                        ),
                        Expanded(
                          flex: 54,
                          child: InkWell(
                            child:
                                Text("저장한 글", style: TextStyle(fontSize: 15)),
                            onTap: () {
                              userController.setProfilePostIndex(2);
                            },
                          ),
                        ),
                        Spacer(
                          flex: 40,
                        )
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 4,
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.purple,
                    ),
                  ), //userController.profilePostIndex.value
                  Expanded(
                      flex: 412,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Obx(() {
                            return Column(
                              children: [
                                for (var i = 0;
                                    i <
                                        userPostLength[userController
                                            .profilePostIndex.value];
                                    i++)
                                  Container(
                                      height: 120,
                                      child: getPosts(userPost[userController
                                          .profilePostIndex.value][i]))
                              ],
                            );
                          })))
                ],
              );
            } else if (snapshot.hasError) {
              return Container(child: Text(snapshot.data));
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}

Widget getPosts(json) {
  return InkWell(
    onTap: () {
      String boardUrl = '/board/${json["type"]}/read/${json["bid"]}';
      Map argument = {'boardUrl': boardUrl};
      Get.toNamed('/post', arguments: argument);
    },
    child: Row(
      children: [
        Spacer(
          flex: 6,
        ),
        Expanded(
            flex: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(
                  flex: 7,
                ),
                Expanded(
                  flex: 20,
                  child: Image.network(
                      'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/${json["profile_photo"]}'),
                ),
                Spacer(
                  flex: 5,
                ),
                Expanded(
                  flex: 9,
                  child: Text(
                    "익명",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Text(
                    "학교 게시판",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Spacer(
                  flex: 8,
                )
              ],
            )),
        Spacer(
          flex: 10,
        ),
        Expanded(
            flex: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(
                  flex: 11,
                ),
                Expanded(
                    flex: 18,
                    child: Text(
                      json["title"],
                      style: TextStyle(fontSize: 20),
                    )),
                Spacer(
                  flex: 11,
                ),
                Expanded(
                    flex: 12,
                    child: Text(
                      json["content"],
                      style: TextStyle(fontSize: 12),
                    )),
                Spacer(
                  flex: 7,
                )
              ],
            )),
        json["photo"] == "" //빈 문자열 처리해야함
            ? Expanded(
                flex: 80,
                child: Column(children: [
                  Spacer(
                    flex: 40,
                  ),
                  Expanded(
                    child: Text(
                      "좋아요${json["like"]} 댓글${json["comments"]} 스크랩${json["scrap"]}",
                      style: TextStyle(fontSize: 10),
                    ),
                    flex: 9,
                  )
                ]))
            : Expanded(
                flex: 80,
                child: Column(children: [
                  Expanded(
                    flex: 40,
                    child: Image.network(
                        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/board/${json["photo"]}'),
                  ),
                  Expanded(
                    child: Text(
                      "좋아요${json["like"]} 댓글${json["comments"]} 스크랩${json["scrap"]}",
                      style: TextStyle(fontSize: 10),
                    ),
                    flex: 9,
                  )
                ])),
        Spacer(
          flex: 4,
        )
      ],
    ),
  );
}

class Profile extends StatelessWidget {
  final userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
        ),
        body: Row(children: [
          Spacer(
            flex: 80,
          ),
          Expanded(
              flex: 280,
              child: Column(children: [
                Spacer(
                  flex: 56,
                ),
                Expanded(
                  flex: 200,
                  child: Obx(() {
                    return Image.network(
                        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${userController.userProfile.value.photo}');
                  }),
                ),
                Spacer(
                  flex: 60,
                ),
                Expanded(
                  flex: 50,
                  child: Text(
                    "닉네임",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Spacer(
                  flex: 20,
                ),
                Expanded(
                  flex: 50,
                  child: Text(
                    "이름",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Spacer(
                  flex: 20,
                ),
                Expanded(
                  flex: 50,
                  child: Text(
                    "학교",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Spacer(
                  flex: 20,
                ),
                Expanded(
                  flex: 50,
                  child: Text(
                    "아이디",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Spacer(
                  flex: 20,
                ),
                Expanded(
                  flex: 50,
                  child: Text(
                    "settubg",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Spacer(
                  flex: 20,
                )
              ])),
          Spacer(
            flex: 80,
          ),
        ]));
  }
}
