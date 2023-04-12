import 'dart:typed_data';

import 'package:better_player/better_player.dart';
import 'package:bloc/bloc.dart';
import 'package:eatall/app/model/video_stream.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:eatall/app/repository/video_stream_repository.dart';
import 'package:equatable/equatable.dart';

class VideoStreamBloc extends Bloc<VideoEvent, VideoState> {
  final VideoStreamRepository repository;
  int _currentPage = 0;
  List<String>? updatedVideoUrls;
  List<BetterPlayerController?>? updatedBetterPlayerControllers;
  bool isFirst = true;

  VideoStreamBloc(this.repository) : super(VideoInitial()) {
    on<LoadVideoEvent>((event, emit) async => await _loadVideos(event,emit));
  }


  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    final thumbnailData = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      maxHeight: 72,
      quality: 25,
    );
    // Image.memory(thumbnailData)
    return thumbnailData;

  }

  Future<void> _loadVideos(LoadVideoEvent event,Emitter<VideoState> emit) async {
    //print("--=-=-=-=-=-=-=-=-$_currentPage");
    List<VideoStream> temp =
        await repository.fetchVideosFromServer(_currentPage,event.url);
    print(temp);
    if (temp.isEmpty) {
      return;
    }

    updatedBetterPlayerControllers =
        List<BetterPlayerController>.from(state.betterPlayerControllers!);

    for (int i = 0; i < temp.length; i++) {
      BetterPlayerController betterPlayerController =
          await _initializeVideo(temp[i]);
      updatedBetterPlayerControllers!.add(betterPlayerController);
    }
    emit(VideoLoaded(
        videoUrls: updatedVideoUrls,
        betterPlayerControllers: updatedBetterPlayerControllers));

    _currentPage ++;
  }

  Future<BetterPlayerController> _initializeVideo(VideoStream video) async {
    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
            autoPlay: false,
            looping: false,
            autoDispose: false,
            controlsConfiguration: BetterPlayerControlsConfiguration(
                showControlsOnInitialize: false));

    BetterPlayerDataSource betterPlayerDataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, video.url,
            cacheConfiguration: const BetterPlayerCacheConfiguration(
              useCache: true,
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
  VideoEvent({this.url});
}

class LoadVideoEvent extends VideoEvent {
  LoadVideoEvent({super.url});

  @override
  List<Object?> get props => [url];
}


// VideoState

abstract class VideoState extends Equatable {
  final List<BetterPlayerController?>? betterPlayerControllers;
  final List<String>? videoUrls;

  VideoState({this.betterPlayerControllers, this.videoUrls});
}

class VideoInitial extends VideoState {
  VideoInitial() : super(betterPlayerControllers: [], videoUrls: []);

  @override
  List<Object?> get props => [betterPlayerControllers,videoUrls];
}

class VideoLoaded extends VideoState {
  VideoLoaded({super.betterPlayerControllers, super.videoUrls});

  @override
  List<Object?> get props => [betterPlayerControllers,videoUrls];
}
