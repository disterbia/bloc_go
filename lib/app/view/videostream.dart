import 'package:Dtalk/app/bloc/follow_bloc.dart';
import 'package:Dtalk/app/view/login_page.dart';
import 'package:Dtalk/app/widget/android_report_widget.dart';
import 'package:Dtalk/app/widget/report_widget.dart';
import 'package:better_player/better_player.dart';
import 'package:Dtalk/app/bloc/chat_bloc.dart';
import 'package:Dtalk/app/bloc/user_profile_bloc.dart';
import 'package:Dtalk/app/bloc/video_stream_bloc.dart';
import 'package:Dtalk/app/model/video_stream.dart';
import 'package:Dtalk/app/view/chat_socket.dart';
import 'package:Dtalk/app/view/four_page.dart';
import 'package:Dtalk/app/view/user_profile.dart';
import 'package:Dtalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoScreenPage extends StatelessWidget {
  PageController _horizontalController = PageController(initialPage: 1);
  PageController? _verticalController;
  //int videostate.currentIndex! = 0;
  BetterPlayerController? controller;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoStreamBloc, VideoState>(
      builder: (context, videostate) {

        print("-=--=-=-=-=${videostate.currentIndex!}");
        List<VideoStream>? videos = videostate.video;
        return  videostate.currentController==null?Center(child: Center(child: CircularProgressIndicator(),),):PageView.builder(
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
            _verticalController = PageController(initialPage: videostate.currentIndex!);
            if (hIndex == 1) {
              return PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _verticalController,
                itemCount: videostate.video!.length,
                onPageChanged: (vNextIndex) {
                  // 이전 동영상으로 이동
                  if (vNextIndex < videostate.currentIndex!) {

                    if (videostate.nextController != null) {
                      videostate.nextController!.dispose(forceDispose: true);
                    }
                    context.read<VideoStreamBloc>().add(UpdatePrevVideoControllers(currentIndex: videostate.currentIndex!));

                    String removeId="";
                    String newId="";
                    if(videos!=null){
                      if (videostate.currentIndex! == 1) {
                        removeId = videos[videostate.currentIndex! + 1].id;
                      } else if(videostate.currentIndex!+1 ==  videostate.video!.length){
                        newId = videos[videostate.currentIndex! - 2].id;
                      }else{
                        removeId = videos[videostate.currentIndex! + 1].id;
                        newId = videos[videostate.currentIndex! - 2].id;
                      }
                    }

                    context.read<ChatBloc>().add(ChangeRoomEvent(newRoomId: newId, removeRoomId: removeId));

                  }
                  // 다음 동영상으로 이동
                  else {
                    if (videostate.prevController != null) {
                      videostate.prevController!.dispose(forceDispose: true);
                    }
                    context.read<VideoStreamBloc>().add(UpdateNextVideoControllers(currentIndex: videostate.currentIndex!));

                    String removeId="";
                    String newId="";
                    if(videos!=null){
                      if (videostate.currentIndex! == 0) {
                        newId = videos[videostate.currentIndex! + 2].id;
                      } else if(videostate.currentIndex== videostate.video!.length-2){
                        removeId = videos[videostate.currentIndex! - 1].id;
                      } else{
                        removeId = videos[videostate.currentIndex! - 1].id;
                        newId = videos[videostate.currentIndex! + 2].id;
                      }
                    }

                    context.read<ChatBloc>().add(ChangeRoomEvent(newRoomId: newId, removeRoomId: removeId));
                  }

                  // 새로운 인덱스로 업데이트하고 다음 동영상 재생
                  context.read<VideoStreamBloc>().add(IndexUpdateEvent(currentIndex: vNextIndex));
                  // videostate.currentIndex! = vNextIndex;


                },
                itemBuilder: (BuildContext context, int vindex) {
                  if (vindex == videostate.currentIndex!) {
                    controller = videostate.currentController;

                  } else if (vindex == videostate.currentIndex! - 1) {
                    controller = videostate.prevController;

                  } else if (vindex == videostate.currentIndex! + 1) {
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
                                Row(
                                  children: [
                                    videos![vindex].userInfo.image==""?CircleAvatar(backgroundImage: AssetImage("assets/img/profile3_s.png"),):
                                    CircleAvatar(backgroundImage: NetworkImage(videos![vindex].userInfo.image,),),
                                    SizedBox(width: 10,),
                                    Text(videos![vindex].userInfo.nickname,style: TextStyle(color: Colors.white,fontSize: 16.sp),),

                                  ],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                                SizedBox(height: 10,),
                                Container(width: 250,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 5,),
                                      Expanded(child: Text(videos[vindex].title,overflow: TextOverflow.ellipsis,maxLines: 2,style: TextStyle(color: Colors.white,fontSize: 18.sp,fontWeight: FontWeight.w100))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ChatStateWidget(video: videos[vindex]),
                          UserID.uid==videos[vindex].uploader?Container():Positioned(
                            top: 0,
                            right: 0,
                            child: Padding(
                                padding:  EdgeInsets.all(20.0),
                                child: ReportWidget(false,blockId: videos[vindex].id,currentIndex: videostate.currentIndex!,)
                            ),
                          ),
                        ],
                      )
                  );
                },
              );
            } else {
              if (hIndex == 2) {
                context.read<UserProfileBloc>().add(GetUserProfileVideosEvent(
                    userId: UserID.uid??"",
                    creator: videos![videostate.currentIndex!].userInfo.id));
                return UserProfile(videos[videostate.currentIndex!],false);
              } else {
                if(UserID.uid!=null){
                  context.read<FollowBloc>().add(FollowEvent(UserID.uid!));
                  return FollowingPage(_horizontalController);
                }
                return LoginPage(true,controller: _horizontalController,);
              }
            }
          },
          itemCount: 3, // 왼쪽, 중앙, 오른쪽 페이지를 위한 항목 수입니다.
        );
      },
    );
  }
}