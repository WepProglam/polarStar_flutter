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

  Rx<int> boardIndex = 0.obs;

  RxBool _dataAvailableRecruitPreview = false.obs;
  RxBool _dataAvailableParttimePreview = false.obs;
  RxBool _dataAvailableOutdoorPreview = false.obs;

  // RxList<Map> pageBodyList = <Map>[].obs;

  RxList<Map> postBody = <Map>[].obs;

  var scrollController = ScrollController().obs;

  Future<void> refreshPage() async {
    postBody.clear();
    // postBody.refresh();
    getRecruitBoard().then((value) => postBody.refresh());
  }

  Future<void> getRecruitBoard() async {
    var res = await Session().getX('/outside/1/page/$page').then((value) {
      switch (value.statusCode) {
        case 200:
          canBuildRecruitBoard(true);

          postBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            postBody.add(jsonDecode(value.body)[i]);
          }

          _dataAvailableRecruitPreview.value = true;

          return value;

          break;

        default:
          recruitBoardBody(json.decode(value.body));
          return value;
      }
    });

    // await Future.delayed(Duration(seconds: 1));
  }

  Future<void> getParttimeBoard() async {
    var res = await Session().getX('/outside/2/page/$page').then((value) {
      switch (value.statusCode) {
        case 200:
          canBuildRecruitBoard(true);
          postBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            postBody.add(jsonDecode(value.body)[i]);
          }

          _dataAvailableParttimePreview.value = true;

          return value;

          break;

        default:
          recruitBoardBody(json.decode(value.body));
          return value;
      }
    });
  }

  Future<void> getOutdoorBoard() async {
    var res = await Session().getX('/outside/3/page/$page').then((value) {
      switch (value.statusCode) {
        case 200:
          canBuildRecruitBoard(true);
          postBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            postBody.add(jsonDecode(value.body)[i]);
          }

          _dataAvailableOutdoorPreview.value = true;

          return value;

          break;

        default:
          recruitBoardBody(json.decode(value.body));
          return value;
      }
    });
  }

  @override
  void onInit() async {
    super.onInit();
    boardIndex.value = 0;

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

    ever(boardIndex, (_) async {
      switch (boardIndex.value) {
        case 0:
          await getRecruitBoard();
          break;
        case 1:
          await getParttimeBoard();
          break;
        case 2:
          await getOutdoorBoard();
          break;
        default:
      }
    });
  }

  bool get dataAvailableRecruitPreview => _dataAvailableRecruitPreview.value;
  bool get dataAvailableOutdoorPreview => _dataAvailableOutdoorPreview.value;
  bool get dataAvailableParttimePreview => _dataAvailableParttimePreview.value;
}
