import 'package:Dtalk/app/bloc/chat_bloc.dart';
import 'package:Dtalk/app/bloc/user_video_bloc.dart';
import 'package:Dtalk/app/bloc/video_stream_bloc.dart';
import 'package:Dtalk/app/const/addr.dart';
import 'package:Dtalk/app/router/custom_go_router.dart';
import 'package:Dtalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


Widget chatWidget(BuildContext context, String videoId) {
  return WillPopScope(
    onWillPop: () async{
      context.read<UserVideoBloc>().add(UserVideoPlayEvent());
      return true;
    },
    child: BlocBuilder<ChatBloc,ChatState>(
      builder: (context,chatstate) {
        return Scaffold(
          body: chatstate.chatRoomStates[videoId]==null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    SizedBox(height: 40.h,),
                    IconButton(
                      onPressed: () {
                        context.pop();
                        context.read<UserVideoBloc>().add(UserVideoPlayEvent());

                      },
                      icon: Image.asset("assets/img/sh_x.png",color: Colors.grey,),
                    ),
                    Expanded(
                      child: chatstate.chatRoomStates[videoId]!.messages.length==0?Center(child: Text("채팅 내역이 없습니다."),):ListView.builder(
                        itemCount:  chatstate.chatRoomStates[videoId]!.messages.length,
                        itemBuilder: (context, bindex) {
                          return Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                chatstate.chatRoomStates[videoId]!.messages[bindex].userImage==""?Container(height: 30.h,child: CircleAvatar(backgroundImage: AssetImage("assets/img/profile3_s.png"),)):
                                Container(height: 30.h,child: CircleAvatar(backgroundColor: Colors.transparent,backgroundImage: NetworkImage(chatstate.chatRoomStates[videoId]!.messages[bindex].userImage,),)),
                                SizedBox(width: 5,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5,),
                                    Text(
                                      chatstate.chatRoomStates[videoId]!.messages[bindex].nickname,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text( chatstate.chatRoomStates[videoId]!.messages[bindex].text,style: TextStyle(fontWeight: FontWeight.w100),),
                                    Builder(
                                      builder: (context) {
                                          String showTime;
                                          DateTime timestamp = DateTime.parse(chatstate.chatRoomStates[videoId]!.messages[bindex].sendTime!);
                                          DateTime now = DateTime.now();
                                          Duration difference = now.difference(timestamp);

                                          if (difference.inSeconds < 60) {
                                            showTime='방금전';
                                          } else if (difference.inMinutes < 60) {
                                            showTime= '${difference.inMinutes}분 전';
                                          } else if (difference.inHours < 24) {
                                            showTime= '${difference.inHours}시간 전';
                                          } else {
                                            showTime= DateFormat('MM/dd').format(timestamp);
                                          }

                                        return Text(
                                          showTime,
                                          style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: chatstate.chatRoomStates[videoId]?.controller,
                          decoration: InputDecoration(suffixIcon: IconButton(padding: EdgeInsets.all(15),
                            icon: Image.asset("assets/img/ic_message.png"),
                            onPressed: () => UserID.uid == null
                                ? context.push(MyRoutes.Login)
                                : context.read<ChatBloc>().add(SendMessageEvent(roomId: videoId,
                                text: chatstate.chatRoomStates[videoId]!.controller.text,
                                userId: UserID.uid!,
                            userImage: UserID.userImage!,
                            nickname: UserID.nickname!)),
                          ) ,
                            focusedBorder:OutlineInputBorder(
                              borderSide:  BorderSide(color: Address.color, width: 2.0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            hintText: '메시지를 입력하세요.',
                            hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onFieldSubmitted: (text) => UserID.uid==null?context.push(MyRoutes.Login):context.read<ChatBloc>().add(
                              SendMessageEvent(roomId: videoId,text: text, userId: UserID.uid!, userImage: UserID.userImage!,
                                  nickname: UserID.nickname!)),
                        ),
                      ),
                    ),

                  ],
                ),
        );
      }
    ),
  );
}
