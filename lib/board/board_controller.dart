import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:polarstar_flutter/session.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BoardController extends GetxController {
  RxString type = '1'.obs, page = '1'.obs;
  RxString where = 'outside'.obs;

  RxBool canBuildRecruitBoard = false.obs;

  RxMap recruitBoardBody = {}.obs;

  Rx<int> boardIndex = 0.obs;

  RxBool dataAvailablePostPreview = false.obs;

  // RxList<Map> pageBodyList = <Map>[].obs;

  RxList<Map> postBody = <Map>[].obs;

  var scrollController = ScrollController().obs;

  Future<void> refreshPage() async {
    postBody.clear();
    // postBody.refresh();
    getBoard().then((value) => postBody.refresh());
  }

  Future<void> getBoard() async {
    var res = await Session()
        .getX('/${where.value}/${type.value}/page/${page.value}')
        .then((value) {
      switch (value.statusCode) {
        case 200:
          canBuildRecruitBoard(true);

          postBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            postBody.add(jsonDecode(value.body)[i]);
          }
          print(jsonDecode(value.body));

          dataAvailablePostPreview.value = true;
          return value;
          break;

        default:
          recruitBoardBody(json.decode(value.body));
          return value;
      }
    });
  }

  // Future<void> getSearchBoard(String searchText) async {
  //   Session().getX('/board/searchAll/page/1?search=$searchText').then((value) {
  //     switch (value.statusCode) {
  //       case 200:
  //         canBuildRecruitBoard(true);

  //         postBody.clear();

  //         for (int i = 0; i < jsonDecode(value.body).length; i++) {
  //           postBody.add(jsonDecode(value.body)[i]);
  //         }

  //         break;
  //       default:
  //         recruitBoardBody(json.decode(value.body));

  //         return value;
  //     }
  //   });
  // }

  @override
  void onInit() async {
    super.onInit();
    boardIndex.value = 0;

    once(type, (_) => getBoard());

    scrollController.value.addListener(() {
      if (scrollController.value.position.pixels ==
              scrollController.value.position.maxScrollExtent / 10 * 9 ||
          !scrollController.value.position.hasPixels) {
        int curPage = int.parse(page.value);
        if (curPage < recruitBoardBody['pageAmount']) {
          page((curPage + 1).toString());
          print('scroll end');
          getBoard();
        }
      }
    });
  }
}
