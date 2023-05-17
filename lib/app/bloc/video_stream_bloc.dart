import 'package:Dtalk/app/view/splash_page.dart';
import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:Dtalk/app/model/video_stream.dart';
import 'package:Dtalk/app/view/home_page.dart';

import 'package:flutter/material.dart';
import 'package:Dtalk/app/repository/video_stream_repository.dart';
import 'package:equatable/equatable.dart';

class VideoStreamBloc extends Bloc<VideoEvent, VideoState> {
  final VideoStreamRepository repository;
  List<VideoStream>? videos=[];
  String firstUrl="";

  VideoStreamBloc(this.repository) : super(VideoInitial()) {
    on<LoadVideoEvent>((event, emit) async => await _loadVideos(emit));
    on<UpdatePrevVideoControllers>((event, emit) async => await _updatePrevControllers(event, emit));
    on<UpdateNextVideoControllers>((event, emit) async => await _updateNextControllers(event, emit));
    on<VideoPlayEvent>((event, emit) async => await _VideoPlay(event, emit));
    on<VideoPauseEvent>((event, emit) async => await _VideoPause(event, emit));
  }

  Future<void> _VideoPause(VideoPauseEvent event, Emitter<VideoState> emit) async {
    if(state.currentController!.isPlaying()! || state.currentController!.isVideoInitialized()!) {
      await state.currentController!.seekTo(Duration.zero);
      await state.currentController!.pause();
    }
  }

  Future<void> _VideoPlay(VideoPlayEvent event, Emitter<VideoState> emit) async {
    if(!state.currentController!.isPlaying()!){
      await state.currentController!.play();
    }
  }

  Future<void> _updatePrevControllers(UpdatePrevVideoControllers event, Emitter<VideoState> emit) async {
    if(event.currentIndex! == 1){ // 첫동영상으로 갔을때
      emit(VideoLoaded(prevController: null, currentController: state.prevController, nextController: state.currentController, video:state.video));
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

  Future<void> _updateNextControllers(UpdateNextVideoControllers event, Emitter<VideoState> emit) async {
    if(event.currentIndex!+2 >= state.video!.length){ // 마지막 동영상으로 갔을때
      emit(VideoLoaded(prevController: state.currentController, currentController: state.nextController, nextController: null, video: state.video));
      await state.prevController!.seekTo(Duration.zero);
      await state.prevController!.pause();
     await state.currentController!.play();
      await _getMoreVideos(state.video!.length,firstUrl,emit);
    }else{
      BetterPlayerController? nextController =  await _initializeVideo(state.video![event.currentIndex!+2]);
      emit(VideoLoaded(prevController: state.currentController, currentController: state.nextController, nextController: nextController, video: state.video));
      await state.prevController!.seekTo(Duration.zero);
      await state.prevController!.pause();
      await state.currentController!.play();
    }
  }

  Future<void> _getMoreVideos(int page,String firstUrl,Emitter<VideoState> emit) async{

    List<VideoStream> temp = await repository.fetchVideosFromServer(page,firstUrl);
    if (temp.isEmpty) {
      return;
    }
    BetterPlayerController newController= await _initializeVideo(temp.first);
    if(temp.first.isNew){
      this.firstUrl=temp[0].url;
      // videos!.insert(0, temp.first);
    }
    videos!.addAll(temp);
    emit(VideoLoaded(prevController: state.prevController, currentController: state.currentController, nextController: newController, video: videos));
  }

  Future<void> _loadVideos(Emitter<VideoState> emit) async {
    List<VideoStream> temp = await repository.fetchVideosFromServer(0, null);
    if (temp.isEmpty) {
      return;
    }
    firstUrl=temp[0].url;
    // 최초 로드 시 0번째, 1번째 동영상 컨트롤러 로드
    if (state.currentController == null) {
      BetterPlayerController currentController = await _initializeVideo(temp[0]);
      BetterPlayerController nextController = await _initializeVideo(temp[1]);
      videos!.addAll(temp);
      emit(VideoLoaded(prevController: null, currentController: currentController, nextController: nextController, video: videos));
      await state.currentController!.play();
    }
  }

  Future<BetterPlayerController> _initializeVideo(VideoStream video) async {
    BetterPlayerConfiguration betterPlayerConfiguration =
         BetterPlayerConfiguration(
            aspectRatio: VideoAspectRatio.aspectRatio,
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
          videoFormat: BetterPlayerVideoFormat.hls,
            cacheConfiguration: const BetterPlayerCacheConfiguration(
              useCache: true,
              maxCacheSize: 5 * 1024 * 1024,
              maxCacheFileSize: 5 * 1024 * 1024,
              preCacheSize: 3 * 1024 * 1024,
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

abstract class VideoEvent extends Equatable {
  final int? currentIndex;
  VideoEvent({this.currentIndex});
}

class LoadVideoEvent extends VideoEvent {
  LoadVideoEvent();

  @override
  List<Object?> get props => [];
}

class UpdatePrevVideoControllers extends VideoEvent {

  UpdatePrevVideoControllers({super.currentIndex});

  @override
  List<Object?> get props => [currentIndex];
}

class VideoPlayEvent extends VideoEvent {

  VideoPlayEvent({super.currentIndex});

  @override
  List<Object?> get props => [currentIndex];
}

class VideoPauseEvent extends VideoEvent {

  VideoPauseEvent();

  @override
  List<Object?> get props => [];
}

class UpdateNextVideoControllers extends VideoEvent {

  UpdateNextVideoControllers({super.currentIndex});

  @override
  List<Object?> get props => [currentIndex];
}

// VideoState

abstract class VideoState extends Equatable {
  final BetterPlayerController? prevController;
  final BetterPlayerController? currentController;
  final BetterPlayerController? nextController;
  final List<VideoStream>? video;

  VideoState({this.prevController,this.currentController,this.nextController, this.video});
}

class VideoInitial extends VideoState {
  VideoInitial()
      : super(prevController: null, currentController: null, nextController: null, video: []);

  @override
  List<Object?> get props => [prevController, currentController, nextController, video];
}

class VideoLoaded extends VideoState {
  VideoLoaded({super.prevController, super.currentController, super.nextController, super.video});

  @override
  List<Object?> get props => [prevController, currentController, nextController, video];
}

