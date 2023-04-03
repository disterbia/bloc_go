import 'package:eatall/app/view/chat_page.dart';
import 'package:eatall/app/view/videostream.dart';
import 'package:flutter/material.dart';

class VideoChatPage extends StatefulWidget {

  @override
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
      VideoScreenPage()
    ]),);
  }
}
