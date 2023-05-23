import 'package:Dtalk/app/widget/android_report_widget.dart';
import 'package:Dtalk/app/widget/report_widget.dart';
import 'package:better_player/better_player.dart';
import 'package:Dtalk/app/bloc/chat_bloc.dart';
import 'package:Dtalk/app/bloc/user_video_bloc.dart';
import 'package:Dtalk/app/model/user_video.dart';
import 'package:Dtalk/app/view/user_video_chat_socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UserVideoPage extends StatefulWidget {
  int index;
  String image;
  String nickname;
  UserVideoPage(this.index,this.image,this.nickname);


  @override
  State<UserVideoPage> createState() => _UserVideoPageState();
}

class _UserVideoPageState extends State<UserVideoPage> {
  bool isFirst = true;
  int _currentIndex = 0;
  BetterPlayerController? controller;
  PageController? _verticalController;
@override
  void initState() {
  print("-=--=-=-=${widget.index}");
  if(_verticalController!=null) {
    _verticalController!.dispose();
    _verticalController=null;
  }
  _currentIndex=widget.index;
  _verticalController = PageController(initialPage: widget.index);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<UserVideoBloc, UserVideoState>(
          builder: (context, videostate) {
            List<UserVideo>? videos = videostate.video;

            return videostate is! UserVideoLoaded || _verticalController==null?Center(child: CircularProgressIndicator()):WillPopScope(
              onWillPop: () async {
                videostate.currentController?.dispose(forceDispose: true);
                videostate.prevController?.dispose(forceDispose: true);
                videostate.nextController?.dispose(forceDispose: true);
                controller!.dispose(forceDispose: true);
                _verticalController!.dispose();
                return true;
              },
              child: Center(
                child: Stack(
                  children: [
                    PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _verticalController,
                      itemCount: videostate.video!.length,
                      onPageChanged: (vNextIndex) async {
                        // 이전 동영상으로 이동
                        if (vNextIndex < _currentIndex) {
                          if (videostate.nextController != null) {
                            videostate.nextController!.dispose(forceDispose: true);
                          }
                          context.read<UserVideoBloc>().add(UserUpdatePrevVideoControllers(currentIndex: _currentIndex));
                          String removeId="";
                          String newId="";
                          if(videos!=null){
                            if(videos.length>2){
                              if (_currentIndex == 1) {
                                removeId = videos[_currentIndex + 1].id;
                              } else if(_currentIndex+1 ==  videostate.video!.length){
                                newId = videos[_currentIndex - 2].id;
                              }else{
                                removeId = videos[_currentIndex + 1].id;
                                newId = videos[_currentIndex - 2].id;
                              }
                              context.read<ChatBloc>().add(ChangeRoomEvent(newRoomId: newId, removeRoomId: removeId));
                            }

                          }


                        }
                        // 다음 동영상으로 이동
                        else {
                          if (videostate.prevController != null) {
                            videostate.prevController!.dispose(forceDispose: true);
                          }
                         context.read<UserVideoBloc>().add(UserUpdateNextVideoControllers(currentIndex: _currentIndex));
                          String removeId="";
                          String newId="";
                          if(videos!=null){
                            if(videos.length>2){
                              if (_currentIndex == 0) {
                                newId = videos[_currentIndex + 2].id;
                              } else if(_currentIndex== videostate.video!.length-2){
                                removeId = videos[_currentIndex - 1].id;
                              } else{
                                removeId = videos[_currentIndex - 1].id;
                                newId = videos[_currentIndex + 2].id;
                              }
                              context.read<ChatBloc>().add(ChangeRoomEvent(newRoomId: newId, removeRoomId: removeId));
                            }

                          }


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
                            return Stack(
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
                                      Row(
                                        children: [
                                          widget.image==""?CircleAvatar(backgroundImage: AssetImage("assets/img/profile3_s.png"),):
                                          CircleAvatar(backgroundImage: NetworkImage(widget.image,),),
                                          SizedBox(width: 10,),
                                          Text(widget.nickname,style: TextStyle(color: Colors.white,fontSize: 16.sp),),
                                        ],
                                        mainAxisAlignment: MainAxisAlignment.center,
                                      ),
                                      SizedBox(height: 10,),
                                      Container(width: 250,
                                        child: Row(
                                          children: [
                                            SizedBox(width: 5,),
                                            Expanded(child: Text(videos![vindex].title,overflow: TextOverflow.ellipsis,maxLines: 2,style: TextStyle(color: Colors.white,fontSize: 18.sp,fontWeight: FontWeight.w100))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                UserVideoChatSocket(video: videos[vindex],videoState:videostate),
                              ],
                            );


                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(alignment: Alignment.topCenter,child: Container(child: InkWell(onTap:()=> context.pop(),child: Image.asset("assets/img/sh_x.png")),height: 30)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

