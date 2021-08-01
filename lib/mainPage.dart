import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'boards.dart';
import 'home.dart';
import 'session.dart';
import 'getXController.dart';

class MainPage extends StatelessWidget {
  List<Widget> mainPageWidget = [
    MainPageScroll(),
    Boards(),
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
                  // Navigator.pushNamedAndRemoveUntil(
                  //     context, '/login', (Route<dynamic> route) => false);
                  Get.offAllNamed('/login');
                },
                icon: Text('LOGOUT')),
            IconButton(
                onPressed: () {
                  Get.toNamed('/profile');
                },
                icon: Icon(Icons.person)),
          ],
        ),
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
                icon: Icon(Icons.dashboard),
                label: 'boards',
                // backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: 'unity',
                // backgroundColor: Colors.black
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outlined),
                label: 'work',
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
