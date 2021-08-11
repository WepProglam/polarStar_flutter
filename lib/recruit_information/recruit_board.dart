import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:get/get.dart';

import 'package:polarstar_flutter/session.dart';
import 'package:polarstar_flutter/getXController.dart';

import 'recruit_controller.dart';

class RecruitBoard extends GetView<RecruitController> {
  const RecruitBoard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recruitController = Get.put(RecruitController());
    final searchText = TextEditingController();

    // navigate로 왔는지
    if (Get.parameters.isEmpty) {
      recruitController.type('1');
      recruitController.page('1');
    } else {
      recruitController.type(Get.parameters['type']);
      recruitController.page(Get.parameters['page']);
    }

    return RefreshIndicator(
      onRefresh: controller.getRecruitBoard,
      child: Stack(
        children: [
          SearchBar(searchText: searchText),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: Get.mediaQuery.size.width,
                ),
                Obx(() {
                  if (recruitController.canBuildRecruitBoard.value) {
                    List<Widget> postPreviewList = [];
                    for (int i = 0;
                        i < recruitController.recruit_board_body['rows'].length;
                        i++) {
                      postPreviewList.add(RecruitPostPreview(
                        index: i,
                      ));
                    }
                    return Column(
                      children: postPreviewList,
                    );
                  } else {
                    return Container();
                  }
                }),
              ],
            ),
          ),
          ListView(),
        ],
      ),
    );
  }
}

class RecruitPostPreview extends StatelessWidget {
  const RecruitPostPreview({Key key, @required this.index}) : super(key: key);
  final int index;

  String boardName(int bid) {
    switch (bid) {
      case 1:
        return '취업';
        break;
      case 2:
        return '공모전';
        break;
      case 3:
        return '알바';
        break;
      default:
        return '취업';
    }
  }

  @override
  Widget build(BuildContext context) {
    final recruitController = Get.put(RecruitController());
    return // Post preview
        Container(
      decoration:
          BoxDecoration(border: Border.symmetric(horizontal: BorderSide())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 프로필 이미지 & 닉네임
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, right: 8.0),
                      child: Container(
                        // 그냥 사이즈 표기용
                        // decoration: BoxDecoration(border: Border.all()),
                        height: 30,
                        width: 30,
                        child: CachedNetworkImage(
                            imageUrl:
                                'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/${recruitController.recruit_board_body['rows'][index]['profile_photo']}',
                            fit: BoxFit.fill,
                            fadeInDuration: Duration(milliseconds: 0),
                            progressIndicatorBuilder: (context, url,
                                    downloadProgress) =>
                                Image(image: AssetImage('image/spinner.gif')),
                            errorWidget: (context, url, error) {
                              print(error);
                              return Icon(Icons.error);
                            }),
                      ),
                    ),
                    Text(recruitController.recruit_board_body['rows'][index]
                        ['nickname']),
                  ],
                ),
              ),
              // 제목, 내용
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        recruitController.recruit_board_body['rows'][index]
                            ['title'],
                        textScaleFactor: 1.5,
                        maxLines: 1,
                      ),
                      // 내용
                      Text(
                        recruitController.recruit_board_body['rows'][index]
                            ['content'],
                        maxLines: 1,
                      )
                    ],
                  ),
                ),
              ),
              // Photo
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // 그냥 사이즈 표기용
                  // decoration: BoxDecoration(border: Border.all()),
                  height: 50,
                  width: 50,
                  child: recruitController.recruit_board_body['rows'][index]
                              ['photo'] ==
                          ''
                      ? Container()
                      : CachedNetworkImage(
                          imageUrl:
                              'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/uploads/outside/${recruitController.recruit_board_body['rows'][index]['photo']}',
                          fit: BoxFit.fill,
                          fadeInDuration: Duration(milliseconds: 0),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  Image(image: AssetImage('image/spinner.gif')),
                          errorWidget: (context, url, error) {
                            print(error);
                            return Icon(Icons.error);
                          }),
                ),
              ),
            ],
          ),
          // 게시판, 좋아요, 댓글, 스크랩
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 8.0,
            ),
            child: Row(
              children: [
                Text(boardName(recruitController.recruit_board_body['rows']
                        [index]['bid']) +
                    '게시판'),
                Spacer(),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                      child: Icon(
                        Icons.thumb_up,
                        size: 15,
                      ),
                    ),
                    Text(recruitController.recruit_board_body['rows'][index]
                            ['like']
                        .toString()),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                      child: Icon(
                        Icons.comment,
                        size: 15,
                      ),
                    ),
                    Text(recruitController.recruit_board_body['rows'][index]
                            ['comments']
                        .toString()),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                      child: Icon(
                        Icons.bookmark,
                        size: 15,
                      ),
                    ),
                    Text(recruitController.recruit_board_body['rows'][index]
                            ['scrap']
                        .toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 검색창
class SearchBar extends StatelessWidget {
  const SearchBar({
    Key key,
    @required this.searchText,
  }) : super(key: key);

  final TextEditingController searchText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          TextFormField(
            controller: searchText,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              hintText: 'search',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            ),
            style: TextStyle(),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                    child: InkWell(
                  onTap: () {
                    Map arg = {'search': searchText.text, 'from': 'home'};
                    Get.toNamed('/searchBoard', arguments: arg);
                  },
                  child: Icon(Icons.search_outlined),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
