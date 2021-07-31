import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
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
}
