import 'dart:convert';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:eatall/app/repository/video_upload_repository.dart';
import 'package:eatall/app/view/splash_page.dart';
import 'package:eatall/main.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as thumb;

class TakeVideoBloc extends Bloc<TakeVideoEvent, TakeVideoState> {
  VideoUploadRepository repository;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  String? _videoThumbnailPath;
  TextEditingController _titleController = TextEditingController();
  BetterPlayerController? _betterPlayerController;

  TakeVideoBloc(this.repository) : super(InitialState(isRecording: false)) {
    on<InitialEvent>((event, emit) async => await _initializeCameras());
    on<StartVideoRecording>(
        (event, emit) async => await _startVideoRecording());
    on<StopVideoRecording>((event, emit) async => await _stopVideoRecording());
    on<UploadVideoEvent>((event, emit) async => await _uploadVideo());
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    state.betterPlayerController?.dispose();
    return super.close();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      emit(InitialState(
          isRecording: false, controller: _controller, cameras: _cameras));
    }
  }

  Future<void> _startVideoRecording() async {
    if (!state.controller!.value.isInitialized) {
      return;
    }
    try {
      await state.controller!.startVideoRecording();
      emit(VideoState(
          isRecording: true,
          controller: state.controller,
          cameras: state.cameras));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopVideoRecording() async {
    String _videoPath = "";
    if (!_controller!.value.isRecordingVideo) {
      return;
    }
    try {
      XFile file = await _controller!.stopVideoRecording();
      _videoPath = file.path;
    } catch (e) {
      print(e);
    } finally {
      emit(VideoState(
          videoPath: _videoPath,
          cameras: state.cameras,
          controller: state.controller,
          isRecording: false));
      _createVideoThumbnail();
    }
  }

  Future<void> _createVideoThumbnail() async {
    _videoThumbnailPath = await thumb.VideoThumbnail.thumbnailFile(
      video: state.videoPath!,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: thumb.ImageFormat.JPEG,
      maxHeight: 256,
      maxWidth: 256,
      quality: 100,
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false,
        looping: false,
        aspectRatio: VideoAspectRatio.aspectRatio! * 1.2,
        autoDispose: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: true,
          showControlsOnInitialize: true,
          controlBarColor: Colors.transparent,
          controlsHideTime: Duration.zero,
          enablePlayPause: false,
          enableFullscreen: false,
          enableMute: false,
          enableProgressText: false,
          enableSkips: false,
          enableAudioTracks: false,
          enableOverflowMenu: false,
          enablePlaybackSpeed: false,
          enableSubtitles: false,
          enableQualities: false,
          enablePip: false,
          enableRetry: false,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource.file(state.videoPath!),
    );

    emit(VideoReviewState(
        titleController: _titleController,
        videoThumbnailPath: _videoThumbnailPath,
        betterPlayerController: _betterPlayerController,
        isRecording: false,
        videoPath: state.videoPath));
  }

  Future<void> _uploadVideo() async {
    try {
      // Metadata
      List<Map<String, dynamic>> metadata = [
        {
          'title': state.titleController!.text,
          'uploader': UserID.uid, // 사용자 정보를 입력해주세요.
        }
      ];

      // FormData
      FormData formData = FormData.fromMap({
        'metadata': jsonEncode(metadata),
        'files': await MultipartFile.fromFile(
          state.videoPath!,
          filename: 'myVideo.mp4',
        ),
      });
      // Send request
      Response response = await repository.upload(formData);

      // Handle response
      if (response.statusCode == 200) {
        List<dynamic> responseData = response.data;
        print(
            'Video uploaded successfully. Download URL: ${responseData[0]['url']}');
      } else {
        print('Error uploading video. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

abstract class TakeVideoEvent extends Equatable {}

class InitialEvent extends TakeVideoEvent {
  @override
  List<Object?> get props => [];
}

class StartVideoRecording extends TakeVideoEvent {
  @override
  List<Object?> get props => [];
}

class StopVideoRecording extends TakeVideoEvent {
  @override
  List<Object?> get props => [];
}

class UploadVideoEvent extends TakeVideoEvent {
  @override
  List<Object?> get props => [];
}

abstract class TakeVideoState extends Equatable {
  final CameraController? controller;
  final List<CameraDescription>? cameras;
  final String? videoPath;
  final bool? isRecording;

  final String? videoThumbnailPath;
  final TextEditingController? titleController;
  final BetterPlayerController? betterPlayerController;

  TakeVideoState(
      {this.cameras,
      this.controller,
      this.isRecording,
      this.videoPath,
      this.titleController,
      this.betterPlayerController,
      this.videoThumbnailPath});
}

class InitialState extends TakeVideoState {
  InitialState(
      {super.controller, super.videoPath, super.isRecording, super.cameras});

  @override
  List<Object?> get props => [controller, videoPath, isRecording, cameras];
}

class VideoState extends TakeVideoState {
  VideoState(
      {super.controller, super.videoPath, super.isRecording, super.cameras});

  @override
  List<Object?> get props => [controller, videoPath, isRecording, cameras];
}

class VideoReviewState extends TakeVideoState {
  VideoReviewState(
      {super.titleController,
      super.betterPlayerController,
      super.videoThumbnailPath,
      super.isRecording,
      super.videoPath});

  @override
  List<Object?> get props => [
        titleController,
        betterPlayerController,
        videoThumbnailPath,
        isRecording,
        videoPath
      ];
}
