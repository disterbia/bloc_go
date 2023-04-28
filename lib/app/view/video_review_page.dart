import 'dart:io';
import 'package:better_player/better_player.dart';
import 'package:DTalk/app/bloc/take_video_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VideoReviewScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<TakeVideoBloc,TakeVideoState>(
        listenWhen: (previous, current) => current is VideoUpladCompleteState,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!),duration:Duration(seconds: 2) ),
          );
          context.pop();
        },
        builder: (context,state) {
          return Scaffold(resizeToAvoidBottomInset: false,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (state.videoThumbnailPath != null)
                        Image.file(
                          File(state.videoThumbnailPath!),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: state.titleController,
                          decoration: InputDecoration(
                            labelText: 'Video Title',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.betterPlayerController != null)
                  BetterPlayer(controller: state.betterPlayerController!),
                ElevatedButton.icon(
                  onPressed: state is VideoLoadingState?null:()  {
                    if(state.titleController!.text.trim().isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("제목을 입력해주세요."),duration:Duration(seconds: 2) ),
                      );
                      return ;
                    }else{
                      context.read<TakeVideoBloc>().add(UploadVideoEvent());
                    }

                  },
                  icon: Icon(Icons.cloud_upload),
                  label: (state is VideoLoadingState)
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
          );
        }
      ),
    );
  }
}