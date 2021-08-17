import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:polarstar_flutter/session.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClassController extends GetxController {
  RxList<Map> classesBody = <Map>[].obs;

  var scrollController = ScrollController().obs;

  Future<void> refreshPage() async {
    classesBody.clear();
    // postBody.refresh();
    getClasses();
  }

  Future<void> getClasses() async {
    var res = await Session().getX('/class').then((value) {
      switch (value.statusCode) {
        case 200:
          classesBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            classesBody.add(jsonDecode(value.body)[i]);
          }

          return value;

          break;

        default:
          return value;
      }
    });
  }

  @override
  void onInit() async {
    super.onInit();
    getClasses();
  }
}

class ClassViewController extends GetxController {
  RxList<Map> classBody = <Map>[].obs;

  RxBool dataAvailable = false.obs;

  Future<void> refreshPage() async {
    classBody.clear();
    // postBody.refresh();
    getClass().then((value) => classBody.refresh());
  }

  Future<void> getClass() async {
    var res = await Session()
        .getX('/class/view/${Get.parameters['classid']}')
        .then((value) {
      switch (value.statusCode) {
        case 200:
          classBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            classBody.add(jsonDecode(value.body)[i]);
          }

          dataAvailable.value = true;

          return value;

          break;

        default:
          return value;
      }
    });
  }

  @override
  void onInit() async {
    super.onInit();
    getClass();
  }
}

class ClassSearchController extends GetxController {
  RxList<Map> resultBody = <Map>[].obs;

  RxBool dataAvailable = false.obs;

  var scrollController = ScrollController().obs;

  Future<void> refreshPage() async {
    resultBody.clear();
    // postBody.refresh();
    getSearchResult();
  }

  Future<void> getSearchResult() async {
    var res = await Session()
        .getX('/class/search?search=${Get.arguments['search']}')
        .then((value) {
      switch (value.statusCode) {
        case 200:
          dataAvailable.value = false;
          resultBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            resultBody.add(jsonDecode(value.body)[i]);
          }

          dataAvailable.value = true;

          return value;

          break;

        default:
          return value;
      }
    });
  }
}
