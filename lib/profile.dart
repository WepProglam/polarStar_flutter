import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'session.dart';
import 'getXController.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Mypage extends StatelessWidget {
  final userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
        ),
        body: RefreshIndicator(
          onRefresh: userController.fetchAll,
          child: Stack(
            children: [
              ListView(),
              Obx(
                () {
                  if (userController.dataAvailableMypage) {
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
                                child: InkWell(onTap: () {
                                  Get.toNamed('/myPage/profile');
                                }, child: Obx(() {
                                  return CircleAvatar(
                                      radius: 100,
                                      backgroundColor: Colors.white,
                                      child: CachedNetworkImage(
                                          imageUrl:
                                              'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${userController.profileImagePath.value}',
                                          fadeInDuration:
                                              Duration(milliseconds: 0),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Image(
                                                  image: AssetImage(
                                                      'image/spinner.gif')),
                                          errorWidget: (context, url, error) {
                                            print(error);
                                            return Icon(Icons.error);
                                          }));
                                }) //수정해야함
                                    ),
                              ),
                              Spacer(
                                flex: 20,
                              ),
                              Expanded(
                                flex: 250,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Spacer(flex: 12),
                                      Expanded(
                                          flex: 20,
                                          child: Text(
                                            '닉네임 : ${userController.profileNickname.value}',
                                            textScaleFactor: 0.7,
                                          )),
                                      Spacer(
                                        flex: 2,
                                      ),
                                      Expanded(
                                          flex: 12,
                                          child: Text(
                                            '프로필 메시지 : ${userController.profileProfilemsg.value}',
                                            textScaleFactor: 0.7,
                                          )),
                                      Spacer(
                                        flex: 2,
                                      ),
                                      Expanded(
                                          flex: 12,
                                          child: Text(
                                            '학교 : ${userController.userProfile["PROFILE_SCHOOL"]}',
                                            textScaleFactor: 0.8,
                                          )),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25))),
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
                                  flex: 8,
                                ),
                                Expanded(
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1, color: Colors.black),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25))),
                                      child: Text(
                                        "쪽지함",
                                        textScaleFactor: 0.8,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onTap: () async {
                                      Get.toNamed("/mailBox");
                                    },
                                  ),
                                  flex: 80,
                                ),
                                Spacer(
                                  flex: 94,
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
                                    userController.dataAvailableMypageWrite
                                        ? print("already downloaded")
                                        : userController.getMineWrite();
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
                                    userController.dataAvailableMypageLike
                                        ? print("already downloaded")
                                        : userController.getMineLike();
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
                                    userController.dataAvailableMypageScrap
                                        ? print("already downloaded")
                                        : userController.getMineScrap();
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
                                  List<bool> dataAvailable = [
                                    userController.dataAvailableMypageWrite,
                                    userController.dataAvailableMypageLike,
                                    userController.dataAvailableMypageScrap
                                  ];

                                  List<RxList> userPost = [
                                    userController.userWriteBid,
                                    userController.userLikeBid,
                                    userController.userScrapBid,
                                  ];

                                  List<int> userPostLength = [
                                    userController.userWriteBid.length,
                                    userController.userLikeBid.length,
                                    userController.userScrapBid.length,
                                  ];

                                  if (dataAvailable[
                                      userController.profilePostIndex.value]) {
                                    return Column(
                                      children: [
                                        for (var i = 0;
                                            i <
                                                userPostLength[userController
                                                    .profilePostIndex.value];
                                            i++)
                                          Container(
                                              height: 120,
                                              child: getPosts(
                                                  userPost[userController
                                                      .profilePostIndex
                                                      .value][i],
                                                  userController))
                                      ],
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                })))
                      ],
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              )
            ],
          ),
        ));
  }
}

Widget getPosts(json, userController) {
  print(json);
  return InkWell(
    onTap: () async {
      Map argument = {
        "BOARD_ID": json["BOARD_ID"],
        "COMMUNITY_ID": json["COMMUNITY_ID"],
      };

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
                      child: CachedNetworkImage(
                          imageUrl:
                              'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/${json["PROFILE_PHOTO"]}',
                          fadeInDuration: Duration(milliseconds: 0),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  Image(image: AssetImage('image/spinner.gif')),
                          errorWidget: (context, url, error) {
                            print(error);
                            return Icon(Icons.error);
                          })),
                  Spacer(
                    flex: 5,
                  ),
                  Expanded(
                    flex: 9,
                    child: Text(
                      "${json["PROFILE_NICKNAME"]}",
                      textScaleFactor: 0.8,
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Text(
                      "${json["COMMUNITY_ID"]} 게시판",
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
                        json["TITLE"].toString(),
                        textScaleFactor: 1.5,
                      )),
                  Spacer(
                    flex: 11,
                  ),
                  Expanded(
                      flex: 12,
                      child: Text(
                        json["CONTENT"].toString(),
                        textScaleFactor: 1.0,
                      )),
                  Spacer(
                    flex: 7,
                  )
                ],
              )),
          json["PHOTO"] == "" || json["PHOTO"] == null //빈 문자열 처리해야함
              ? Expanded(
                  flex: 80,
                  child: Column(children: [
                    Spacer(
                      flex: 40,
                    ),
                    Expanded(
                      child: Text(
                        "좋아요${json["LIKES"]} 댓글${json["COMMENTS"]} 스크랩${json["SCRAPS"]}",
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
                      child: CachedNetworkImage(
                          imageUrl:
                              'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/board/${json["PHOTO"]}',
                          fadeInDuration: Duration(milliseconds: 0),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  Image(image: AssetImage('image/spinner.gif')),
                          errorWidget: (context, url, error) {
                            print(error);
                            return Icon(Icons.error);
                          }),
                    ),
                    /*loadingBuilder: (BuildContext context, Widget child,
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
                          }*/

                    Expanded(
                      child: Text(
                        "좋아요${json["LIKES"]} 댓글${json["COMMENTS"]} 스크랩${json["SCRAPS"]}",
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
  //아직 안 죽은 controller라면 put보단 find로
  final UserController userController = Get.find();

  final ImagePicker _picker = ImagePicker();

  final nicknameController = TextEditingController();

  final profilemessageController = TextEditingController();

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
    switch (response.statusCode) {
      case 200:
        Get.snackbar("사진 변경 성공", "사진 변경 성공",
            snackPosition: SnackPosition.BOTTOM);
        break;
      case 500:
        Get.snackbar("사진 변경 실패", "사진 변경 실패",
            snackPosition: SnackPosition.BOTTOM);
        break;
      default:
    }
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

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
        ),
        //새로 고침 방법 : RefreshIndicator로 감싸고, onrefresh 함수에 Future형을 리턴하는 함수 할당. 기존에 listview로 안되어있으면 STACK으로 감싼 뒤에 listview 위에 추가
        body: RefreshIndicator(
          onRefresh: userController.getMineWrite,
          child: Stack(
            children: [
              ListView(),
              Obx(
                () {
                  if (userController.dataAvailableMypage) {
                    return Row(
                      children: [
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
                                    ElevatedButton(
                                      onPressed: () {
                                        Get.defaultDialog(
                                            title: "프로필 사진을 변경하시겠습니까?",
                                            textConfirm: "네",
                                            textCancel: "아니오",
                                            confirm: ElevatedButton(
                                                onPressed: () async {
                                                  print("confirm!");
                                                  Get.back();

                                                  await getGalleryImage(
                                                      userController);

                                                  upload(
                                                      userController
                                                          .image.value,
                                                      userController);
                                                },
                                                child: Text("네")),
                                            cancel: ElevatedButton(
                                                onPressed: () {
                                                  print("cancle!");
                                                  Get.back();
                                                },
                                                child: Text("아니오")));
                                      },
                                      child: CachedNetworkImage(
                                          imageUrl:
                                              'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${userController.profileImagePath.value}',
                                          fadeInDuration:
                                              Duration(milliseconds: 0),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Image(
                                                  image: AssetImage(
                                                      'image/spinner.gif')),
                                          errorWidget: (context, url, error) {
                                            print(error);
                                            return Icon(Icons.error);
                                          }),
                                    ),
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
                                    Expanded(
                                        child: Text(
                                      "${userController.userProfile["LOGIN_ID"]}",
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
                                child: Row(children: [
                                  Text(
                                    "학교",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${userController.userProfile["PROFILE_SCHOOL"]}",
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
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
                                        child: Text(
                                      userController.profileProfilemsg.value,
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    )),
                                    InkWell(
                                      child: Icon(Icons.edit),
                                      onTap: () {
                                        Get.defaultDialog(
                                          title: "프로필 메세지 변경",
                                          barrierDismissible: true,
                                          content: Column(
                                            children: [
                                              TextFormField(
                                                controller:
                                                    profilemessageController,
                                                keyboardType:
                                                    TextInputType.text,
                                                maxLines: 1,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                  "기존 프로필 메시지 : ${userController.profileProfilemsg.value}"),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    String tempProfileMsg =
                                                        profilemessageController
                                                            .text;

                                                    tempProfileMsg =
                                                        tempProfileMsg.trim();
                                                    if (tempProfileMsg
                                                        .isNotEmpty) {
                                                      if (tempProfileMsg ==
                                                          userController
                                                              .profileProfilemsg
                                                              .value) {
                                                        Get.snackbar(
                                                            "프로필 메세지가 동일합니다.",
                                                            "프로필 메세지가 동일합니다.");
                                                      } else {
                                                        Map modifyData = {
                                                          'PROFILE_MESSAGE':
                                                              tempProfileMsg,
                                                          'PROFILE_NICKNAME':
                                                              userController
                                                                  .profileProfilemsg
                                                                  .value
                                                        };
                                                        Session()
                                                            .patchX(
                                                                "/info/modify",
                                                                modifyData)
                                                            .then((value) {
                                                          switch (value
                                                              .statusCode) {
                                                            case 200:
                                                              userController
                                                                  .setProfilemsg(
                                                                      tempProfileMsg);
                                                              Get.back();
                                                              Get.snackbar(
                                                                  "프로필 메세지 변경",
                                                                  tempProfileMsg);

                                                              break;

                                                            default:
                                                              Get.snackbar(
                                                                  "프로필 메세지 실패",
                                                                  tempProfileMsg);
                                                          }
                                                        });
                                                      }
                                                      print(
                                                          profilemessageController
                                                              .text);
                                                    }
                                                  },
                                                  child: Text("수정하기"))
                                            ],
                                          ),
                                        );
                                        print("수정하기");
                                      },
                                    )
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
                                        child: Text(
                                      userController.profileNickname.value,
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    )),
                                    InkWell(
                                      child: Icon(Icons.edit),
                                      onTap: () {
                                        Get.defaultDialog(
                                          title: "닉네임 변경",
                                          content: Column(
                                            children: [
                                              TextFormField(
                                                controller: nicknameController,
                                                keyboardType:
                                                    TextInputType.text,
                                                maxLines: 1,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                  "기존 닉네임 : ${userController.profileNickname.value}"),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    String tempNickName =
                                                        nicknameController.text;

                                                    tempNickName =
                                                        tempNickName.trim();
                                                    if (tempNickName
                                                        .isNotEmpty) {
                                                      if (tempNickName ==
                                                          userController
                                                              .profileNickname
                                                              .value) {
                                                        Get.snackbar(
                                                            "기존 닉네임과 동일합니다.",
                                                            "기존 닉네임과 동일합니다.");
                                                      } else {
                                                        Map modifyData = {
                                                          'PROFILE_MESSAGE':
                                                              userController
                                                                  .profileProfilemsg
                                                                  .value,
                                                          'PROFILE_NICKNAME':
                                                              tempNickName
                                                        };
                                                        Session()
                                                            .patchX(
                                                                "/info/modify",
                                                                modifyData)
                                                            .then((value) {
                                                          switch (value
                                                              .statusCode) {
                                                            case 200:
                                                              userController
                                                                  .setProfileNickname(
                                                                      tempNickName);
                                                              Get.back();
                                                              Get.snackbar(
                                                                  "닉네임 변경",
                                                                  tempNickName);

                                                              break;

                                                            default:
                                                              Get.snackbar(
                                                                  "프로필 메세지 실패",
                                                                  tempNickName);
                                                          }
                                                        });
                                                      }
                                                      print(
                                                          profilemessageController
                                                              .text);
                                                    }
                                                  },
                                                  child: Text("수정하기"))
                                            ],
                                          ),
                                        );
                                        print("수정하기");
                                      },
                                    )
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
                      ],
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              )
            ],
          ),
        ));
  }
}
