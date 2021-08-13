// 이게 material 위젯 가져오는 거임 거의 항상 쓰인다고 보면 됨
import 'package:flutter/material.dart';

// 얘는 내가 만들어놓은 http 통신 관련 파일
import 'package:polarstar_flutter/session.dart';

// 얘는 상태 관리 해주는 패키지
// class_controller에다가 상태 변화 필요한거 있으면 만들어 쓰면 됨
import 'package:get/get.dart';

import 'class_controller.dart';

// json 인코드 디코드 할떄 씀(json.decode(response.body))
// 이러면 Map 반환됨
import 'dart:convert';

// 아마 이 밑에 Run 같은거 뜰건데 main.dart 실행하지 말고 이걸로 하면 됨
// 로그인하면 ㅈ같으니까 그냥 json을 Map으로 만들어서 테스트 ㄱㄱ
void main() => runApp(ClassMain());

// stateful은 GetX로 대체할거라 stateless만 쓰면 됨
class ClassMain extends StatelessWidget {
  const ClassMain({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // GetX안쓰면 그냥 MarerialApp인데 GetX 쓸거라 ㅇㅇ
      title: 'polarStar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => ClassView()),
      ],
    );
  }
}

// 클래스 이름은 알아서 하슈
class ClassView extends StatelessWidget {
  const ClassView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ClassControll()을 불러와서 이제 그 안의 변수등의 상태 변화를 이 컨트롤러로 알 수 있음
    final classControll = Get.put(ClassController());

    // 보통 MaterialApp 안에 Scaffold로 많이 함 그냥 그대로 하면 됨
    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
      ),
      body: Container(), // 여기다 원하는 위젯 만들면 됨
    );
  }
}
