import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:eatall/app/model/video_object.dart';
import 'package:eatall/app/repository/login_repository.dart';
import 'package:eatall/app/repository/video_upload_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class VideoUploadBloc extends Bloc<UploadEvent, UploadState> {

  final VideoUploadRepository videoUploadRepository ;
  final _picker = ImagePicker();

  VideoUploadBloc(this.videoUploadRepository) : super(VideoState()) {
    on<PickVideoEvent>((event, emit) async{
     await _pickVideos(event,emit);
    });
    on<UploadVideoEvent>((event, emit) async{
      await _uploadVideos(event,emit);
    });
    on<ResetSnackBarEvent>((event, emit) {
      if (state is SnackBarState) {
        emit(VideoState(videoPlayerController: state.videoPlayerController));
      }
    });
  }

  Future<void> _pickVideos(PickVideoEvent event,emit) async {

    final pickedFiles = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFiles != null) {
        VideoPlayerController controller = VideoPlayerController.file(File(pickedFiles.path));
        await controller.initialize();
        await controller.setLooping(true);
        controller.play();
        emit(VideoState(videos: [pickedFiles],videoPlayerController: controller));
  }

  }

  // 이 메서드는 사용자가 입력한 동영상 제목과 함께 VideoObject 리스트를 생성합니다.
  List<VideoObject> _createVideoObjects(UploadState state,List<String> titles) {
    List<VideoObject> videoObjects = [];
    for (int i = 0; i < state.videos!.length; i++) {
      videoObjects.add(
        VideoObject(
          title: titles[i],
          uploader: '사용자 이름', // 업로더 정보를 적절하게 수정하세요.
          path: state.videos![i].path,
        ),
      );
    }
    return videoObjects;
  }

  Future<void> _uploadVideos(UploadVideoEvent event,emit) async {
    if (state.videos == null || state.videos!.isEmpty) {
      emit(SnackBarState(message: "동영상을 선택하세요."));
      return;
    }
    emit(UploadingState(videos: state.videos, videoPlayerController: state.videoPlayerController));

    // 여기서 titles를 적절한 값으로 설정하십시오.
    List<String> titles = [
      event.text,
      '예제2'
    ]; // 동영상 제목을 사용자로부터 입력받아 설정하세요.

    try {
      List<MultipartFile> files = [];
      List<VideoObject> videoObjects = _createVideoObjects(state,titles);


      for (VideoObject videoObject in videoObjects) {
        final videoFile = File(videoObject.path);
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
        emit(SnackBarState(message: "동영상 업로드에 성공했습니다."));
      } else {
        emit(SnackBarState(message: "동영상 업로드에 실패했습니다."));
      }

      emit(VideoState(videoPlayerController: state.videoPlayerController));
    } catch (e) {
      print(e);
      emit(SnackBarState(message: "동영상 업로드 중 오류가 발생했습니다."));
    }
  }
  @override
  Future<void> close() {
    state.videoPlayerController?.dispose();
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

class ResetSnackBarEvent extends UploadEvent {
  @override
  List<Object?> get props => [];
}

abstract class UploadState extends Equatable{
  final List<XFile>? videos;
  final VideoPlayerController? videoPlayerController; // Add this line

  UploadState({this.videos, this.videoPlayerController});
}

class UploadingState extends UploadState {
  UploadingState({super.videos, super.videoPlayerController});


  @override
  List<Object?> get props => [videos, videoPlayerController];
}

class VideoState extends UploadState{
  VideoState({super.videos,super.videoPlayerController});

  @override
  List<Object?> get props => [videos,videoPlayerController];
}

class SnackBarState extends UploadState {
  final String message;

  SnackBarState({required this.message, super.videos, super.videoPlayerController});

  @override
  List<Object?> get props => [message, videos, videoPlayerController];
}