
import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:eatall/app/bloc/chat_bloc.dart';
import 'package:eatall/app/repository/video_stream_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoStreamBloc extends Bloc<VideoEvent, VideoState> {
  final VideoStreamRepository repository;
  int _currentPage = 0;
  List<String>? updatedVideoUrls;
  List<ChewieController?>? updatedChewieControllers;

  VideoStreamBloc(this.repository) : super(VideoInitial()) {

    on<LoadVideoEvent>((event, emit)async => await _loadVideos(emit));
  }


  Future<void> _loadVideos(Emitter<VideoState> emit) async {
    _currentPage++;
    print("--=-=-=-=-=-=-=-=-$_currentPage");
    List<String> temp = await repository.fetchVideosFromServer(_currentPage-1);
    ;
    if (temp.isEmpty) return;

    updatedVideoUrls = List<String>.from(state.videoUrls!)..addAll(temp);
    updatedChewieControllers = List<ChewieController?>.from(state.chewieControllers!);

      for (int i = 0; i < temp.length; i++) {
        ChewieController chewieController = await _initializeVideo(temp[i]);
        updatedChewieControllers!.add(chewieController);
      }
     emit(VideoLoaded(videoUrls: updatedVideoUrls,chewieControllers: updatedChewieControllers));


  }

  Future<ChewieController> _initializeVideo(String downloadUrl) async {
    VideoPlayerController videoPlayerController = VideoPlayerController.network(downloadUrl);
    await videoPlayerController.initialize();

    ChewieController chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,

    );

    return chewieController;
  }


  @override
  Future<void> close() {
    for (ChewieController? chewieController in state.chewieControllers!) {
      chewieController?.dispose();
    }
    return super.close();
  }
}


// VideoEvent

abstract class VideoEvent extends Equatable {}

class LoadVideoEvent extends VideoEvent {
  LoadVideoEvent();

  @override
  List<Object?> get props => [];
}
class BuildVideoEvent extends VideoEvent {
  final int index;

  BuildVideoEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class PageChangedEvent extends VideoEvent {
  final int index;

  PageChangedEvent({required this.index});

  @override
  List<Object?> get props => [];
}

// VideoState

abstract class VideoState extends Equatable {
  final List<ChewieController?>? chewieControllers;
  final List<String>? videoUrls;
  VideoState({this.chewieControllers,this.videoUrls});
}

class VideoInitial extends VideoState {
  VideoInitial(): super(chewieControllers: [],videoUrls: []);

  @override
  List<Object?> get props => [];
}
class VideoLoaded extends VideoState {
  VideoLoaded({super.chewieControllers,super.videoUrls});

  @override
  List<Object?> get props => [];

}