import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;

  ChatScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  IOWebSocketChannel? _channel;
  String? _roomId;

  void clearMessages() {
    setState(() {
      _messages.clear();
    });
  }
  void updateRoomId(String roomId) {
    _roomId = roomId;
  }

  void connectWebSocket() {
    if (_channel == null && _roomId != null) {
      setupWebSocket();
    }
  }
  void disposeWebSocket() {
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }
  // @override
  // void initState() {
  //   super.initState();
  //   setupWebSocket();
  // }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_isInitialized) {
  //     setupWebSocket();
  //     _isInitialized = true;
  //   }
  // }

  void setupWebSocket() {
    _channel = IOWebSocketChannel.connect(
        'ws://192.168.0.88:8080/ws?roomId=${widget.roomId}');
    _channel!.stream.listen((event) {
      Map<String, dynamic> messageData = jsonDecode(event);
      setState(() {
        _messages.add(Message.fromJson(messageData));
      });
    });
  }

  @override
  void dispose() {
    disposeWebSocket();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.isNotEmpty) {
      _channel!.sink.add(jsonEncode({"username": "User", "text": text}));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_messages[index].username),
                subtitle: Text(_messages[index].text),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: '메시지를 입력하세요.'),
                  onSubmitted: _sendMessage,
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Message {
  final String username;
  final String text;

  Message({required this.username, required this.text});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(username: json['username'], text: json['text']);
  }
}
