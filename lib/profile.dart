import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'session.dart';
import 'getXController.dart';

class Profile extends StatelessWidget {
  final Controller c = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());

    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
        ),
        body: FutureBuilder(
          future: userController.getUserProfile(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Obx(() => Column(
                    children: [
                      Spacer(
                        flex: 10,
                      ),
                      Expanded(
                        flex: 80,
                        child: Row(
                          children: [
                            Spacer(
                              flex: 10,
                            ),
                            Expanded(
                                flex: 80,
                                child: Image.network(
                                  'http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000/${userController.userProfile.value.photo}', //수정해야함
                                )),
                            Spacer(
                              flex: 20,
                            ),
                            Expanded(
                              flex: 250,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Spacer(flex: 12),
                                    Expanded(
                                      flex: 20,
                                      child: Text(
                                        '${userController.userProfile.value.nickname}',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                    Spacer(
                                      flex: 10,
                                    ),
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                          '${userController.userProfile.value.uid}'),
                                    ),
                                    Spacer(
                                      flex: 6,
                                    ),
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                          '${userController.userProfile.value.school}'),
                                    ),
                                    Spacer(
                                      flex: 8,
                                    )
                                  ]),
                            )
                          ],
                        ),
                      ),
                      Spacer(
                        flex: 18,
                      ),
                      Expanded(
                          flex: 24,
                          child: Row(
                            children: [
                              Spacer(
                                flex: 10,
                              ),
                              Expanded(
                                  flex: 80,
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1, color: Colors.black),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25))),
                                      child: Text(
                                        "profile",
                                        style: TextStyle(fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    onTap: () => {print("profile")},
                                  )),
                              Spacer(
                                flex: 8,
                              ),
                              Expanded(
                                child: InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25))),
                                    child: Text(
                                      "text",
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  onTap: () => {print("text")},
                                ),
                                flex: 80,
                              ),
                              Spacer(
                                flex: 182,
                              )
                            ],
                          )),
                      Spacer(
                        flex: 26,
                      ),
                      Expanded(
                        flex: 16,
                        child: Row(
                          children: [
                            Spacer(
                              flex: 27,
                            ),
                            Expanded(
                              flex: 61,
                              child: Text(
                                "내가 쓴 글",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Spacer(
                              flex: 63,
                            ),
                            Expanded(
                              flex: 70,
                              child: Text("내가 쓴 댓글",
                                  style: TextStyle(fontSize: 15)),
                            ),
                            Spacer(
                              flex: 45,
                            ),
                            Expanded(
                              flex: 54,
                              child:
                                  Text("저장한 글", style: TextStyle(fontSize: 15)),
                            ),
                            Spacer(
                              flex: 40,
                            )
                          ],
                        ),
                      ),
                      Spacer(
                        flex: 4,
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: Colors.purple,
                        ),
                      ),
                      Expanded(
                        flex: 59,
                        child: Text("게시글"),
                      ),
                      Expanded(
                        flex: 59,
                        child: Text("게시글"),
                      ),
                      Expanded(
                        flex: 59,
                        child: Text("게시글"),
                      ),
                      Expanded(
                        flex: 59,
                        child: Text("게시글"),
                      ),
                      Expanded(
                        flex: 59,
                        child: Text("게시글"),
                      ),
                      Expanded(
                        flex: 59,
                        child: Text("게시글"),
                      ),
                      Expanded(
                        flex: 59,
                        child: Text("게시글"),
                      ),
                      Expanded(
                        flex: 59,
                        child: Text("게시글"),
                      ),
                      Expanded(
                        flex: 59,
                        child: Text("게시글"),
                      ),
                      Text(
                        'clicks: ${c.ccommentUrl.value}',
                      )
                    ],
                  ));
            } else if (snapshot.hasError) {
              return Container(child: Text(snapshot.data.bodyBytes));
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}
