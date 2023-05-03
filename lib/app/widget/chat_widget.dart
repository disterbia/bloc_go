import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/router/custom_go_router.dart';
import 'package:DTalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


Widget chatWidget(BuildContext context, String videoId) {
  return BlocBuilder<ChatBloc,ChatState>(
    builder: (context,chatstate) {
      return Scaffold(resizeToAvoidBottomInset: true,
        body: chatstate.chatRoomStates[videoId]==null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: chatstate.chatRoomStates[videoId]!.messages.length==0?Center(child: Text("채팅 내역이 없습니다."),):ListView.builder(
                      itemCount:  chatstate.chatRoomStates[videoId]!.messages.length,
                      itemBuilder: (context, bindex) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatstate.chatRoomStates[videoId]!.messages[bindex].username,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text( chatstate.chatRoomStates[videoId]!.messages[bindex].text),
                              Text(
                                chatstate.chatRoomStates[videoId]!.messages[bindex].sendTime!,
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
                            controller: chatstate.chatRoomStates[videoId]?.controller,
                            decoration: InputDecoration(
                              hintText: '메시지를 입력하세요.',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            onSubmitted: (text) => UserID.uid==null?context.push(MyRoutes.Login):context.read<ChatBloc>().add(
                                SendMessageEvent(roomId: videoId,text: text, userId: UserID.uid!)),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.black),
                          onPressed: () => UserID.uid == null
                              ? context.push(MyRoutes.Login)
                              : context.read<ChatBloc>().add(SendMessageEvent(roomId: videoId,
                                  text: chatstate.chatRoomStates[videoId]!.controller.text,
                                  userId: UserID.uid!)),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
      );
    }
  );
}
