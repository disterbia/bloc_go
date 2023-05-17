import 'package:Dtalk/app/const/addr.dart';
import 'package:Dtalk/app/widget/recording_timer.dart';
import 'package:camera/camera.dart';
import 'package:Dtalk/app/bloc/take_video_bloc.dart';
import 'package:Dtalk/app/router/custom_go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TakeVideoScreen extends StatefulWidget {
  @override
  _TakeVideoScreenState createState() => _TakeVideoScreenState();
}

class _TakeVideoScreenState extends State<TakeVideoScreen> {
  bool enabled = true;
  bool enabled2 = true;
  bool isfront=true;
  final maximumDuration = Duration(seconds: 30);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<TakeVideoBloc, TakeVideoState>(
          listener: (context, state) {
            if (state is VideoReviewState) {
              setState(() {
                enabled=true;
                enabled2 = true;
              });

              context.push(MyRoutes.VIDEOREVIEW);
            }
          }, builder: (context, state) {
        return WillPopScope(
          onWillPop: () async{
            context.read<TakeVideoBloc>().add(DisposeCameraEvent());
            return true;
          },
          child: Scaffold(
            body:
            state.controller != null && state.controller!.value.isInitialized
                ? Stack(
              children: [
                Container(height: double.infinity,child: CameraPreview(state.controller!)),
                state.controller!.value.isRecordingVideo?
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: RecordingTimer(maximumDuration: Duration(seconds: 30)),
                ):Container(),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Align(alignment: Alignment.bottomRight,child: InkWell(onTap: (){
                    if(!state.controller!.value.isRecordingVideo){
                      context.read<TakeVideoBloc>().add(DisposeCameraEvent());
                      context.read<TakeVideoBloc>().add(InitialEvent(isfront?0:1));
                      isfront=!isfront;
                    }
                  },child:state.controller!.value.isRecordingVideo?Container(): Icon(Icons.flip_camera_android,color: Colors.white,size: 30.sp,))),
                )
              ],
            )
                : Center(child: CircularProgressIndicator()),
            floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
            floatingActionButton: state.isRecording!
                ? AbsorbPointer(
              absorbing: !enabled,
                  child: FloatingActionButton(
              onPressed: () {
                context.read<TakeVideoBloc>().add(StopVideoRecording());
                setState(() {
                  enabled = false;
                });
              },
                    child:Ink(
                        decoration: ShapeDecoration(
                          shape: CircleBorder(
                            side: BorderSide(color: Colors.red, width: 5), // 테두리 색상 설정
                          ),
                        ),
                        child: Container() // 원하는 아이콘 설정
                    ),
                    backgroundColor: Colors.grey.withOpacity(0.3), // 반투명한 배경색 설정
                    elevation: 0, // 기본 그림자 효과 제거
                    clipBehavior: Clip.antiAlias,
            ),
                )
                : AbsorbPointer(
              absorbing: !enabled2,
                  child: FloatingActionButton(

              onPressed: () {
                  context
                      .read<TakeVideoBloc>()
                      .add(StartVideoRecording());
                  setState(() {
                    enabled2 = false;
                  });
                  Future.delayed(maximumDuration, () async {
                    if (state.controller!.value.isRecordingVideo) {
                      context.read<TakeVideoBloc>().add(StopVideoRecording());
                    }
                  });
              },
              child:Ink(
                decoration: ShapeDecoration(
                  shape: CircleBorder(
                    side: BorderSide(color:Address.color
                        , width: 5), // 테두리 색상 설정
                  ),
                ),
                child: Container() // 원하는 아이콘 설정
              ),
                    backgroundColor: Colors.grey.withOpacity(0.3), // 반투명한 배경색 설정
                    elevation: 0, // 기본 그림자 효과 제거
                    clipBehavior: Clip.antiAlias, // 경계를 넘어가지 않게 함
            ),
                ),
          ),
        );
      }),
    );
  }
}