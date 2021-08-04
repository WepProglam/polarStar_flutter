import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'session.dart';
import 'getXController.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

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
          future: userController.getUserPage(),
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
                                'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${userController.profileImagePath.value}',
                                fit: BoxFit.fill,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress
                                                  .expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes
                                          : null,
                                    ),
                                  );
                                },
                              ) //수정해야함
                              ),
                        ),
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
                                        textScaleFactor: 0.8,
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
                                        textScaleFactor: 0.8,
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
                                        textScaleFactor: 0.8,
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
                                    textScaleFactor: 0.8,
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
                                  textScaleFactor: 0.8,
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
                              textScaleFactor: 0.8,
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
                            child: Text(
                              "좋아요 누른 글",
                              textScaleFactor: 0.8,
                            ),
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
                            child: Text(
                              "저장한 글",
                              textScaleFactor: 0.8,
                            ),
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
    child: Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black54))),
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
                        'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/${json["profile_photo"]}',
                        fit: BoxFit.fill,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      )),
                  Spacer(
                    flex: 5,
                  ),
                  Expanded(
                    flex: 9,
                    child: Text(
                      "익명",
                      textScaleFactor: 0.8,
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Text(
                      "학교 게시판",
                      textScaleFactor: 0.5,
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
                        textScaleFactor: 1.5,
                      )),
                  Spacer(
                    flex: 11,
                  ),
                  Expanded(
                      flex: 12,
                      child: Text(
                        json["content"],
                        textScaleFactor: 1.0,
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
                        textScaleFactor: 0.5,
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
                          'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/board/${json["photo"]}',
                          fit: BoxFit.fill,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            );
                          },
                        )),
                    Expanded(
                      child: Text(
                        "좋아요${json["like"]} 댓글${json["comments"]} 스크랩${json["scrap"]}",
                        textScaleFactor: 0.5,
                      ),
                      flex: 9,
                    )
                  ])),
          Spacer(
            flex: 4,
          )
        ],
      ),
    ),
  );
}

class Profile extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  final box = GetStorage();
  bool showProgress = false;

  getGalleryImage(UserController userController) async {
    var pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    var img = File(pickedFile.path);
    userController.setProfileImage(pickedFile);
    final Directory extDir = await getApplicationDocumentsDirectory();
    String dirPath = extDir.path;
    final String filePath = '${dirPath}/profile.png';

    final File profileImage = await img.copy(filePath);

    box.write("profileImage", profileImage.path);
  }

  Future upload(XFile imageFile, UserController userController) async {
    var request = Session().multipartReq('PATCH', '/info/modify/photo');

    var pic = await http.MultipartFile.fromPath("photo", imageFile.path);
    print(imageFile.path);
    request.files.add(pic);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
    print(response.body);
    userController
        .setProfileImagePath("uploads/" + jsonDecode(response.body)["src"]);
    print(jsonDecode(response.body)["src"]);
    print(userController.profileImagePath.value);
    /*setState(() {
      showProgress=true;
    });*/
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final userController = Get.put(UserController());

    String pastNickName = box.read("nickname");
    String pastprofileMsg = box.read("profilemsg");

    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (pastNickName == userController.nickName.value.trim() &&
                  pastprofileMsg == userController.profileMsg.value.trim()) {
                Get.snackbar("UPDATE ERROR", "변경된 사항이 없습니다.",
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }

              Map modifyData = {
                'nickname': userController.nickName.value.trim(),
                'profilemsg': userController.profileMsg.value.trim()
              };
              Session().patchX("/info/modify", modifyData).then((value) {
                if (value.statusCode == 401) {
                  //바뀐게 없음
                  Get.snackbar("UPDATE ERROR", "변경된 사항이 없습니다.",
                      snackPosition: SnackPosition.BOTTOM);
                } else {
                  Get.snackbar("UPDATE SUCCESS", "성공적으로 변경되었습니다.",
                      snackPosition: SnackPosition.BOTTOM);

                  print(modifyData);

                  pastNickName = userController.nickName.value.trim();
                  pastprofileMsg = userController.profileMsg.value.trim();

                  box.write("nickname", pastNickName);
                  box.write("profilemsg", pastprofileMsg);

                  print("box read : " +
                      box.read("nickname") +
                      " & " +
                      box.read("profilemsg"));
                }
              });
            },
            label: Text("수정")),
        body: FutureBuilder(
            future: userController.getUserProfile(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                if (showProgress) {
                  return CircularProgressIndicator();
                } else {
                  return Row(children: [
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
                              child: Column(children: [
                                ElevatedButton(onPressed: () {
                                  Get.defaultDialog(
                                      title: "프로필 사진을 변경하시겠습니까?",
                                      textConfirm: "네",
                                      textCancel: "아니오",
                                      confirm: ElevatedButton(
                                          onPressed: () async {
                                            print("confirm!");
                                            await getGalleryImage(
                                                userController);
                                            Get.back();

                                            upload(userController.image.value,
                                                userController);

                                            print(userController
                                                .userProfile.value.photo);
                                          },
                                          child: Text("네")),
                                      cancel: ElevatedButton(
                                          onPressed: () {
                                            print("cancle!");
                                            Get.back();
                                          },
                                          child: Text("아니오")));
                                }, child: Obx(() {
                                  print("시발 왜 안돼");
                                  return Image.network(
                                    'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${userController.profileImagePath.value}',
                                    fit: BoxFit.fill,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes
                                              : null,
                                        ),
                                      );
                                    },
                                  );
                                })),
                              ])),
                          Spacer(
                            flex: 60,
                          ),
                          Expanded(
                            flex: 50,
                            child: Row(
                              children: [
                                Text(
                                  "아이디",
                                  textScaleFactor: 1.5,
                                ),
                                Expanded(child: Obx(() {
                                  return TextFormField(
                                    enabled: false,
                                    initialValue:
                                        userController.userProfile.value.uid,
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  );
                                }))
                              ],
                            ),
                          ),
                          Spacer(
                            flex: 20,
                          ),
                          Expanded(
                            flex: 50,
                            child: Row(children: [
                              Text(
                                "학교",
                                style: TextStyle(fontSize: 30),
                              ),
                              Expanded(
                                child: Obx(() {
                                  return TextFormField(
                                    enabled: false,
                                    initialValue:
                                        userController.userProfile.value.school,
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  );
                                }),
                              )
                            ]),
                          ),
                          Spacer(
                            flex: 20,
                          ),
                          Expanded(
                            flex: 50,
                            child: Row(
                              children: [
                                Text(
                                  "프로필 메시지",
                                  textScaleFactor: 1.5,
                                ),
                                Expanded(
                                    child: TextFormField(
                                  enabled: true,
                                  initialValue: userController
                                      .userProfile.value.profilemsg,
                                  onChanged: (text) {
                                    userController.setProfileMessage(text);
                                  },
                                  validator: (value) {
                                    if (value.trim().isEmpty) {
                                      return '프로필 메시지를 입력하세요';
                                    }
                                    return null;
                                  },
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                ))
                              ],
                            ),
                          ),
                          Spacer(
                            flex: 20,
                          ),
                          Expanded(
                            flex: 50,
                            child: Row(
                              children: [
                                Text(
                                  "닉네임",
                                  textScaleFactor: 1.5,
                                ),
                                Expanded(
                                    child: TextFormField(
                                  enabled: true,
                                  initialValue:
                                      userController.userProfile.value.nickname,
                                  onChanged: (text) {
                                    userController.setNickName(text);
                                  },
                                  validator: (value) {
                                    if (value.trim().isEmpty) {
                                      return '닉네임을 입력하세요';
                                    }
                                    return null;
                                  },
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                ))
                              ],
                            ),
                          ),
                          Spacer(
                            flex: 20,
                          ),
                        ])),
                    Spacer(
                      flex: 80,
                    ),
                  ]);
                }
              } else if (snapshot.hasError) {
                Get.offAndToNamed("back");

                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            }));
  }
}
