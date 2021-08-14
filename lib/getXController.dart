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
  List<dynamic> userWriteBid = [].obs; //유저 작성 글
  List<dynamic> userLikeBid = [].obs; //유저 좋아요 글
  List<dynamic> userScrapBid = [].obs; //유저 스크랩 글

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

    var userWriteBid = responseBody["WritePost"];
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
    print("get mine like");
    var response = await Session().getX("/info/like");

    if (response.statusCode == 404) {
      userLikeBid = [];
    } else {
      var responseBody = jsonDecode(response.body);
      userLikeBid = responseBody["LIKE"];
    }

    _dataAvailableMypageLike.value = true;
  }

  //유저 스크랩 글
  Future<void> getMineScrap() async {
    print("get mine scrap");
    var response = await Session().getX("/info/scrap");

    if (response.statusCode == 404) {
      userScrapBid = [];
    } else {
      var responseBody = jsonDecode(response.body);
      userScrapBid = responseBody["SCRAP"];
    }

    _dataAvailableMypageScrap.value = true;
  }

  void setProfileNickname(nickname) {
    profileNickname.value = nickname;
  }

  void setProfilemsg(profilemsg) {
    profileProfilemsg.value = profilemsg;
  }

  void setProfileImagePath(path) {
    profileImagePath.value = path;
  }

  void setProfilePostIndex(index) {
    profilePostIndex.value = index;
  }

  void setProfileImage(img) {
    image.value = img;
  }

  //따로따로 하니깐 화면이 뚝뚝 끊겨서 일단은 한번에 다 불러옴
  @override
  void onInit() async {
    super.onInit();
    getMineWrite();
    getMineLike();
    getMineScrap();
    profilePostIndex.value = 0;
  }

  //한번에 세트로 다 불러오는 함수
  Future<void> fetchAll() async {
    // _dataAvailableMypageWrite.value = false;
    // _dataAvailableMypageLike.value = false;
    // _dataAvailableMypageScrap.value = false;
    getMineWrite();
    getMineLike();
    getMineScrap();
  }

  bool get dataAvailableMypage => _dataAvailableMypage.value;
  bool get dataAvailableMypageWrite => _dataAvailableMypageWrite.value;
  bool get dataAvailableMypageLike => _dataAvailableMypageLike.value;
  bool get dataAvailableMypageScrap => _dataAvailableMypageScrap.value;
}

class MailController extends GetxController {
  RxList mailBox = [].obs; //쪽지함
  RxInt message_box_id = 0.obs; //쪽지함 id
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
      mailBox.value = json["messageBox"];
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
    var response = await Session().getX("/message/${message_box_id.value}");
    var json = jsonDecode(response.body);
    mailSendData.value = json["messages"];
    opponentProfile.value = json["profile"];
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
  // Post
  var anonymousCheck = true.obs;
  Rx<bool> mailAnonymous = true.obs;
  var isCcomment = false.obs;
  var ccommentUrl = '/board/cid'.obs;

  @override
  void onInit() {
    super.onInit();
    ever(mailAnonymous, (_) {
      print(mailAnonymous.value);
    });
  }

  changeAnonymous(bool value) {
    anonymousCheck.value = value;
    update();
  }

  changeCcomment(String cidUrl) {
    if (isCcomment.value && ccommentUrl.value == cidUrl) {
      isCcomment.value = false;
    } else {
      isCcomment.value = true;
    }

    update();
  }

  makeCcommentUrl(String where, String cid) {
    ccommentUrl.value = '/$where/cid/$cid';
    update();
  }

  // 댓글 수정
  var autoFocusTextForm = false.obs;
  var putUrl = '/board'.obs;

  updateAutoFocusTextForm(bool b) {
    autoFocusTextForm.value = b;
    update();
  }

  updatePutUrl(String url) {
    putUrl.value = url;
    update();
  }

  void getPostFromCommentData(Map comment) async {
    var response = await Session().getX(
        "/board/${comment['comment']['type']}/read/${comment['comment']['bid']}");
  }
}

class LoginController extends GetxController {
  var isAutoLogin = true.obs;

  updateAutoLogin(bool b) {
    isAutoLogin.value = b;
    update();
  }
}
