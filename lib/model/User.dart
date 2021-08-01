import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

class User {
  int pid;
  String uid;
  int deleted;
  String nickname;
  String school;
  String photo;
  String profilemsg;
  Map<String, dynamic> likes;
  List<dynamic> friends;
  List<dynamic> buffer;
  int arrest;
  List<dynamic> scrap;

  User(
      {this.pid,
      this.uid,
      this.deleted,
      this.nickname,
      this.school,
      this.photo,
      this.profilemsg,
      this.likes,
      this.friends,
      this.buffer,
      this.arrest,
      this.scrap});
  User.fromJson(Map<String, dynamic> item) {
    pid = item['pid'];
    uid = item['uid'];
    deleted = item['deleted'];
    nickname = item['nickname'];
    school = item['school'];
    photo = item['photo'];
    profilemsg = item['profilemsg'];
    likes = (item['likes']);
    friends = (item['friends']);
    buffer = (item['buffer']);
    arrest = item['arrest'];
    scrap = item['scrap'];
  }
}
