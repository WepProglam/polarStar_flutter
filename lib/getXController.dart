import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'model/User.dart';
import 'session.dart';

class Controller extends GetxController {
  var mainPageIndex = 0.obs;

  updateMainPage(int index) {
    mainPageIndex.value = index;
    update();
  }

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

  var pageIndex = 1.obs;

  updatePageIndex(int i) {
    pageIndex.value = i;
    update();
  }
}

class UserController extends GetxController {
  Rx<User> userProfile = new User().obs;
  //var user = User().obs;
  Future<String> getUserProfile() async {
    var response = await Session().getX("/info");
    var responseBody = utf8.decode(response.bodyBytes);
    var json = jsonDecode(responseBody)["profile"];
    json["likes"] = jsonDecode(json["likes"]);
    print(json["likes"]["b"]);
    userProfile.value = User(
      pid: json["pid"],
      uid: json["uid"],
      deleted: json["deleted"],
      nickname: json["nickname"],
      school: json["school"],
      photo: json["photo"],
      profilemsg: json["profilemsg"],
      likes: json["likes"],
      friends: json["friends"],
      buffer: json["buffer"],
      scrap: json["scrap"],
      arrest: json["arrest"],
    );

    return "a";
  }

  @override
  void onInit() async {
    print("object");
    super.onInit();
  }
}
