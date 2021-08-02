import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'model/User.dart';
import 'session.dart';

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
  Rx<User> userProfile = new User().obs;
  Rx<int> profilePostIndex = 0.obs;
  Rx<Post> postPreview = new Post().obs;

  //var user = User().obs;
  Future<String> getUserProfile() async {
    var response = await Session().getX("/info");
    var responseBody = utf8.decode(response.bodyBytes);
    var json = jsonDecode(responseBody)["profile"];

    print(json["bids"][0]);

    userProfile.value = User(
      pid: json["pid"],
      uid: json["uid"],
      deleted: json["deleted"],
      nickname: json["nickname"],
      school: json["school"],
      photo: json["photo"],
      profilemsg: json["profilemsg"],
      likes: json["likes"],
      bids: json["bids"],
      friends: json["friends"],
      buffer: json["buffer"],
      scrap: json["scrap"],
      arrest: json["arrest"],
    );

    return "a";
  }

  void setProfilePostIndex(index) {
    profilePostIndex.value = index;
  }

  @override
  void onInit() async {
    print("object");
    super.onInit();
    profilePostIndex.value = 0;

    ever(profilePostIndex, (_) {
      print('$_이/가 변경되었습니다.');
    });
  }
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
