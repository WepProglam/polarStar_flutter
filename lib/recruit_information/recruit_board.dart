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

    final searchText = TextEditingController();

    return RefreshIndicator(
      onRefresh: recruitController.getRecruitBoard,
      child: Stack(
        children: [
          ListView(),
          SingleChildScrollView(
            child: Column(
              children: [
                SearchBar(searchText: searchText),
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
