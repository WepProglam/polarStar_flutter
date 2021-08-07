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
    var response = await Session().getX("/info");
    var responseBody = utf8.decode(response.bodyBytes);
    var json = jsonDecode(responseBody)["profile"];
    userWriteBid = json["bids"];
    //첫 화면에 유저 정보랑 쓴 글 같이 띄워야 되서 같이 유저 정보랑 같이 불러옴
    userProfile = {
      "pid": json["pid"],
      "uid": json["uid"],
      "deleted": json["deleted"],
      "nickname": json["nickname"],
      "school": json["school"],
      "photo": json["photo"],
      "profilemsg": json["profilemsg"],
      "friends": json["friends"],
      "buffer": json["buffer"],
      "arrest": json["arrest"],
      "userType": json["userType"]
    };

    profileImagePath.value = json["photo"]; //프사 경로
    profileNickname.value = json["nickname"]; //닉네임 경로
    profileProfilemsg.value = json["profilemsg"]; //프메 경로
    _dataAvailableMypage.value = true;
    _dataAvailableMypageWrite.value = true;
  }

  //유저 좋아요 글
  Future<void> getMineLike() async {
    print("get mine like");
    var response = await Session().getX("/info/like");
    var responseBody = utf8.decode(response.bodyBytes);
    var json = jsonDecode(responseBody);
    userLikeBid = json["likes"];
    _dataAvailableMypageLike.value = true;
  }

  //유저 스크랩 글
  Future<void> getMineScrap() async {
    print("get mine scrap");
    var response = await Session().getX("/info/scrap");
    var responseBody = utf8.decode(response.bodyBytes);
    var json = jsonDecode(responseBody);
    userScrapBid = json["scrap"];
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
  var mailData = Rx<Map<String, dynamic>>(null);
  var mailSendingData = Rx<List<dynamic>>(null);

  Future<List<dynamic>> getMailBox() async {
    var response = await Session().getX("/message");
    var mailBox = jsonDecode(response.body)["messageBox"];
    int mailLength = mailBox.length;
    return mailBox;
  }

  Future<Map<String, dynamic>> getMail(String url) async {
    var response = await Session().getX(url);
    print(response);
    mailData.value = jsonDecode(response.body);
    mailSendingData.value = mailData.value["messages"];

    //var mailBox = jsonDecode(response.body)["messageBox"];
    //int mailLength = mailBox.length;
    return jsonDecode(response.body);
  }
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
  var isCcomment = false.obs;
  var ccommentUrl = '/board/cid'.obs;

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

  makeCcommentUrl(String cid) {
    ccommentUrl.value = '/board/cid/$cid';
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
