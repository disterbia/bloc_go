import 'package:better_player/better_player.dart';
import 'package:eatall/app/bloc/user_profile_bloc.dart';
import 'package:eatall/app/bloc/video_stream_bloc.dart';
import 'package:eatall/app/view/four_page.dart';
import 'package:eatall/app/view/user_profile.dart';
import 'package:eatall/app/widget/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoScreenPage extends StatelessWidget {

  bool isFirst = true;
  PageController _horizontalController = PageController(initialPage: 1);
  PageController _verticalController = PageController();
  int _currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoStreamBloc, VideoState>(
        builder: (context, videostate) {
              return PageView.builder(
                onPageChanged: (hNextIndex) async{
                  if (hNextIndex != 1) { // 중앙 페이지(동영상 목록)가 아닌 경우
                        await videostate.betterPlayerControllers![_currentIndex]!.videoPlayerController!.seekTo(Duration.zero);
                        await videostate.betterPlayerControllers![_currentIndex]?.pause();
                  }
                  else{
                    _verticalController.jumpToPage(_currentIndex);
                    await Future.delayed(Duration(milliseconds: 500));
                    await videostate.betterPlayerControllers![_currentIndex]?.play();
                  }
                },
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int hIndex) {
                  if (hIndex == 1) {
                    return PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _verticalController,
                      itemCount: videostate.betterPlayerControllers!.length,
                      onPageChanged: (vNextindex) async {
                          await videostate.betterPlayerControllers![vNextindex]!.play();
                          await videostate.betterPlayerControllers![_currentIndex]!.videoPlayerController!.seekTo(Duration.zero);
                          await videostate.betterPlayerControllers![_currentIndex]?.pause();
                          if (vNextindex ==
                              videostate.betterPlayerControllers!.length - 2 && vNextindex>_currentIndex) {
                            context.read<VideoStreamBloc>().add(LoadVideoEvent(page:videostate.betterPlayerControllers!.length,url: videostate.videoUrl![0]));
                          }
                          _currentIndex = vNextindex;


                      },
                      itemBuilder: (BuildContext context, int vindex) {
                        if (isFirst && vindex == 0) {
                          isFirst = false;
                          videostate.betterPlayerControllers![0]?.play();
                        }
                        return WillPopScope(
                          onWillPop: () async {
                            await videostate.betterPlayerControllers![vindex]!
                                .videoPlayerController!
                                .seekTo(Duration.zero);
                            await videostate.betterPlayerControllers![vindex]
                                ?.pause();
                            return true;
                          },
                          child: Stack(
                            children: [
                              videostate.betterPlayerControllers![vindex] !=
                                  null
                                  ? BetterPlayer(
                                  controller: videostate
                                      .betterPlayerControllers![vindex]!)
                                  : Center(child: CircularProgressIndicator()),
                              Positioned(
                                bottom: 25,
                                left: 25,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(videostate.video![vindex].title),
                                    Text(videostate.video![vindex].uploader),
                                    Text(videostate.video![vindex].likeCount.toString()),
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
                                                    child: chatWidget(context, videostate.video![vindex].url),
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
                    );
                  } else {
                    if(hIndex==2){
                      context.read<UserProfileBloc>().add(GetUserProfileVideosEvent(userId: videostate.video![_currentIndex].userInfo.id));
                      return UserProfile(videostate.video![_currentIndex]);
                    }
                    else return FollowingPage(
                      creators: [
                        Creator(
                          name: 'Creator 1',
                          imageUrl: 'https://example.com/image1.jpg',
                          videoUrl: 'https://example.com/video1.jpg',
                          followers: 1000,
                          following: 50,
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
