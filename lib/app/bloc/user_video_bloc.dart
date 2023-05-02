import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:DTalk/app/model/user_video.dart';
import 'package:DTalk/app/view/home_page.dart';

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class UserVideoBloc extends Bloc<UserVideoEvent, UserVideoState> {
  List<UserVideo>? videos=[];

  UserVideoBloc() : super(VideoInitial()) {
    on<LoadVideoEvent>((event, emit) async => await _loadVideos(event,emit));
    on<UpdatePrevVideoControllers>((event, emit) async => await _updatePrevControllers(event, emit));
    on<UpdateNextVideoControllers>((event, emit) async => await _updateNextControllers(event, emit));
    on<PlayAndPauseEvent>((event, emit) async => await _playAndPause(event, emit));
  }


  Future<void> _playAndPause(PlayAndPauseEvent event, Emitter<UserVideoState> emit) async {
    if(state.currentController!.isPlaying()!){
      await state.currentController!.seekTo(Duration.zero);
      await state.currentController!.pause();
    }else {
      await state.currentController!.play();
    }
  }

  Future<void> _updatePrevControllers(UpdatePrevVideoControllers event, Emitter<UserVideoState> emit) async {
    if(event.currentIndex! == 1){ // 첫동영상으로 갔을때
      emit(VideoLoaded(prevController: null, currentController: state.prevController, nextController: state.currentController, video: state.video));
      await state.nextController!.seekTo(Duration.zero);
      await state.nextController!.pause();
      await state.currentController!.play();
    }else{
      BetterPlayerController? prevController = await _initializeVideo(state.video![event.currentIndex!-2]);
      emit(VideoLoaded(prevController: prevController, currentController: state.prevController, nextController: state.currentController, video: state.video));
      await state.nextController!.seekTo(Duration.zero);
      await state.nextController!.pause();
      await state.currentController!.play();
    }
  }

  Future<void> _updateNextControllers(UpdateNextVideoControllers event, Emitter<UserVideoState> emit) async {
    if(event.currentIndex!+2 >= state.video!.length){ // 마지막 동영상으로 갔을때
      emit(VideoLoaded(prevController: state.currentController, currentController: state.nextController, nextController: null, video: state.video));
      await state.prevController!.seekTo(Duration.zero);
      await state.prevController!.pause();
      await state.currentController!.play();
    }else{
      BetterPlayerController? nextController =  await _initializeVideo(state.video![event.currentIndex!+2]);
      emit(VideoLoaded(prevController: state.currentController, currentController: state.nextController, nextController: nextController, video: state.video));
      await state.prevController!.seekTo(Duration.zero);
      await state.prevController!.pause();
      await state.currentController!.play();
    }
  }


  Future<void> _loadVideos(LoadVideoEvent event, Emitter<UserVideoState> emit) async {
    List<UserVideo> temp = event.userVideo!;
    int index = event.currentIndex!;
    BetterPlayerController? prevController;
    BetterPlayerController? nextController;
    if (temp.isEmpty) {
      return;
    }

      if(index!=0 && temp.length>1){
        prevController = await _initializeVideo(temp[index-1]);
      }else{
        state.prevController?.dispose(forceDispose: true);
        prevController=null;
      }
      state.currentController?.dispose(forceDispose: true);
      BetterPlayerController currentController = await _initializeVideo(temp[index]);

      if(index!=temp.length-1 && temp.length>1){
         nextController = await _initializeVideo(temp[index+1]);
      }else{
        state.nextController?.dispose(forceDispose: true);
        nextController=null;
      }


      videos=temp;
      emit(VideoLoaded(prevController: prevController, currentController: currentController, nextController: nextController, video: videos));
      await state.currentController!.play();

  }

  Future<BetterPlayerController> _initializeVideo(UserVideo video) async {
    BetterPlayerConfiguration betterPlayerConfiguration =
    BetterPlayerConfiguration(
        aspectRatio: VideoAspectRatio.aspectRatio2,
        autoPlay: false,
        looping: true,
        autoDispose: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: true,
          showControlsOnInitialize: false,
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
          enableRetry: false,));

    BetterPlayerDataSource betterPlayerDataSource =
    BetterPlayerDataSource(BetterPlayerDataSourceType.network, video.url,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 10 * 1024 * 1024,
          maxCacheFileSize: 10 * 1024 * 1024,
          preCacheSize: 10 * 1024 * 1024,
        ));

    BetterPlayerController betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
        betterPlayerDataSource: betterPlayerDataSource);

    return betterPlayerController;
  }

  @override
  Future<void> close() {
    state.nextController?.dispose(forceDispose: true);
    state.currentController?.dispose(forceDispose: true);
    state.prevController?.dispose(forceDispose: true);

    return super.close();
  }
}

// VideoEvent

abstract class UserVideoEvent extends Equatable {
  final List<UserVideo>? userVideo;
  final int? currentIndex;
  UserVideoEvent({this.userVideo,this.currentIndex});
}

class LoadVideoEvent extends UserVideoEvent {
  LoadVideoEvent({super.userVideo,super.currentIndex});

  @override
  List<Object?> get props => [userVideo,currentIndex];
}

class UpdatePrevVideoControllers extends UserVideoEvent {

  UpdatePrevVideoControllers({super.userVideo,super.currentIndex});

  @override
  List<Object?> get props => [userVideo,currentIndex];
}

class PlayAndPauseEvent extends UserVideoEvent {

  PlayAndPauseEvent({super.userVideo,super.currentIndex});

  @override
  List<Object?> get props => [userVideo,currentIndex];
}

class UpdateNextVideoControllers extends UserVideoEvent {

  UpdateNextVideoControllers({superuserVideo,super.currentIndex});

  @override
  List<Object?> get props => [userVideo,currentIndex];
}

// VideoState

abstract class UserVideoState extends Equatable {
  final BetterPlayerController? prevController;
  final BetterPlayerController? currentController;
  final BetterPlayerController? nextController;
  final List<UserVideo>? video;

  UserVideoState({this.prevController,this.currentController,this.nextController, this.video});
}

class VideoInitial extends UserVideoState {
  VideoInitial()
      : super(prevController: null, currentController: null, nextController: null, video: []);

  @override
  List<Object?> get props => [prevController, currentController, nextController, video];
}

class VideoLoaded extends UserVideoState {
  VideoLoaded({super.prevController, super.currentController, super.nextController, super.video});

  @override
  List<Object?> get props => [prevController, currentController, nextController, video];
}

