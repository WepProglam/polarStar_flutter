import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'recruit_controller.dart';

class RecruitPost extends GetView<RecruitPostController> {
  const RecruitPost({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recruitPostController = Get.put(RecruitPostController());
    recruitPostController.getPostData();

    return Scaffold(
      appBar: AppBar(title: Text('polarStar')),
      body: RefreshIndicator(
        onRefresh: recruitPostController.refreshPost,
        child: ListView(),
      ),
    );
  }
}
