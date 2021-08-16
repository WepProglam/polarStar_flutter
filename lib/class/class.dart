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

import '../getXController.dart';
import '../src/post_layout.dart';
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
        GetPage(name: '/', page: () => Class()),
        GetPage(name: '/view/:classid', page: () => ClassView()),
        GetPage(name: '/searchClass', page: () => SearchClass()),
      ],
    );
  }
}

// 클래스 이름은 알아서 하슈
class Class extends GetView<ClassController> {
  Class({Key key}) : super(key: key);
  final classController = Get.put(ClassController());
  final searchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 보통 MaterialApp 안에 Scaffold로 많이 함 그냥 그대로 하면 됨
    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
      ),
      body: RefreshIndicator(
          onRefresh: classController.refreshPage,
          child: Stack(children: [
            Obx(() {
              return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: classController.scrollController.value,
                  itemCount: classController.postBody.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ClassPreview(body: classController.postBody[index]);
                  });
            }),
            SearchBar(searchText: searchText)
          ])), // 여기다 원하는 위젯 만들면 됨
    );
  }
}

class ClassPreview extends StatelessWidget {
  const ClassPreview({Key key, @required this.body}) : super(key: key);
  final Map<dynamic, dynamic> body;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/view/${body['classid']}');
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          // height: 200,
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  body['className'],
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  body['classNumber'],
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  body['professor'],
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ClassView extends GetView<ClassViewController> {
  ClassView({Key key}) : super(key: key);
  final classViewController = Get.put(ClassViewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('polarStar')),
        body: RefreshIndicator(
            onRefresh: classViewController.refreshClass,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                Obx(() {
                  if (classViewController._dataAvailableClassView) {
                    return PostLayout(
                      controller: classViewController,
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
              ]),
            )),
  
  }
}


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
                    Map arg = {'search': searchText.text};
                    Get.toNamed('/searchClass', arguments: arg);
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

class SearchClass extends StatefulWidget {
  const SearchClass({Key key}) : super(key: key);

  @override
  _SearchClassState createState() => _SearchClassState();
}

class _SearchClassState extends State<SearchClass> {
  dynamic arg = Get.arguments;
  bool getData = false;
  TextEditingController searchText = TextEditingController();
  final Controller c = Get.put(Controller());
  var response;

  Future getClassData(dynamic arg) async {
    String getUrl;
    List<Widget> buttons = [];

    if (arg is Map) {
      getUrl = '/class/search?search=${arg['search']}';
    }

    var res = await Session().getX(getUrl).then((value) {
      if (value.statusCode == 404) {
        return value;
      } else {
        return value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [
            Container(
              width: 40,
              child: arg is! Map
                  ? InkWell(
                      onTap: () {
                        Get.toNamed('/', arguments: arg);
                      },
                      child: Icon(
                        Icons.add,
                      ))
                  : null,
            )
          ],
        ),
        body: FutureBuilder(
          future: getClassData(arg),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData == false) {
              return Column(
                children: [Text("Err")],
              );
            } else if (snapshot.hasError) {
              return CircularProgressIndicator();
            } else {
              return Column(
                children: [
                  Container(
                    child: classContents(jsonDecode(response.body)),
                  )
                ],
              );
            }
          },
        ));
  }

  Widget classContents(List<dynamic> body) {
    List<Widget> classContentList = [];

    for (var item in body) {
      classContentList.add(classContent(item));
    }

    return Column(
      children: classContentList,
    );
  }

  Widget classContent(Map<dynamic, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: 50,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            primary: Colors.black,
          ),
          onPressed: () {
            // print('url: ${data['url']}');
            String classUrl = '/class/view?${data['classid']}}';
            Map postArg = {'classUrl': classUrl};
            Get.toNamed('/class/view', arguments: postArg);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 200,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data['className'],
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data['classNumber'],
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data['professor'],
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
