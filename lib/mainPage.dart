import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'boardList.dart';
import 'home.dart';
import 'session.dart';
import 'getXController.dart';

import 'board/recruit_board.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final box = GetStorage();
  List<Widget> mainPageWidget = [
    MainPageScroll(),
    RecruitBoard(),
    Boards(),
    Boards(),
  ];

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.put(Controller());

    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [
            IconButton(
                onPressed: () {
                  Session().getX('/logout');
                  Session.cookies = {};
                  Session.headers['Cookie'] = '';
                  box.remove('pw');
                  box.remove('isloggined');
                  box.remove('token');
                  // Navigator.pushNamedAndRemoveUntil(
                  //     context, '/login', (Route<dynamic> route) => false);
                  Get.offAllNamed('/login');
                },
                icon: Text('LOGOUT')),
            IconButton(
                onPressed: () {
                  Get.toNamed('/myPage');
                },
                icon: Icon(Icons.person)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Session().getX('/push');

              //print(response.body);
            },
            label: const Text("FCM test!")),
        body: Obx(() => mainPageWidget[c.mainPageIndex.value]),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'home',
                // backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outlined),
                label: 'work',
                // backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'boards',
                // backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: 'unity',
                // backgroundColor: Colors.black
              ),
            ],
            unselectedItemColor: Colors.black,
            currentIndex: c.mainPageIndex.value,
            selectedItemColor: Colors.amber[800],
            onTap: (index) => {c.updateMainPage(index)},
          ),
        ));
  }
}
