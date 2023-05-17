import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Developer Easter Egg")),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("MADE BY CHA SEUNG HAN")),
          Text("010-2229-6713"),
          Text("disterbia94@gmail.com"),
        ],
      ),
    );
  }
}
