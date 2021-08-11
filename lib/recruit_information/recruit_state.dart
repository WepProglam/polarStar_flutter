import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:http/http.dart';
import 'package:polarstar_flutter/session.dart';

class RecruitController extends GetxController {
  RxString type = ''.obs, page = ''.obs, bid = ''.obs;

  RxMap recruit_board_body = {}.obs;

  Future<void> getRecruitBoard() async {
    type.value = '3';
    page.value = '1';

    Session().getX('/outside/$type/page/$page').then((value) {
      switch (value.statusCode) {
        case 200:
          recruit_board_body.value = json.decode(value.body);
          break;

        default:
          recruit_board_body.value = json.decode(value.body);
      }
    });
  }

  Future<void> getRecruitPost() async {
    var res = await Session().getX('/outside/$type/read/$bid');
    print(json.decode(res.body));
  }
}
