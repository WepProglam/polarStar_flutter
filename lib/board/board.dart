import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:polarstar_flutter/session.dart';
import 'dart:convert';
import 'package:polarstar_flutter/getXController.dart';
import 'package:polarstar_flutter/src/board_layout.dart';
import 'board_controller.dart';

class Board extends StatelessWidget {
  const Board({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BoardController());
    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
        actions: [
          Container(
            width: 40,
            child: InkWell(
                onTap: () {
                  Get.toNamed('/writePost', arguments: {'COMMUNITY_ID': '4'});
                },
                child: Icon(
                  Icons.add,
                )),
          )
        ],
      ),
      body: BoardLayout(
        from: 'board',
        type: Get.arguments,
      ),
    );
  }
}
