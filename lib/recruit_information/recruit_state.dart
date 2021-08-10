import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:http/http.dart';
import 'package:polarstar_flutter/session.dart';

class RecruitController extends GetxController {
  getRecrutMain() async {
    var res = await Session().getX('/outside/3/page/1');
    print(json.decode(res.body));
  }
}
