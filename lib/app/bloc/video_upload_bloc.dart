import 'dart:convert';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:eatall/app/model/video_object.dart';
import 'package:eatall/app/repository/video_upload_repository.dart';
import 'package:eatall/app/view/home_page.dart';
import 'package:eatall/main.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class VideoUploadBloc extends Bloc<UploadEvent, UploadState> {

  final VideoUploadRepository videoUploadRepository ;
  final _picker = ImagePicker();
  BetterPlayerController? controller;

  VideoUploadBloc(this.videoUploadRepository) : super(VideoState(titleController: TextEditingController())) {
    on<PickVideoEvent>((event, emit) async{
     await _pickVideos(event,emit);
    });
    on<UploadVideoEvent>((event, emit) async{
      await _uploadVideos(event,emit);
    });

    on<DisposePlayerControllerEvent>((event, emit) {
      if (state.videoPlayerController != null) {
        state.videoPlayerController!.dispose();
        emit(VideoState(titleController: state.titleController,videoPlayerController: null,videos: null));
      }
    });

    on<ResetSnackBarEvent>((event, emit) {
      if (state is SnackBarState) {
        emit(VideoState(videoPlayerController: state.videoPlayerController,titleController: state.titleController));
      }
    });
  }


  Future<void> _pickVideos(PickVideoEvent event,emit) async {
    final pickedFiles = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFiles != null) {
      if(controller!=null) controller!.dispose();
      if(state.videoPlayerController!=null) state.videoPlayerController!.dispose();
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,pickedFiles.path);
      BetterPlayerConfiguration betterPlayerConfiguration =
       BetterPlayerConfiguration(
          aspectRatio: VideoAspectRatio.aspectRatio!*1.5,
          autoPlay: false,
          looping: false,
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
          ));
       controller = BetterPlayerController(betterPlayerConfiguration,betterPlayerDataSource: betterPlayerDataSource,);

      emit(VideoState(videos: [pickedFiles],videoPlayerController: controller,titleController: state.titleController));
  }

  }

  // 이 메서드는 사용자가 입력한 동영상 제목과 함께 VideoObject 리스트를 생성합니다.
  List<VideoObject> _createVideoObjects(UploadState state,List<String> titles) {
    List<VideoObject> videoObjects = [];
    for (int i = 0; i < state.videos!.length; i++) {
      videoObjects.add(
        VideoObject(
          title: titles[i],
          uploader: UserID.uid!,
          path: state.videos![i].path,
        ),
      );
    }
    return videoObjects;
  }

  Future<void> _uploadVideos(UploadVideoEvent event,emit) async {
    if (state.videos == null || state.videos!.isEmpty) {
      emit(SnackBarState(message: "동영상을 선택하세요.",titleController: state.titleController));
      return;
    }

    if(state.titleController!.text.trim().isEmpty) {
      emit(SnackBarState(message: "제목을 입력하세요.",titleController: state.titleController));
      return;
    }
    emit(UploadingState(videos: state.videos, videoPlayerController: state.videoPlayerController,titleController: state.titleController));


    List<String> titles = [
      event.text
    ];

    try {
      List<MultipartFile> files = [];
      List<VideoObject> videoObjects = _createVideoObjects(state,titles);


      for (VideoObject videoObject in videoObjects) {
        final videoFile = File(videoObject.path);
        int fileSize = await videoFile.length();
        print('File size: $fileSize bytes');
        final file = await MultipartFile.fromFile(
            videoFile.path, filename: videoFile.path
            .split('/')
            .last);
        files.add(file);
      }

      final metaDataList = jsonEncode(
          videoObjects.map((videoObject) => videoObject.toJson()).toList());
      final formData = FormData.fromMap({
        'metadata': metaDataList,
        'files': files,
      });
      final response = await videoUploadRepository.upload(formData);

      if (response.statusCode == 200) {
        emit(SnackBarState(message: "동영상 업로드에 성공했습니다.",titleController: state.titleController));
      } else {
        emit(SnackBarState(message: "동영상 업로드에 실패했습니다.",titleController: state.titleController));
      }

      emit(VideoState(titleController: state.titleController));
    } catch (e) {
      print(e);
      emit(SnackBarState(message: "동영상 업로드 중 오류가 발생했습니다.",titleController: state.titleController));
    }
  }
  @override
  Future<void> close() {
    state.videoPlayerController?.dispose();
    state.titleController?.dispose();
    controller?.dispose();
    return super.close();
  }
}

abstract class UploadEvent extends Equatable{}

class PickVideoEvent extends UploadEvent{
  @override
  List<Object?> get props => [];
}

class UploadVideoEvent extends UploadEvent{
  UploadVideoEvent(this.text);
  final String text;

  @override
  List<Object?> get props => [text];

}

class DisposePlayerControllerEvent extends UploadEvent {
  @override
  List<Object?> get props => [];
}

class ResetSnackBarEvent extends UploadEvent {
  @override
  List<Object?> get props => [];
}

abstract class UploadState extends Equatable{
  final List<XFile>? videos;
  final BetterPlayerController? videoPlayerController; // Add this line
  final TextEditingController? titleController;

  UploadState({this.videos, this.videoPlayerController,this.titleController});
}

class UploadingState extends UploadState {
  UploadingState({super.videos, super.videoPlayerController,super.titleController});


  @override
  List<Object?> get props => [videos, videoPlayerController,titleController];
}

class VideoState extends UploadState{
  VideoState({super.videos,super.videoPlayerController,super.titleController});

  @override
  List<Object?> get props => [videos,videoPlayerController,titleController];
}

class SnackBarState extends UploadState {
  final String message;

  SnackBarState({required this.message, super.videos, super.videoPlayerController,super.titleController});

  @override
  List<Object?> get props => [message, videos, videoPlayerController,titleController];
}