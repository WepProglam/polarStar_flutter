import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:polarstar_flutter/session.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecruitController extends GetxController {
  RxString type = '1'.obs, page = '1'.obs;

  RxBool canBuildRecruitBoard = false.obs;

  RxMap recruitBoardBody = {}.obs;

  // RxList<Map> pageBodyList = <Map>[].obs;

  RxList<Map> postBody = <Map>[].obs;

  var scrollController = ScrollController().obs;

  Future<void> refreshPage() async {
    page('1');
    // pageBodyList = <Map>[].obs;
    postBody.clear();
    // pageBodyList.refresh();
    postBody.refresh();
    getRecruitBoard().then((value) => postBody.refresh());
  }

  Future<void> getRecruitBoard() async {
    var res = Session().getX('/outside/$type/page/$page').then((value) {
      switch (value.statusCode) {
        case 200:
          recruitBoardBody(json.decode(value.body));
          // pageBodyList.add(json.decode(value.body));
          print(json.decode(value.body));
          canBuildRecruitBoard(true);

          for (int i = 0; i < json.decode(value.body)['rows'].length; i++) {
            postBody.add(json.decode(value.body)['rows'][i]);
            // print(postBody.length);

          }

          print(postBody.length);

          return value;

          break;

        default:
          recruitBoardBody(json.decode(value.body));
          return value;
      }
    });

    await Future.delayed(Duration(seconds: 1));

    update();
  }

  @override
  void onInit() {
    once(type, (_) => getRecruitBoard());

    scrollController.value.addListener(() {
      if (scrollController.value.position.pixels ==
              scrollController.value.position.maxScrollExtent / 10 * 9 ||
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
  RxMap testComment = {}.obs;

  RxBool isReady = false.obs;

  RxList<Map> commentList = <Map>[].obs;

  Future<void> refreshPost() async {
    getPostData();
    update();
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

          // 나중 대비 해놓은거
          for (var item in resBody['comments'].entries) {
            commentList.addNonNull(item.value['comment']);
          }

          // testComment(resBody['comments']['4']['comment']);
          print(postBody['comments']);

          isReady(true);
          isReady.refresh();
          break;
        default:
      }
    });
  }
}