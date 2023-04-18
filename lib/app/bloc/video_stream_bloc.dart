import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:eatall/app/model/video_stream.dart';
import 'package:eatall/app/view/home_page.dart';

import 'package:flutter/material.dart';
import 'package:eatall/app/repository/video_stream_repository.dart';
import 'package:equatable/equatable.dart';

class VideoStreamBloc extends Bloc<VideoEvent, VideoState> {
  final VideoStreamRepository repository;
  List<BetterPlayerController?>? updatedBetterPlayerControllers;
  List<String> videoUrls=[];
  List<VideoStream>? videos=[];

  VideoStreamBloc(this.repository) : super(VideoInitial()) {
    on<LoadVideoEvent>((event, emit) async => await _loadVideos(event,emit));
  }

  Future<void> _loadVideos(LoadVideoEvent event,Emitter<VideoState> emit) async {
    List<VideoStream> temp =
        await repository.fetchVideosFromServer(event.page!,event.url);
    print(temp);
    if (temp.isEmpty) {
      return;
    }

    updatedBetterPlayerControllers =
        List<BetterPlayerController>.from(state.betterPlayerControllers!);

    for (int i = 0; i < temp.length; i++) {
      videoUrls!.add(temp[i].url);
      BetterPlayerController betterPlayerController =
          await _initializeVideo(temp[i]);
      updatedBetterPlayerControllers!.add(betterPlayerController);
    }

    videos!.addAll(temp);
    emit(VideoLoaded(
        video:videos,
        betterPlayerControllers: updatedBetterPlayerControllers,
        videoUrl: videoUrls));
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
            cacheConfiguration: const BetterPlayerCacheConfiguration(
              useCache: true,
              maxCacheSize: 100 * 1024 * 1024,
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
    for (BetterPlayerController? betterPlayerController
        in state.betterPlayerControllers!) {
      betterPlayerController?.dispose();
    }
    return super.close();
  }
}

// VideoEvent

abstract class VideoEvent extends Equatable {
  final String? url;
  final int page;
  VideoEvent({required this.page,this.url});
}

class LoadVideoEvent extends VideoEvent {
  LoadVideoEvent({required super.page,super.url});

  @override
  List<Object?> get props => [page,url];
}


// VideoState

abstract class VideoState extends Equatable {
  final List<BetterPlayerController?>? betterPlayerControllers;
  final List<VideoStream>? video;
  final List<String>? videoUrl;

  VideoState({this.betterPlayerControllers, this.video,this.videoUrl});
}

class VideoInitial extends VideoState {
  VideoInitial() : super(betterPlayerControllers: [], video: [],videoUrl: []);

  @override
  List<Object?> get props => [betterPlayerControllers,video,videoUrl];
}

class VideoLoaded extends VideoState {
  VideoLoaded({super.betterPlayerControllers, super.video,super.videoUrl});

  @override
  List<Object?> get props => [betterPlayerControllers,video,videoUrl];
}
