import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eatall/app/bloc/video_upload_bloc.dart';
import 'package:eatall/app/model/video_object.dart';
import 'package:eatall/app/repository/video_upload_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';


class VideoUploadScreen extends StatelessWidget {
  String id;

  VideoUploadScreen(this.id);

  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Add this method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('동영상 업로드'),
      ),
      body: BlocProvider(create: (context) =>
          VideoUploadBloc(VideoUploadRepository()),
        child: BlocConsumer<VideoUploadBloc,UploadState>(
            listener: (context, state) {
              if (state is SnackBarState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message),duration:Duration(seconds: 2) ),
                );
              }
              Future.delayed(Duration(seconds: 2), () {
                context.read<VideoUploadBloc>().add(ResetSnackBarEvent());
              });
            },
            builder: (context, state) =>
                SingleChildScrollView(
                  child: Column(
                    children: [
                      if (state.videos != null && state.videoPlayerController != null &&
                          state.videoPlayerController!.value
                              .isInitialized) // Update this line
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 300,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: state.videoPlayerController!.value.size.width,
                              height: state.videoPlayerController!.value.size
                                  .height,
                              child: VideoPlayer(
                                  state.videoPlayerController!), // Update this line
                            ),
                          ),
                        ),
                      SizedBox(height: 50,),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: '동영상 제목',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: ()=>context.read<VideoUploadBloc>().add(PickVideoEvent()),
                              icon: Icon(Icons.video_library),
                              label: Text('갤러리에서 선택'),
                            ),
                            ElevatedButton.icon(
                              onPressed: state is! UploadingState
                                  ? () => context.read<VideoUploadBloc>().add(UploadVideoEvent(_titleController.text))
                                  : null,
                              icon: Icon(Icons.cloud_upload),
                              label: (state is UploadingState)
                                  ? Row(
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
                                  : Text('동영상 업로드'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
        ),
      ),
    );
  }
}