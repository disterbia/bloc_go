import 'package:chewie/chewie.dart';
import 'package:eatall/app/bloc/chat_bloc.dart';
import 'package:eatall/app/bloc/video_stream_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class VideoScreenPage extends StatelessWidget {
  VideoScreenPage(this.id);
  String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VideoStreamBloc,VideoState>(
        builder: (context, videostate) {
          return BlocBuilder<ChatBloc,ChatState>(
            builder: (context, chatstate) {
              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int aindex) {
                  if(aindex==0) {
                    Future.delayed(Duration.zero, () {
                      videostate.chewieControllers![aindex]?.play();
                    });
                  }
                  return Column(
                    children: [
                      Expanded(child: videostate.chewieControllers![aindex] != null
                          ? Chewie(controller: videostate.chewieControllers![aindex]!)
                          : Center(child: CircularProgressIndicator())),
                      Expanded(child:  Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: chatstate.messages!.length,
                              itemBuilder: (context, bindex) {
                                print("==================${chatstate.messages![bindex].text}");
                                return ListTile(
                                  title: Text(chatstate.messages![bindex].username),
                                  subtitle: Text(chatstate.messages![bindex].text),
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
                                    decoration: InputDecoration(hintText: '메시지를 입력하세요.'),
                                    onSubmitted:(text)=> context.read<ChatBloc>().add(SendMessageEvent(text: text)),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: () => context.read<ChatBloc>().add(SendMessageEvent(text: chatstate.controller!.text)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                    ],
                  );
                },
                itemCount: videostate.chewieControllers!.length,
                onPageChanged: (int nindex) {
                  for (int i = 0; i < videostate.chewieControllers!.length; i++) {
                    if (i == nindex) {
                      Future.delayed(Duration(milliseconds: 200), () {
                        videostate.chewieControllers![nindex]?.play();
                      });
                      context.read<ChatBloc>().add(NewChatEvent(nindex.toString()));
                    } else {
                      videostate.chewieControllers![i]?.pause();
                      videostate.chewieControllers![i]?.videoPlayerController.seekTo(Duration.zero);
                    }
                  }

                  if (nindex == videostate.chewieControllers!.length - 2) {
                   context.read<VideoStreamBloc>().add(LoadVideoEvent());
                  }
                },
              );
            }
          );
        }
      ),
    );
  }

}