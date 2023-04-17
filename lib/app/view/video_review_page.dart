import 'dart:io';
import 'package:better_player/better_player.dart';
import 'package:eatall/app/bloc/take_video_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoReviewScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<TakeVideoBloc,TakeVideoState>(
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
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: ()  {
                context.read<TakeVideoBloc>().add(UploadVideoEvent());
              },
              child: Icon(Icons.file_upload),
            ),
          );
        }
      ),
    );
  }
}