import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:polarstar_flutter/session.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'recruit_board.dart';

class RecruitController extends GetxController {
  RxString type = '1'.obs, page = '1'.obs, bid = '1'.obs;

  RxBool canBuildRecruitBoard = false.obs;

  RxMap recruitBoardBody = {}.obs;

  // RxList<Map> pageBodyList = <Map>[].obs;

  RxList<Widget> postPreviewList = <Widget>[].obs;

  var scrollController = ScrollController().obs;

  Future<void> refreshPage() async {
    page('1');
    // pageBodyList = <Map>[].obs;
    postPreviewList = <Widget>[].obs;
    // pageBodyList.refresh();
    postPreviewList.refresh();
    getRecruitBoard();
  }

  Future<void> getRecruitBoard() async {
    Session().getX('/outside/$type/page/$page').then((value) {
      switch (value.statusCode) {
        case 200:
          recruitBoardBody(json.decode(value.body));
          // pageBodyList.add(json.decode(value.body));
          print(json.decode(value.body));
          canBuildRecruitBoard(true);

          for (int i = 0; i < json.decode(value.body)['rows'].length; i++) {
            postPreviewList.add(RecruitPostPreview(
              index: i,
              body: json.decode(value.body),
            ));
            postPreviewList.refresh();
            // print(postPreviewList.length);
          }

          break;

        default:
          recruitBoardBody(json.decode(value.body));
      }
    });
    await Future.delayed(Duration(seconds: 1));

    update();
  }

  Future<void> getRecruitPost() async {
    var res = await Session().getX('/outside/$type/read/$bid');
    print(json.decode(res.body));
  }

  @override
  void onInit() {
    once(type, (_) => getRecruitBoard());

    scrollController.value.addListener(() {
      if (scrollController.value.position.pixels ==
              scrollController.value.position.maxScrollExtent ||
          !scrollController.value.position.hasPixels) {
        int curPage = int.parse(page.value);
        if (curPage < recruitBoardBody['pageAmount']) {
          page((curPage + 1).toString());
          print('scroll end');
          getRecruitBoard();
        }
      }
    });

    super.onInit();
  }
}

class RecruitPostController extends GetxController {
  RxMap postBody = {}.obs;

  RxBool isReady = false.obs;

  Future<void> refreshPost() async {
    getPostData();
  }

  Future getPostData() async {
    print(Get.parameters);

    Session()
        .getX(
            '/outside/${Get.parameters['type']}/read/${Get.parameters['bid']}')
        .then((value) {
      switch (value.statusCode) {
        case 200:
          Map resBody = json.decode(value.body);
          postBody(resBody);
          postBody.refresh();
          print(postBody);
          isReady(true);
          isReady.refresh();
          break;
        default:
      }
    });
  }
}
