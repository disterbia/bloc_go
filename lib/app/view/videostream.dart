import 'package:DTalk/app/bloc/follow_bloc.dart';
import 'package:DTalk/app/view/login_page.dart';
import 'package:better_player/better_player.dart';
import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/bloc/user_profile_bloc.dart';
import 'package:DTalk/app/bloc/video_stream_bloc.dart';
import 'package:DTalk/app/model/video_stream.dart';
import 'package:DTalk/app/view/chat_socket.dart';
import 'package:DTalk/app/view/four_page.dart';
import 'package:DTalk/app/view/user_profile.dart';
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
                              controller != null
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
              } else {
                if(UserID.uid!=null){
                  context.read<FollowBloc>().add(FollowEvent(UserID.uid!));
                  return FollowingPage(_horizontalController);
                }
                return LoginPage();
              }
            }
          },
          itemCount: 3, // 왼쪽, 중앙, 오른쪽 페이지를 위한 항목 수입니다.
        );
      },
    );
  }
}
