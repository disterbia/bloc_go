import 'package:better_player/better_player.dart';
import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/bloc/user_profile_bloc.dart';
import 'package:DTalk/app/bloc/video_stream_bloc.dart';
import 'package:DTalk/app/model/video_stream.dart';
import 'package:DTalk/app/view/chat_socket.dart';
import 'package:DTalk/app/view/four_page.dart';
import 'package:DTalk/app/view/user_profile.dart';
import 'package:DTalk/app/widget/chat_widget.dart';
import 'package:DTalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class VideoScreenPage extends StatelessWidget {
  PageController _horizontalController = PageController(initialPage: 1);
  PageController? _verticalController;
  int _currentIndex = 0;
  BetterPlayerController? controller;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoStreamBloc, VideoState>(
      builder: (context, videostate) {
        List<VideoStream>? videos = videostate.video;
        return PageView.builder(
          onPageChanged: (hNextIndex) async {
            if(hNextIndex==1)
            context.read<VideoStreamBloc>().add(VideoPlayEvent());
            else  context.read<VideoStreamBloc>().add(VideoPauseEvent());
          },
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int hIndex) {
            if (_verticalController != null) {
              _verticalController!.dispose();
              _verticalController = null;
            }
            _verticalController = PageController(initialPage: _currentIndex);
            if (hIndex == 1) {
              return PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _verticalController,
                itemCount: videostate.video!.length,
                onPageChanged: (vNextIndex) {
                  // 이전 동영상으로 이동
                  if (vNextIndex < _currentIndex) {

                    if (videostate.nextController != null) {
                      videostate.nextController!.dispose(forceDispose: true);
                    }
                    context.read<VideoStreamBloc>().add(UpdatePrevVideoControllers(currentIndex: _currentIndex));

                    String removeId="";
                    String newId="";
                   if(videos!=null){
                      if (_currentIndex == 1) {
                        removeId = videos[_currentIndex + 1].id;
                      } else if(_currentIndex+1 ==  videostate.video!.length){
                        newId = videos[_currentIndex - 2].id;
                      }else{
                        removeId = videos[_currentIndex + 1].id;
                        newId = videos[_currentIndex - 2].id;
                      }
                    }

                    context.read<ChatBloc>().add(ChangeRoomEvent(newRoomId: newId, removeRoomId: removeId));

                  }
                  // 다음 동영상으로 이동
                  else {
                    if (videostate.prevController != null) {
                      videostate.prevController!.dispose(forceDispose: true);
                    }
                    context.read<VideoStreamBloc>().add(UpdateNextVideoControllers(currentIndex: _currentIndex));

                    String removeId="";
                    String newId="";
                    if(videos!=null){
                      if (_currentIndex == 0) {
                        newId = videos[_currentIndex + 2].id;
                      } else if(_currentIndex== videostate.video!.length-2){
                        removeId = videos[_currentIndex - 1].id;
                      } else{
                        removeId = videos[_currentIndex - 1].id;
                        newId = videos[_currentIndex + 2].id;
                      }
                    }

                    context.read<ChatBloc>().add(ChangeRoomEvent(newRoomId: newId, removeRoomId: removeId));
                  }

                  // 새로운 인덱스로 업데이트하고 다음 동영상 재생
                  _currentIndex = vNextIndex;


                },
                itemBuilder: (BuildContext context, int vindex) {
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
                      return Future(() => true);
                    },
                    child: Stack(
                            children: [
                              videostate.currentController != null
                                  ? BetterPlayer(controller: controller!)
                                  : Center(child: CircularProgressIndicator()),
                              Positioned(
                                bottom: 25,
                                left: 25,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(videos![vindex].id),
                                    Text(videos[vindex].title),
                                    Text(videos[vindex].uploader),
                                  ],
                                ),
                              ),
                              ChatStateWidget(video: videos[vindex]),

                            ],
                          )
                  );
                },
              );
            } else {
              if (hIndex == 2) {
                context.read<UserProfileBloc>().add(GetUserProfileVideosEvent(
                    userId: UserID.uid??"",
                    creator: videos![_currentIndex].userInfo.id));
                return UserProfile(videos[_currentIndex]);
              } else
                return FollowingPage(
                  creators: [
                    Creator(
                      name: 'Creator 1',
                      imageUrl: 'https://storage.googleapis.com/oauthtest-8d82e.appspot.com/thumbnails/1d331e32-e3c6-4b34-88be-593221b8aa6d-thumbnail.webp',
                      videoUrl: 'https://storage.googleapis.com/oauthtest-8d82e.appspot.com/thumbnails/3b5c4116-941e-4a31-8398-b358f34effab-thumbnail.webp',
                      followers: 1000,
                      following: 22,
                    ),
                    Creator(
                      name: 'Creator 2',
                      imageUrl: 'https://storage.googleapis.com/oauthtest-8d82e.appspot.com/thumbnails/473c10d3-a5ee-4f10-b268-b3740b45332b-thumbnail.webp',
                      videoUrl: 'https://storage.googleapis.com/oauthtest-8d82e.appspot.com/thumbnails/5e14a13f-91f7-4563-9749-29edafeb3ad1-thumbnail.webp',
                      followers: 200,
                      following: 13,
                    ),
                    Creator(
                      name: 'Creator 3',
                      imageUrl: 'https://storage.googleapis.com/oauthtest-8d82e.appspot.com/thumbnails/7c9169c4-7ae7-427b-ae84-9976e0f20dcf-thumbnail.webp',
                      videoUrl: 'https://storage.googleapis.com/oauthtest-8d82e.appspot.com/thumbnails/82c6819c-8906-4a43-b244-a47fbcc98282-thumbnail.webp',
                      followers: 400,
                      following: 66,
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
