import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:polarstar_flutter/session.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClassController extends GetxController {
  RxBool canBuildClass = false.obs;

  RxMap classBody = {}.obs;

  RxBool _dataAvailableClassPreview = false.obs;

  RxList<Map> postBody = <Map>[].obs;

  var scrollController = ScrollController().obs;

  Future<void> refreshPage() async {
    postBody.clear();
    // postBody.refresh();
    getClass().then((value) => postBody.refresh());
  }

  Future<void> getClass() async {
    var res = await Session().getX('/class').then((value) {
      switch (value.statusCode) {
        case 200:
          canBuildClass(true);

          postBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            postBody.add(jsonDecode(value.body)[i]);
          }

          _dataAvailableClassPreview.value = true;

          

          return value;

          break;

        default:
          classBody(json.decode(value.body));
          return value;
      }
    });

  }
}


class ClassViewController extends GetxController {



}

class ClassSearchController extends GetxController {

  RxBool canBuildClass = false.obs;

  RxMap classBody = {}.obs;

  RxBool _dataAvailableClassSearch = false.obs;

  RxList<Map> postBody = <Map>[].obs;

  var scrollController = ScrollController().obs;

  Future<void> refreshPage(searchText) async {
    postBody.clear();
    // postBody.refresh();
    getSearchResult(searchText).then((value) => postBody.refresh());
  }

  Future<void> getSearchResult(searchText) async {
    var res = await Session().getX('/class/search?search=$searchText').then((value) {
      switch (value.statusCode) {
        case 200:
          canBuildClass(true);

          postBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            postBody.add(jsonDecode(value.body)[i]);
          }

          _dataAvailableClassSearch.value = true;

          return value;

          break;

        default:
          classBody(json.decode(value.body));
          return value;
      }
    });


}
