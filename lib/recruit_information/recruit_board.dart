import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:polarstar_flutter/session.dart';
import 'package:polarstar_flutter/getXController.dart';

import 'recruit_state.dart';

class RecruitBoard extends StatelessWidget {
  const RecruitBoard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recruitController = Get.put(RecruitController());
    // recruitController.getRecrutMain();

    return Container(
      child: null,
    );
  }
}
