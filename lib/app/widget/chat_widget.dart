import 'package:eatall/app/bloc/chat_bloc.dart';
import 'package:eatall/app/router/custom_go_router.dart';
import 'package:eatall/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

ScrollController _listViewController = ScrollController();
Widget chatWidget(BuildContext context, String videoId) {
  context.read<ChatBloc>().add(NewChatEvent(videoId));
  return BlocBuilder<ChatBloc, ChatState>(
    builder: (context, chatstate) {
      return Scaffold(
        body: chatstate is !ChatChange?Center(child: CircularProgressIndicator(),):Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _listViewController,
                itemCount: chatstate.messages!.length,
                itemBuilder: (context, bindex) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatstate.messages![bindex].username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(chatstate.messages![bindex].text),
                        Text(
                          chatstate.messages![bindex].sendTime,
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
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
                      controller: chatstate.controller,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요.',
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                      onSubmitted: (text) => context.read<ChatBloc>().add(
                          SendMessageEvent(text: text, userId: UserID.uid!)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.black),
                    onPressed: () => UserID.uid==null?context.push(MyRoutes.Login):
                        context.read<ChatBloc>().add(
                        SendMessageEvent(
                            text: chatstate.controller!.text,
                            userId: UserID.uid!)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}