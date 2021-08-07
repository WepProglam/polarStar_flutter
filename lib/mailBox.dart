import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'session.dart';
import 'getXController.dart';

class MailBox extends StatelessWidget {
  final mailController = Get.put(MailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
        ),
        body: RefreshIndicator(
          onRefresh: mailController.getMailBox,
          child: Stack(
            children: [
              ListView(),
              Obx(() {
                //데이터가 사용가능한 상태인지 확인
                if (mailController.dataAvailableMailPage) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var item in mailController.mailBox)
                          InkWell(
                            onTap: () async {
                              mailController.message_box_id.value =
                                  item['message_box_id'];
                              //처음에 정보(쪽지 주고 받은 내역) 받고 보냄
                              await mailController.getMail();
                              Get.toNamed("/mailBox/sendMail");
                            },
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 10,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1.0)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      //상대방 닉네임 or 익명
                                      child: Text(
                                        "${item["opponent"]}",
                                        textScaleFactor: 1.2,
                                      ),
                                      flex: 30,
                                    ),
                                    Expanded(
                                      //최근 내용
                                      child: Text(
                                        "${item["content"]}",
                                        textAlign: TextAlign.center,
                                        textScaleFactor: 1.2,
                                      ),
                                      flex: 100,
                                    ),
                                    Expanded(
                                      //문자 보낸 시각
                                      child: Text(
                                        "${item["content_creation_date"]}",
                                        textAlign: TextAlign.center,
                                        textScaleFactor: 1,
                                      ),
                                      flex: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              })
            ],
          ),
        ));
  }
}

class SendMail extends StatelessWidget {
  MailController mailController = Get.find(); //이미 있는 컨트롤러라 find
  final commentWriteController = TextEditingController();
  //스크롤 초기 설정 필요함
  ScrollController controller =
      new ScrollController(initialScrollOffset: 10000);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        mailController
            .setDataAvailableMailSendPageFalse(); //뒤로가기 눌렀을때 이 메일함의 dataavailabe을 false로 설정
        Get.back();
        return;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('polarStar'),
            actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
          ),
          body: RefreshIndicator(
            onRefresh: mailController.getMail,
            child: Stack(
              children: [
                ListView(),
                Obx(() {
                  if (mailController.dataAvailableMailSendPage) {
                    //data가 available한 상태인지 확인
                    return Container(
                      margin: const EdgeInsets.only(bottom: 60),
                      child: ListView.builder(
                        controller: controller,
                        itemCount: mailController.mailSendData.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        itemBuilder: (context, index) {
                          return Container(
                              padding:
                                  EdgeInsets.only(left: 14, right: 14, top: 10),
                              child: Align(
                                //sentMessage가 1이면 본인, 아니면 상대방
                                alignment: (mailController.mailSendData[index]
                                            ["sentMessage"] ==
                                        0
                                    ? Alignment.topLeft
                                    : Alignment.topRight),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    //sentMessage가 1이면 본인, 아니면 상대방
                                    color: (mailController.mailSendData[index]
                                                ["sentMessage"] ==
                                            0
                                        ? Colors.grey.shade400
                                        : Colors.blue[200]),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: (mailController.mailSendData[index]
                                              ["sentMessage"] ==
                                          0
                                      ? Text(
                                          '${mailController.opponentProfile["nickname"]} : ${mailController.mailSendData[index]["content"]}',
                                          style: TextStyle(fontSize: 15))
                                      : Text(
                                          '${mailController.mailSendData[index]["content"]}',
                                          style: TextStyle(fontSize: 15))),
                                ),
                              ));
                        },
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                })
              ],
            ),
          ),
          //입력창
          bottomSheet: Container(
            height: 60,
            child: Stack(children: [
              //키보드
              Container(
                child: TextFormField(
                  controller: commentWriteController,
                  onFieldSubmitted: (value) {
                    sendMail(commentWriteController, controller);
                  },
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      hintText: "쪽지 보내기", border: OutlineInputBorder()),
                ),
              ),
              Positioned(
                top: 15,
                right: 20,
                child: InkWell(
                  onTap: () {
                    sendMail(commentWriteController, controller);
                  },
                  child: Icon(
                    Icons.send,
                    size: 30,
                  ),
                ),
              ),
            ]),
          )),
    );
  }

  //쪽지 보내느 함수
  void sendMail(commentWriteController, controller) async {
    if (commentWriteController.text.trim().isEmpty) {
      //빈 값 보내면 snackBar 반환
      Get.snackbar("텍스트를 입력해주세요", "텍스트를 입력해주세요",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Map messageData = {
      "message_box_id": "${mailController.message_box_id.value}",
      'content': "${commentWriteController.text}",
    };

    print(messageData);
    print(mailController.mailSendData.length);

    String postUrl = "/message";

    var response = await Session().postX(postUrl, messageData);

    print(response.statusCode);

    //mailSendData(Obs)에 추가 =>  돔 자동 수정
    mailController.mailSendData.add({
      "sentMessage": 1,
      "content": commentWriteController.text,
      "creation_date": "2021-08-06T10:11:55.457Z"
    });

    //쪽지 보내면 자동으로 스크롤을 최하단으로 가게 하는 코드
    //근데 시부레 안됨 ㅈ같네
    controller.animateTo(controller.position.maxScrollExtent,
        duration: Duration(microseconds: 300), curve: Curves.easeOut);

    //쪽지 보내고나면 텍스트 입력창 다시 초기화
    commentWriteController.clear();
  }
}
