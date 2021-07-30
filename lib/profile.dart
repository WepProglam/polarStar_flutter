import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'session.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
      ),
      body: UserProfile(),
    );
  }
}

class UserProfile extends StatefulWidget {
  UserProfile({Key key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('profile'),
    );
  }
}
