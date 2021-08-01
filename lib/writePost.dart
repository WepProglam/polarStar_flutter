import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'session.dart';
import 'dart:convert';
import 'getXController.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';

class WritePost extends StatefulWidget {
  @override
  _WritePostState createState() => _WritePostState();
}

class _WritePostState extends State<WritePost> {
  XFile _image;
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  Controller c = Controller();
  Map arg = Get.arguments;

  final ImagePicker _picker = ImagePicker();
  TextEditingController photoName = TextEditingController();

  @override
  void initState() {
    if (arg['item'] != null) {
      setState(() {
        title.text = arg['item']['title'].toString();
        content.text = arg['item']['content'].toString();
        if (arg['item']['photo'] != null) {
          _image = XFile(
              'http://http://ec2-3-37-156-121.ap-northeast-2.compute.amazonaws.com:3000${arg['item']['photo']}');
        }
      });
    }

    super.initState();
  }

  getGalleryImage(String titleStr, String contentStr) async {
    var img = await _picker.pickImage(source: ImageSource.gallery);
    print(titleStr);
    setState(() {
      _image = img;
      title.text = titleStr;
      content.text = contentStr;
    });
  }

  getCameraImage(String title, String content) async {
    var img = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = img;
    });
  }

  Future postPost(String arg, Map data) async {
    String url = '/board/$arg';
    Session().postX(url, data).then((value) {
      switch (value.statusCode) {
        case 200:
          Get.back();
          break;
        case 401:
          Session().getX('/logout');
          Get.offAllNamed('/login');
          break;
        case 403:
          Get.snackbar('Forbidden', 'Forbidden');
          break;
        case 404:
          Get.snackbar('Type is not founded', 'type is not founded');
          Get.back();
          break;
        default:
          print(value.statusCode);
      }
    });
  }

  Future upload(String arg, XFile imageFile, Map data) async {
    var request = Session().multipartReq('/board/$arg');

    var pic = await http.MultipartFile.fromPath("photo", imageFile.path);
    //contentType: new MediaType('image', 'png'));

    request.files.add(pic);
    request.fields['title'] = data['title'];
    request.fields['description'] = data['description'];
    request.fields['unnamed'] = data['unnamed'];
    print(request.files[0].filename);
    var response = await request.send();
    print(response.statusCode);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Map data = {
                    'title': title.text,
                    'description': content.text,
                    'unnamed': c.anonymousCheck.value ? '1' : '0',
                  };

                  if (_image != null) {
                    upload(arg['type'].toString(), _image, data).then((value) {
                      switch (value.statusCode) {
                        case 200:
                          Get.back();
                          break;
                        case 401:
                          // Get.snackbar('login error', 'session expired');
                          // Session().getX('/logout');
                          // Get.offAllNamed('/login');
                          break;
                        case 403:
                          Get.snackbar('Forbidden', 'Forbidden');

                          break;
                        case 404:
                          Get.snackbar(
                              'Type is not founded', 'type is not founded');
                          Get.back();
                          break;
                        default:
                          print(value.statucCode);
                      }
                    });
                  } else {
                    postPost(arg['type'].toString(), data);
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: Text('작성'),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TextFormField(
            controller: title,
            // textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '제목을 작성하세요.',
              isDense: true,
            ),
          ),
          TextFormField(
            controller: content,
            // textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '내용을 작성하세요.',
              isDense: true,
            ),
            maxLines: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    onTap: () {
                      getGalleryImage(title.text, content.text);
                    },
                    child: Icon(Icons.photo),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    onTap: () {
                      getCameraImage(title.text, content.text);
                    },
                    child: Icon(Icons.photo_camera),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 100,
                    height: 20,
                    child: TextField(
                      style: TextStyle(fontSize: 10),
                      enabled: false,
                      controller: photoName,
                      decoration: InputDecoration(hintText: 'photo name'),
                    ),
                  ),
                ),
                Spacer(),
                GetBuilder<Controller>(
                  // init: Controller(), // GetBuilder안 init
                  builder: (c) {
                    return Container(
                      height: 20,
                      width: 20,
                      child: Transform.scale(
                        scale: 1,
                        child: Checkbox(
                          value: c.anonymousCheck.value,
                          onChanged: (value) {
                            c.changeAnonymous(value);
                          },
                        ),
                      ),
                    );
                  },
                ),
                Text(' 익명'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
