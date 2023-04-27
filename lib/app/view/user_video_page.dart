import 'package:better_player/better_player.dart';
import 'package:eatall/app/bloc/chat_bloc.dart';
import 'package:eatall/app/bloc/user_video_bloc.dart';
import 'package:eatall/app/model/user_video.dart';
import 'package:eatall/app/view/chat_socket.dart';
import 'package:eatall/app/view/user_video_chat_socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserVideoPage extends StatelessWidget {
  int index;
  bool isFirst = true;
  int _currentIndex = 0;
  BetterPlayerController? controller;
  PageController? _verticalController;
  UserVideoPage(this.index);

  @override
  Widget build(BuildContext context) {
    if(_verticalController!=null) {
      _verticalController!.dispose();
      _verticalController=null;
    }
    _currentIndex=index;
    _verticalController = PageController(initialPage: index);
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<UserVideoBloc, UserVideoState>(
          builder: (context, videostate) {
            List<UserVideo>? videos = videostate.video;

            return videostate is! VideoLoaded || _verticalController==null?Center(child: CircularProgressIndicator()):WillPopScope(
              onWillPop: () async {
                print("-=--=-=-=");
                videostate.currentController?.dispose(forceDispose: true);
                videostate.prevController?.dispose(forceDispose: true);
                videostate.nextController?.dispose(forceDispose: true);
                controller!.dispose(forceDispose: true);
                _verticalController!.dispose();
                return true;
              },
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _verticalController,
                itemCount: videostate.video!.length,
                onPageChanged: (vNextIndex) async {
                  // 이전 동영상으로 이동
                  if (vNextIndex < _currentIndex) {
                    if (videostate.nextController != null) {
                      videostate.nextController!.dispose(forceDispose: true);
                    }
                    context.read<UserVideoBloc>().add(UpdatePrevVideoControllers(currentIndex: _currentIndex));
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
                    context.read<UserVideoBloc>().add(UpdateNextVideoControllers(currentIndex: _currentIndex));
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
                  return BlocBuilder<ChatBloc,ChatState>(
                    builder: (context,chatstate) {
                      return Stack(
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
                                Text(videos![vindex].title),
                                Text(videos[vindex].uploader),
                              ],
                            ),
                          ),
                          UserVideoChatSocket(video: videos[vindex])
                        ],
                      );
                    }
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

