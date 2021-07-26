import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('polarStar'),
        actions: [
          IconButton(
              onPressed: () {
                Session().get('http://10.0.2.2:3000/logout');
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false);
              },
              icon: Text('LOGOUT')),
          IconButton(onPressed: () {}, icon: Icon(Icons.person)),
        ],
      ),
      body: MainBoards(),
    );
  }
}

class MainBoards extends StatefulWidget {
  MainBoards({Key key}) : super(key: key);

  @override
  _MainBoardsState createState() => _MainBoardsState();
}

class _MainBoardsState extends State<MainBoards> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 8,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Search'),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      onPressed: () {}, icon: Icon(Icons.search_outlined))),
              Spacer(
                flex: 1,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              OutlinedButton(onPressed: () {}, child: Text('board1')),
              Spacer(),
              OutlinedButton(onPressed: () {}, child: Text('board2')),
              Spacer(),
              OutlinedButton(onPressed: () {}, child: Text('board3')),
              Spacer(),
              OutlinedButton(onPressed: () {}, child: Text('board4')),
              Spacer(),
            ],
          ),
          OutlinedButton(
              onPressed: () {
                Session().get('http://10.0.2.2:3000/logout');
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false);
              },
              child: Text('LOGOUT')),
        ],
      ),
    );
  }
}
