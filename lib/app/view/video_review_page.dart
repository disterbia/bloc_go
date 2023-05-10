import 'dart:io';
import 'package:DTalk/app/const/addr.dart';
import 'package:better_player/better_player.dart';
import 'package:DTalk/app/bloc/take_video_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class VideoReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<TakeVideoBloc, TakeVideoState>(
          listenWhen: (previous, current) => current is VideoUpladCompleteState,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message!),
                  duration: Duration(seconds: 2)),
            );
            context.pop();
          },
          builder: (context, state) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text(
                  "새로운 영상",
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    if (state.betterPlayerController != null)
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: BetterPlayer(
                                controller: state.betterPlayerController!)),
                      ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "문구입력",
                          style: TextStyle(color: Colors.grey.shade200),
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
                              controller: state.titleController,
                              decoration: InputDecoration(
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
                          onPressed: state is VideoLoadingState
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
                                    context
                                        .read<TakeVideoBloc>()
                                        .add(UploadVideoEvent());
                                  }
                                },
                          child: (state is VideoLoadingState)
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
            );
          }),
    );
  }
}
