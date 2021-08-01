import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  var mainPageIndex = 1.obs;

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

  // 게시판 페이지 인덱스
  var pageIndex = 1.obs;

  updatePageIndex(int i) {
    pageIndex.value = i;
    update();
  }

  var isBoardEmpty = false.obs;
  changeIsBoardEmpty(bool value) {
    isBoardEmpty.value = value;
    update();
  }
}
