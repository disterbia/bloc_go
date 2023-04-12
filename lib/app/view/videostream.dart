import 'package:better_player/better_player.dart';
import 'package:eatall/app/bloc/chat_bloc.dart';
import 'package:eatall/app/bloc/video_stream_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoScreenPage extends StatelessWidget {
  VideoScreenPage(this.id);

  String id;
  bool isFirst = true;
  PageController _horizontalController = PageController(initialPage: 1);
  PageController _verticalController = PageController();
  ScrollController _listViewController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoStreamBloc, VideoState>(
        builder: (context, videostate) {
          return BlocBuilder<ChatBloc, ChatState>(
            builder: (context, chatstate) {
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    if (scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent) {
                      _verticalController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else if (scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.minScrollExtent) {
                      if (_verticalController.page != null &&
                          _verticalController.page! > 0) {
                        _verticalController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int hIndex) {
                    if (hIndex == 1) {
                      return PageView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _verticalController,
                        itemBuilder: (BuildContext context, int aindex) {
                          if (isFirst && aindex == 0) {
                            isFirst = false;
                            videostate.betterPlayerControllers![0]?.play();
                          }
                          return WillPopScope(
                            onWillPop: () async {
                              await videostate.betterPlayerControllers![aindex]!
                                  .videoPlayerController!
                                  .seekTo(Duration.zero);
                              await videostate.betterPlayerControllers![aindex]
                                  ?.pause();
                              return true;
                            },
                            child: Column(
                              children: [
                                Expanded(
                                    child: videostate.betterPlayerControllers![
                                                aindex] !=
                                            null
                                        ? BetterPlayer(
                                            controller: videostate
                                                    .betterPlayerControllers![
                                                aindex]!)
                                        : Center(
                                            child:
                                                CircularProgressIndicator())),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _listViewController,
                                        itemCount: chatstate.messages!.length,
                                        itemBuilder: (context, bindex) {
                                          return ListTile(
                                            title: Text(chatstate
                                                .messages![bindex].username),
                                            subtitle: Text(chatstate
                                                .messages![bindex].text),
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: chatstate.controller,
                                              decoration: InputDecoration(
                                                  hintText: '메시지를 입력하세요.'),
                                              onSubmitted: (text) => context
                                                  .read<ChatBloc>()
                                                  .add(SendMessageEvent(
                                                      text: text,
                                                      userId:
                                                          "id.substring(0, 5)")),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.send),
                                            onPressed: () => context
                                                .read<ChatBloc>()
                                                .add(SendMessageEvent(
                                                    text: chatstate
                                                        .controller!.text,
                                                    userId:
                                                        "id.substring(0, 5)")),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                              ],
                            ),
                          );
                        },
                        itemCount: videostate.betterPlayerControllers!.length,
                        onPageChanged: (int nindex) async {

                          for (int i = 0;
                              i < videostate.betterPlayerControllers!.length;
                              i++) {
                            if (i == nindex) {
                              print("-=-=-${ nindex}");
                              context
                                  .read<ChatBloc>()
                                  .add(NewChatEvent(nindex.toString()));
                              await videostate.betterPlayerControllers![nindex]!.play();
                            } else {
                             await videostate.betterPlayerControllers![i]!.videoPlayerController!.seekTo(Duration.zero);
                             await videostate.betterPlayerControllers![i]?.pause();
                            }
                          }

                          if (nindex ==
                              videostate.betterPlayerControllers!.length - 2) {
                            context
                                .read<VideoStreamBloc>()
                                .add(LoadVideoEvent());
                          }
                        },
                      );
                    } else {
                      if(hIndex==2)
                      return Container(child: Center(child: Text("마이페이지")),);
                      else return Container(child: Center(child: Text("다른페이지")),);
                    }
                  },
                  itemCount: 3, // 왼쪽, 중앙, 오른쪽 페이지를 위한 항목 수입니다.
                ),
              );
            },
          );
        },
      );
  }
}
