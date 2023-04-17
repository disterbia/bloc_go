import 'package:camera/camera.dart';
import 'package:eatall/app/bloc/take_video_bloc.dart';
import 'package:eatall/app/router/custom_go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TakeVideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<TakeVideoBloc, TakeVideoState>(
          listener: (context, state) {
        if (state is VideoReviewState) {
          context.push(MyRoutes.VIDEOREVIEW);
        }
      }, builder: (context, state) {
        return Scaffold(
          body:
              state.controller != null && state.controller!.value.isInitialized
                  ? Stack(
                      children: [
                        CameraPreview(state.controller!),
                      ],
                    )
                  : Center(child: CircularProgressIndicator()),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: state.isRecording!
              ? FloatingActionButton(
                  onPressed: () {
                    context.read<TakeVideoBloc>().add(StopVideoRecording());
                  },
                  child: Icon(Icons.stop),
                  backgroundColor: Colors.red,
                )
              : FloatingActionButton(
                  onPressed: () {
                    context.read<TakeVideoBloc>().add(StartVideoRecording());
                  },
                  child: Icon(Icons.circle_outlined, color: Colors.black),
                  backgroundColor: Colors.white,
                ),
        );
      }),
    );
  }
}
