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
  ClassViewController({this.classid});

  int classid;

  RxList<Map> classBody = <Map>[].obs;

  Future<void> refreshPage() async {
    classBody.clear();
    // postBody.refresh();
    getClass().then((value) => classBody.refresh());
  }

  Future<void> getClass() async {
    var res = await Session().getX('/class/view/$classid').then((value) {
      switch (value.statusCode) {
        case 200:
          classBody.clear();

          classBody.add(jsonDecode(value.body));

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
  ClassSearchController({this.search});

  String search;

  RxList<Map> resultBody = <Map>[].obs;

  var scrollController = ScrollController().obs;

  Future<void> refreshPage() async {
    resultBody.clear();
    // postBody.refresh();
    getSearchResult();
  }

  Future<void> getSearchResult() async {
    var res =
        await Session().getX('/class/search?search=$search').then((value) {
      switch (value.statusCode) {
        case 200:
          resultBody.clear();

          for (int i = 0; i < jsonDecode(value.body).length; i++) {
            resultBody.add(jsonDecode(value.body)[i]);
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
    getSearchResult();
  }
}
