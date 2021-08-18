// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'model/User.dart';
import 'session.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Controller extends GetxController {
  // mainPage
  var mainPageIndex = 0.obs;

  updateMainPage(int index) {
    mainPageIndex.value = index;
    update();
  }

  // board
  var isBoardEmpty = false.obs;

  changeIsBoardEmpty(bool value) {
    isBoardEmpty.value = value;
    update();
  }
}

class UserController extends GetxController {
  Rx<User> userPage = new User().obs;
  Rx<int> profilePostIndex = 0.obs;
  Rx<Post> postPreview = new Post().obs;

  Map<dynamic, dynamic> userProfile = {}.obs; //유저 기본 정보
  RxList userWriteBid = [].obs; //유저 작성 글
  RxList userLikeBid = [].obs; //유저 좋아요 글
  RxList userScrapBid = [].obs; //유저 스크랩 글

  var _dataAvailableMypage = false.obs;
  var _dataAvailableMypageWrite = false.obs;
  var _dataAvailableMypageLike = false.obs;
  var _dataAvailableMypageScrap = false.obs;

  var image = Rx<XFile>(null); //프사 바꿀때 쓰는 Obs

  var profileImagePath = Rx<String>('');
  var profileNickname = Rx<String>('');
  var profileProfilemsg = Rx<String>('');

  final box = GetStorage();

  //내가 쓴 글 목록 불러옴
  Future<void> getMineWrite() async {
    print("get mine write");
    _dataAvailableMypageWrite.value = false;
    var response = await Session().getX("/info");
    var responseBody = jsonDecode(response.body);
    var dataResponse = responseBody["PROFILE"];

    userWriteBid.value = responseBody["WritePost"];
    //첫 화면에 유저 정보랑 쓴 글 같이 띄워야 되서 같이 유저 정보랑 같이 불러옴
    userProfile = {
      "PROFILE_ID": dataResponse["PROFILE_ID"],
      "uid": "곧 삭제할 예정",
      "IS_DELETED": dataResponse["IS_DELETED"],
      "PROFILE_SCHOOL": dataResponse["PROFILE_SCHOOL"],
      "ACCUSES": dataResponse["ACCUSES"],
      "userType": 0
    };

    profileImagePath.value = "uploads/" + dataResponse["PROFILE_PHOTO"]; //프사 경로
    profileNickname.value = dataResponse["PROFILE_NICKNAME"]; //닉네임 경로
    profileProfilemsg.value = dataResponse["PROFILE_MESSAGE"]; //프메 경로

    _dataAvailableMypage.value = true;
    _dataAvailableMypageWrite.value = true;
  }

  //유저 좋아요 글
  Future<void> getMineLike() async {
    var response = await Session().getX("/info/like");
    if (response.statusCode == 404) {
      userLikeBid.clear();
    } else {
      var responseBody = jsonDecode(response.body);
      userLikeBid.value = responseBody["LIKE"];
    }
    _dataAvailableMypageLike.value = true;
  }

  //유저 스크랩 글
  Future<void> getMineScrap() async {
    var response = await Session().getX("/info/scrap");

    if (response.statusCode == 404) {
      userScrapBid.clear();
    } else {
      var responseBody = jsonDecode(response.body);
      userScrapBid.value = responseBody["SCRAP"];
    }
    _dataAvailableMypageScrap.value = true;
  }

  void setProfileImage(img) {
    image.value = img;
  }

  @override
  void onInit() async {
    super.onInit();
    await getMineWrite();
    profilePostIndex.value = 0;

    //사용자가 인덱스 변경 시 매번 다운 받았는지 체크 후, 안받았으면 http 요청 보냄
    ever(profilePostIndex, (_) async {
      switch (profilePostIndex.value) {
        case 0:
          if (!dataAvailableMypage) {
            getMineWrite();
          }
          break;

        case 1:
          if (!dataAvailableMypageLike) {
            getMineLike();
          }
          break;

        case 2:
          if (!dataAvailableMypageScrap) {
            getMineScrap();
          }
          break;
        default:
          if (!dataAvailableMypage) {
            getMineWrite();
          }
          break;
      }
    });
  }

  //한번에 세트로 다 불러오는 함수
  Future<void> fetchAll() async {
    // _dataAvailableMypageWrite.value = false;
    // _dataAvailableMypageLike.value = false;
    // _dataAvailableMypageScrap.value = false;
    await getMineWrite();
  }

  bool get dataAvailableMypage => _dataAvailableMypage.value;
  bool get dataAvailableMypageWrite => _dataAvailableMypageWrite.value;
  bool get dataAvailableMypageLike => _dataAvailableMypageLike.value;
  bool get dataAvailableMypageScrap => _dataAvailableMypageScrap.value;
}

class MailController extends GetxController {
  RxList mailBox = [].obs; //쪽지함
  RxInt MAIL_BOX_ID = 0.obs; //쪽지함 id
  RxList mailSendData = [].obs; //쪽지내역
  RxMap opponentProfile = {}.obs; //쪽지 상대방 프로필

  var _dataAvailableMailPage = false.obs; //쪽지함 데이터가 가능한지 여부
  var _dataAvailableMailSendPage = false.obs; //쪽지 보내는 페이지 데이터 가능한지 여부

  @override
  void onInit() async {
    super.onInit();
    getMailBox(); //mailcontroller가 처음 생성될 때가 쪽지함 볼때라 init에 넣어둠
  }

  Future<void> getMailBox() async {
    //쪽지함 보기
    var response = await Session().getX("/message");
    var json = jsonDecode(response.body);

    if (json.isEmpty) {
      mailBox.value = [];
    } else {
      print(json);
      mailBox.value = json;
    }
    _dataAvailableMailPage.value = true;
  }

  void setDataAvailableMailSendPageFalse() {
    /**
     * 쪽지 페이지가 항상 true면 1번 쪽지함 후 2번 쪽지함 봐도 1번으로 나옴
     * => 매번 뒤로가기 누를때마다 이 함수로 불가능으로 바꿈
     */
    _dataAvailableMailSendPage.value = false;
  }

  Future<void> getMail() async {
    //쪽지 내역 보기

    print(MAIL_BOX_ID.value);
    print(MAIL_BOX_ID.value);
    print(MAIL_BOX_ID.value);

    print("/message/${MAIL_BOX_ID.value}");
    var response = await Session().getX("/message/${MAIL_BOX_ID.value}");
    print(response.body);
    var json = jsonDecode(response.body);
    mailSendData.value = json["MAIL"];
    opponentProfile.value = json["TARGET_PROFILE"];
    _dataAvailableMailSendPage.value = true;
  }

  bool get dataAvailableMailPage => _dataAvailableMailPage.value;
  bool get dataAvailableMailSendPage => _dataAvailableMailSendPage.value;
}

class NotiController extends GetxController {
  Rx<Map<String, dynamic>> notiObs = Rx<Map<String, dynamic>>({
    "notification": {"title": "제목", "body": "텍스트"}
  });
  Rx<String> tokenFCM = Rx<String>("");

  @override
  void onInit() async {
    print("ON INIT");
    super.onInit();
    var firebaseMessaging = FirebaseMessaging.instance;
    var firstToken = await firebaseMessaging.getToken();
    tokenFCM.value = firstToken;
    firebaseCloudMessaging_Listeners();
  }

  // ignore: non_constant_identifier_names
  void firebaseCloudMessaging_Listeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification.body);
      print(event.notification.body);
      Get.snackbar(event.notification.body, event.notification.body,
          snackPosition: SnackPosition.TOP);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  /*void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }*/
}

class PostController extends GetxController {
  PostController({this.boardOrRecruit, this.COMMUNITY_ID, this.BOARD_ID});
  Rx<bool> _dataAvailable = false.obs;

  String boardOrRecruit;
  int COMMUNITY_ID;
  int BOARD_ID;

  // Post
  var anonymousCheck = true.obs;
  Rx<bool> mailAnonymous = true.obs;
  RxList postContent = [].obs;
  RxList<Map> sortedList = <Map>[].obs;
  RxMap postBody = {}.obs;

  var isCcomment = false.obs;
  var ccommentUrl = ''.obs;
  var commentUrl = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    makeCommentUrl(COMMUNITY_ID, BOARD_ID);
    boardOrRecruit = COMMUNITY_ID > 3 ? "board" : "outside";
    print("init!!!!");
    await getPostData();
  }

  Future<void> refreshPost() async {
    await getPostData();
  }

  Future<void> getPostData() async {
    var response =
        await Session().getX("/$boardOrRecruit/$COMMUNITY_ID/read/$BOARD_ID");
    print(response.statusCode);
    switch (response.statusCode) {
      case 401:
        Session().getX('/logout');
        Get.offAllNamed('/login');
        return null;
        break;
      case 400:
      case 200:
        sortPCCC(jsonDecode(response.body));
        _dataAvailable.value = true;
        return;
      default:
    }
  }

  void sortPCCC(List<dynamic> itemList) {
    sortedList.clear();

    sortedList.add(itemList[0]);

    int itemLength = itemList.length;

    //댓글 대댓글 정렬
    for (int i = 1; i < itemLength; i++) {
      var unsortedItem = itemList[i];

      //게시글 - 댓글 - 대댓글 순서대로 정렬되있으므로 대댓글 만나는 순간 끝
      if (unsortedItem["DEPTH"] == 2) {
        print("break!");
        break;
      }

      //댓글 집어 넣기
      sortedList.add(itemList[i]);

      for (int k = 1; k < itemList.length; k++) {
        //itemlist를 돌면서 댓글을 부모로 가지는 대댓글 찾아서
        if (itemList[k]["PARENT_ID"] == unsortedItem["UNIQUE_ID"]) {
          //sortedList에 집어넣음(순서대로)
          sortedList.add(itemList[k]);
        }
      }
    }
  }

  void totalSend(String urlTemp, String what) {
    String url = "/$boardOrRecruit" + urlTemp;
    Session().getX(url).then((value) {
      switch (value.statusCode) {
        case 200:
          Get.snackbar("$what 성공", "$what 성공",
              snackPosition: SnackPosition.BOTTOM);
          getPostData();
          break;
        case 403:
          Get.snackbar('이미 $what 한 게시글입니다', '이미 $what 한 게시글입니다',
              snackPosition: SnackPosition.BOTTOM);
          break;
        default:
      }
    });
  }

  void sendMail(
      int UNIQUE_ID, int COMMUNITY_ID, mailWriteController, mailController) {
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
                        value: mailAnonymous.value,
                        onChanged: (value) {
                          mailAnonymous.value = value;
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
                  "UNIQUE_ID": '$UNIQUE_ID',
                  "PROFILE_UNNAMED": '1',
                  "CONTENT": '${content.trim()}',
                  "COMMUNITY_ID": '$COMMUNITY_ID'
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
                        jsonDecode(response.body)["MAIL_BOX_ID"];

                    print(jsonDecode(response.body));
                    print(jsonDecode(response.body));

                    mailController.MAIL_BOX_ID.value = targetMessageBoxID;

                    print(mailController.MAIL_BOX_ID.value);
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
    mailWriteController.clear();
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

  changeAnonymous(bool value) {
    anonymousCheck.value = value;
  }

  changeCcomment(String cidUrl) {
    if (isCcomment.value && ccommentUrl.value == cidUrl) {
      isCcomment(false);
    } else {
      isCcomment(true);
    }
  }

  makeCcommentUrl(int COMMUNITY_ID, int cid) {
    ccommentUrl.value = '/$boardOrRecruit/$COMMUNITY_ID/cid/$cid';
  }

  makeCommentUrl(int COMMUNITY_ID, int bid) {
    commentUrl.value = '/$boardOrRecruit/$COMMUNITY_ID/bid/$bid';
  }

  // 댓글 수정
  var autoFocusTextForm = false.obs;
  var putUrl = ''.obs;

  // updateAutoFocusTextForm(bool b) {
  //   autoFocusTextForm.value = b;
  //   update();
  // }

  // void getPostFromCommentData(Map comment) async {
  //   var response = await Session().getX(
  //       "/board/${comment['comment']['type']}/read/${comment['comment']['bid']}");
  // }

  bool get dataAvailable => _dataAvailable.value;
}

class LoginController extends GetxController {
  var isAutoLogin = true.obs;

  updateAutoLogin(bool b) {
    isAutoLogin.value = b;
    update();
  }
}
