import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:get/get.dart';

import 'package:polarstar_flutter/session.dart';
import 'package:polarstar_flutter/getXController.dart';

import 'board_controller.dart';
import 'package:polarstar_flutter/src/board_layout.dart';

class RecruitBoard extends StatelessWidget {
  RecruitBoard({Key key}) : super(key: key);
  final controller = Get.put(BoardController());
  final searchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.type('1');
    controller.refreshPage();
    return Scaffold(
        body: BoardLayout(
      from: 'outside',
      type: '1',
    ));
  }
}
