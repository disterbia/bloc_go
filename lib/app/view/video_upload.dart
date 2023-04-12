
import 'package:better_player/better_player.dart';
import 'package:eatall/app/bloc/video_upload_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class VideoUploadScreen extends StatelessWidget {
  String id;
  VideoUploadScreen(this.id);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoUploadBloc,UploadState>(
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
                    if (state.videos != null && state.videoPlayerController != null) // Update this line
                      BetterPlayer(controller:
                          state.videoPlayerController!),
                    SizedBox(height: 50,),
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: TextField(
                    //     controller: state.titleController,
                    //     decoration: InputDecoration(
                    //       labelText: '동영상 제목',
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: state is! UploadingState ?()=>context.read<VideoUploadBloc>().add(PickVideoEvent()):null,
                            icon: Icon(Icons.video_library),
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
                            ):Text('갤러리에서 선택'),
                          ),
                          ElevatedButton.icon(
                            onPressed: state is! UploadingState
                                ? () => context.read<VideoUploadBloc>().add(UploadVideoEvent(state.titleController!.text))
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
      );
  }
}