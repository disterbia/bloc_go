import 'package:better_player/better_player.dart';
import 'package:eatall/app/bloc/user_profile_bloc.dart';
import 'package:eatall/app/bloc/video_stream_bloc.dart';
import 'package:eatall/app/model/video_stream.dart';
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
  bool isbackHorizon=false;
  BetterPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoStreamBloc, VideoState>(
        builder: (context, videostate) {
          List<VideoStream>? videos = videostate.video;
          return PageView.builder(
                onPageChanged: (hNextIndex) async{
                  context.read<VideoStreamBloc>().add(PlayAndPauseEvent());
                  if (hNextIndex == 1) { // 중앙 페이지(동영상 목록)가 아닌 경우
                    isbackHorizon=true;
                    _verticalController.jumpToPage(_currentIndex);
                    isbackHorizon=false;
                  }
                },
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int hIndex) {
                  if (hIndex == 1) {
                    return PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _verticalController,
                      itemCount: videostate.video!.length,
                      onPageChanged: (vNextIndex) async {
                        if(isbackHorizon) return;
                          // 이전 동영상으로 이동
                          if (vNextIndex < _currentIndex) {
                              if (videostate.nextController != null) {
                                videostate.nextController!.dispose(forceDispose: true);
                              }
                                context.read<VideoStreamBloc>().add(UpdatePrevVideoControllers(currentIndex: _currentIndex));

                          }
                          // 다음 동영상으로 이동
                          else {
                              if (videostate.prevController != null) {
                                videostate.prevController!.dispose(forceDispose: true);
                              }
                              context.read<VideoStreamBloc>().add(UpdateNextVideoControllers(currentIndex: _currentIndex));
                          }

                          // 새로운 인덱스로 업데이트하고 다음 동영상 재생
                          _currentIndex = vNextIndex;
                      },
                      itemBuilder: (BuildContext context, int vindex) {
                        if (isFirst && vindex == 0) {
                          isFirst = false;
                          videostate.currentController?.play();
                        }

                        if (vindex == _currentIndex) {
                          controller = videostate.currentController;
                        } else if (vindex == _currentIndex - 1) {
                          controller = videostate.prevController;
                        } else if (vindex == _currentIndex + 1) {
                          controller = videostate.nextController;
                        }
                        return WillPopScope(
                          onWillPop: () async {
                            await videostate.currentController?.seekTo(Duration.zero);
                            await videostate.currentController?.pause();
                            return true;
                          },
                          child: Stack(
                            children: [
                          videostate.currentController !=
                                  null
                                  ? BetterPlayer(
                                  controller: controller!)
                                  : Center(child: CircularProgressIndicator()),
                              Positioned(
                                bottom: 25,
                                left: 25,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(videos![vindex].title),
                                    Text(videos[vindex].uploader),
                                    Text(videos[vindex].likeCount.toString()),
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
                      context.read<UserProfileBloc>().add(GetUserProfileVideosEvent(userId: videos![_currentIndex].userInfo.id));
                      return UserProfile(videos[_currentIndex]);
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
