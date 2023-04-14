import 'package:better_player/better_player.dart';
import 'package:eatall/app/bloc/chat_bloc.dart';
import 'package:eatall/app/bloc/video_stream_bloc.dart';
import 'package:eatall/app/view/four_page.dart';
import 'package:eatall/app/view/user_profile.dart';
import 'package:eatall/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoScreenPage extends StatelessWidget {

  bool isFirst = true;
  PageController _horizontalController = PageController(initialPage: 1);
  PageController _verticalController = PageController();
  ScrollController _listViewController = ScrollController();

  Widget chatWidget(BuildContext context, String videoId) {
    context.read<ChatBloc>().add(NewChatEvent(videoId));
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, chatstate) {
        return Scaffold(
          body: chatstate.isLoading!?Center(child: CircularProgressIndicator(),):Column(
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
                      onPressed: () => context.read<ChatBloc>().add(
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoStreamBloc, VideoState>(
        builder: (context, videostate) {
              return PageView.builder(
                onPageChanged: (value) {
                  if (value != 1) { // 중앙 페이지(동영상 목록)가 아닌 경우
                    for (int i = 0; i < videostate.betterPlayerControllers!.length; i++) {
                      if(videostate.betterPlayerControllers![i]!.isPlaying()!){
                        videostate.betterPlayerControllers![i]!.videoPlayerController!.seekTo(Duration.zero);
                        videostate.betterPlayerControllers![i]?.pause();
                      }
                    }
                  }
                },
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
                          child: Stack(
                            children: [
                              videostate.betterPlayerControllers![aindex] !=
                                  null
                                  ? BetterPlayer(
                                  controller: videostate
                                      .betterPlayerControllers![aindex]!)
                                  : Center(child: CircularProgressIndicator()),
                              Positioned(
                                bottom: 25,
                                left: 25,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(videostate.video![aindex].title),
                                    Text(videostate.video![aindex].uploader),
                                    Text(videostate.video![aindex].likeCount.toString()),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 25,
                                right: 25,
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (BuildContext context) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          icon: Icon(Icons.close, color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: chatWidget(context, videostate.video![aindex].url),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Icon(Icons.comment),
                                    ),
                                    // 다른 아이콘들을 여기에 추가하세요.
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: videostate.betterPlayerControllers!.length,
                      onPageChanged: (int nindex) async {
                        for (int i = 0; i < videostate.betterPlayerControllers!.length; i++) {
                          if (i == nindex) {
                            await videostate.betterPlayerControllers![nindex]!.play();
                          } else {
                            if(videostate.betterPlayerControllers![i]!.isPlaying()!){
                              await videostate.betterPlayerControllers![i]!.videoPlayerController!.seekTo(Duration.zero);
                              await videostate.betterPlayerControllers![i]?.pause();
                            }
                          }
                        }

                        if (nindex ==
                            videostate.betterPlayerControllers!.length - 2) {
                          context.read<VideoStreamBloc>().add(LoadVideoEvent(page:videostate.betterPlayerControllers!.length,url: videostate.videoUrl![nindex]));
                        }
                      },
                    );
                  } else {
                    if(hIndex==2)
                    return UserProfile();
                    else return FollowingPage(
                      creators: [
                        Creator(
                          name: 'Creator 1',
                          imageUrl: 'https://example.com/image1.jpg',
                          videoUrl: 'https://example.com/video1.jpg',
                          followers: 1000,
                          following: 50,
                        ),
                        Creator(
                          name: 'Creator 2',
                          imageUrl: 'https://example.com/image2.jpg',
                          videoUrl: 'https://example.com/video2.jpg',
                          followers: 2000,
                          following: 100,
                        ),
                        // Add more creators if needed.
                      ],
                    );
                  }
                },
                itemCount: 3, // 왼쪽, 중앙, 오른쪽 페이지를 위한 항목 수입니다.
              );
            },
      );
  }
}
