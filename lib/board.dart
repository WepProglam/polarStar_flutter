import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'session.dart';

class Board extends StatelessWidget {
  const Board({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BoardState();
  }
}

class BoardState extends StatefulWidget {
  BoardState({Key key}) : super(key: key);

  @override
  _BoardStateState createState() => _BoardStateState();
}

class _BoardStateState extends State<BoardState> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: null,
    );
  }
}
