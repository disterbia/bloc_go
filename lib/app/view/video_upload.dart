
import 'package:Dtalk/app/bloc/mypage_bloc.dart';
import 'package:Dtalk/app/const/addr.dart';
import 'package:Dtalk/main.dart';
import 'package:better_player/better_player.dart';
import 'package:Dtalk/app/bloc/video_upload_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';



class VideoUploadScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(leading: Container(child: InkWell(onTap:()=> context.pop(),child: Image.asset("assets/img/ic_back.png")),padding: EdgeInsets.all(15)),
        title: Text(
          "새로운 영상",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
      ),
      body: BlocConsumer<VideoUploadBloc,UploadState>(
            listener: (context, state) async {
              if (state is SnackBarState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message),duration:Duration(seconds: 2) ),
                );
                if(state.message=="동영상 업로드에 성공했습니다.") {
                  context.read<MyPageBloc>().add(GetMyPageEvent(userId: UserID.uid!));
                  await Future.delayed(Duration.zero);
                  return context.pop();
                }
              }
              if(state is FailedState){
                return context.pop();
              }

            },
            builder: (context, state) =>
                WillPopScope(
                  onWillPop: () async {
                    context.read<VideoUploadBloc>().add(DisposeController());
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (state.videos != null && state.videoPlayerController != null) // Update this line
                      Padding(
                      padding: const EdgeInsets.all(30.0),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                         child: BetterPlayer(controller:
                              state.videoPlayerController!))),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "문구입력",
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              // if (state.videoThumbnailPath != null)
                              //   Image.file(
                              //     File(state.videoThumbnailPath!),
                              //     width: 64,
                              //     height: 64,
                              //     fit: BoxFit.cover,
                              //   ),
                              SizedBox(width: 20),
                              Expanded(
                                child: TextField(
                                  autofocus: true,
                                  controller: state.titleController,
                                  decoration: InputDecoration(
                                    hintText: "불건전한 내용이 포함될 시 이용이 제한됩니다.",hintStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                    ),focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Address.color),
                                  ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ConstrainedBox(constraints: BoxConstraints.tightFor(width: double.infinity,height: 60.h),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Address.color),
                                  shape:
                                  MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ))),
                              onPressed: state is UploadingState
                                  ? null
                                  : () {
                                if (state.titleController!.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("제목을 입력해주세요."),
                                        duration: Duration(seconds: 2)),
                                  );
                                  return;
                                } else {
                                  context.read<VideoUploadBloc>().add(UploadVideoEvent(state.titleController!.text));
                                }
                              },
                              child: (state is UploadingState)
                                  ? Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text('업로드 중...'),
                                ],
                              )
                                  : Text('영상 공유하기'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
        ),
    );
  }
}