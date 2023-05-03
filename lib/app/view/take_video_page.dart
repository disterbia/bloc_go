import 'package:camera/camera.dart';
import 'package:DTalk/app/bloc/take_video_bloc.dart';
import 'package:DTalk/app/router/custom_go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TakeVideoScreen extends StatefulWidget {
  @override
  _TakeVideoScreenState createState() => _TakeVideoScreenState();
}

class _TakeVideoScreenState extends State<TakeVideoScreen> {
  bool enabled = true;
  bool enabled2 = true;

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
                CameraPreview(state.controller!),
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
              child: Icon(Icons.stop),
              backgroundColor: Colors.red,
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
              },
              child: Icon(Icons.circle_outlined, color: Colors.black),
              backgroundColor: Colors.white,
            ),
                ),
          ),
        );
      }),
    );
  }
}