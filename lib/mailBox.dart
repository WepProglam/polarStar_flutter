import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'session.dart';
import 'getXController.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class MailBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mailController = Get.put(MailController());
    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
        ),
        body: FutureBuilder(
          future: mailController.getMailBox(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    for (var item in snapshot.data)
                      InkWell(
                        onTap: () {
                          Get.toNamed("/mailBox/sendMail", arguments: {
                            "message_box_id": '${item["message_box_id"]}'
                          });
                          print(item);
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
                                  child: Text(
                                    "${item["opponent"]}",
                                    textScaleFactor: 1.2,
                                  ),
                                  flex: 30,
                                ),
                                Expanded(
                                  child: Text(
                                    "${item["content"]}",
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1.2,
                                  ),
                                  flex: 100,
                                ),
                                Expanded(
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
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text("snapshot.error");
            }
            return CircularProgressIndicator();
          },
        ));
  }
}

class SendMail extends StatelessWidget {
  Map arg = Get.arguments;
  final mailController = Get.put(MailController());

  @override
  Widget build(BuildContext context) {
    String message_box_id = arg["message_box_id"];
    print(url);
    final c = Get.put(PostController());
    var commentWriteController = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text('polarStar'),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
        ),
        body: FutureBuilder(
          future: mailController.getMail("/message/${message_box_id}"),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data["messages"]);
              print(mailController.mailData.value);
              print(mailController.mailData.value);
              print(mailController.mailData.value);
              print(mailController.mailData.value);
              print(mailController.mailData.value);
              /**/
              return Obx(() {
                return ListView.builder(
                  itemCount: mailController.mailSendingData.value.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  //physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Obx(() {
                      return Container(
                          padding:
                              EdgeInsets.only(left: 14, right: 14, top: 10),
                          child: Align(
                            alignment: (mailController.mailSendingData
                                        .value[index]["sentMessage"] ==
                                    0
                                ? Alignment.topLeft
                                : Alignment.topRight),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: (mailController.mailSendingData
                                            .value[index]["sentMessage"] ==
                                        0
                                    ? Colors.grey.shade400
                                    : Colors.blue[200]),
                              ),
                              padding: EdgeInsets.all(16),
                              child: (mailController.mailSendingData
                                          .value[index]["sentMessage"] ==
                                      0
                                  ? Text(
                                      '${mailController.mailData.value["profile"]["nickname"]} : ${mailController.mailSendingData.value[index]["content"]}',
                                      style: TextStyle(fontSize: 15))
                                  : Text(
                                      '${mailController.mailSendingData.value[index]["content"]} :  Me(${mailController.mailData.value["profile"]["nickname"]})',
                                      style: TextStyle(fontSize: 15))),
                            ),
                          ));
                    });
                  },
                );
              });
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text("snapshot.error");
            }
            return CircularProgressIndicator();
          },
        ),
        bottomSheet: Container(
          height: 60,
          child: Stack(children: [
            Container(
                child: Obx(
              () => TextFormField(
                controller: commentWriteController,
                autofocus: c.autoFocusTextForm.value,
                onFieldSubmitted: (value) {
                  print(value);
                  commentWriteController.clear();
                },
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                    hintText: "쪽지 보내기", border: OutlineInputBorder()),
              ),
            )),
            Positioned(
              top: 15,
              right: 20,
              child: InkWell(
                onTap: () async {
                  Map messageData = {
                    "message_box_id": message_box_id,
                    'content': commentWriteController.text,
                  };

                  print(messageData);

                  String postUrl = "/message";

                  var response = await Session().postX(postUrl, messageData);

                  //{sentMessage: 0, content: sent from your post/comment: asdfagd, creation_date: 2021-08-06T10:11:55.457Z}
                  mailController.mailSendingData.value.add({
                    "sentMessage": 0,
                    "content": commentWriteController.text,
                    "creation_date": "2021-08-06T10:11:55.457Z"
                  });

                  print(response.statusCode);
                  /*if (c.isCcomment.value) {
                    postUrl = c.ccommentUrl.value;
                  } else {
                    postUrl = commentPostUrl(arg['boardUrl']);
                  }

                  if (c.autoFocusTextForm.value) {
                    Session()
                        .putX(c.putUrl.value, commentData)
                        .then((value) => setState(() {}));
                  } else {
                    Session()
                        .postX(postUrl, commentData)
                        .then((value) => setState(() {}));
                  }*/
                },
                child: Icon(
                  Icons.send,
                  size: 30,
                ),
              ),
            ),
          ]),
        ));
  }
}
