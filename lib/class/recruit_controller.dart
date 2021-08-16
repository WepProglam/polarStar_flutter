import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:polarstar_flutter/session.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClassController extends GetxController {
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

class RecruitPostController extends GetxController {
  RxMap postBody = {}.obs;
  RxMap testComment = {}.obs;

  RxBool isReady = false.obs;
  RxBool _dataAvailableRecruitPost = false.obs;
  var ccommentUrl = '/outside/cid'.obs;

  RxList<Map> commentList = <Map>[].obs;
  RxList<Map> sortedList = <Map>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await getPostData();
  }

  Future<void> refreshPost() async {
    getPostData();
  }

  makeCcommentUrl(String where, String COMMUNITY_ID, String cid) {
    ccommentUrl.value = '/outside/$COMMUNITY_ID/cid/$cid';
  }

  void sortPCCC(List<dynamic> itemList) {
    sortedList.clear();

    sortedList.add(itemList[0]);

    int itemLength = itemList.length;

    //댓글 대댓글 정렬
    for (int i = 1; i < itemLength; i++) {
      var unsortedItem = itemList[i];

      //게시글 - 댓글 - 대댓글 순서대로 정렬되있으므로 대댓글 만나는 순간 끝
      if (unsortedItem["DEPTH"] == 2) {
        print("break!");
        break;
      }

      //댓글 집어 넣기
      sortedList.add(itemList[i]);

      for (int k = 1; k < itemList.length; k++) {
        //itemlist를 돌면서 댓글을 부모로 가지는 대댓글 찾아서
        if (itemList[k]["PARENT_ID"] == unsortedItem["UNIQUE_ID"]) {
          //sortedList에 집어넣음(순서대로)
          sortedList.add(itemList[k]);
        }
      }
    }
  }

  Future getPostData() async {
    print(Get.parameters);

    _dataAvailableRecruitPost.value = false;
    await Session()
        .getX(
            '/outside/${Get.parameters['type']}/read/${Get.parameters['bid']}')
        .then((value) {
      switch (value.statusCode) {
        case 200:
          // print(value.body);
          List resBody = jsonDecode(value.body);
          resBody[0]["MYSELF"] = false;
          sortPCCC(resBody);
          postBody.value = resBody[0];

          // 나중 대비 해놓은거
          // for (var item in resBody['comments'].entries) {
          //   commentList.addNonNull(item.value['comment']);
          // }

          // testComment(resBody['comments']['4']['comment']);

          _dataAvailableRecruitPost.value = true;
          break;
        default:
          _dataAvailableRecruitPost.value = false;
          break;
      }
    });
  }

  bool get dataAvailableRecruitPost => _dataAvailableRecruitPost.value;
}
