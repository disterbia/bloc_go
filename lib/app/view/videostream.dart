import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Streaming Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoScreenPage(title: 'Flutter Video Streaming Demo'),
    );
  }
}

class VideoScreenPage extends StatefulWidget {
  VideoScreenPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreenPage> {
  List<ChewieController> _chewieControllers = [];
  Dio dio = Dio();
  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  int _currentPage = 0;
  int _currentIndex=0;
  bool _hasMoreVideos = true;

  Future<ChewieController> _initializeVideo(String downloadUrl, bool autoPlay) async {
    VideoPlayerController videoPlayerController = VideoPlayerController.network(downloadUrl);
    await videoPlayerController.initialize();

    ChewieController chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: autoPlay,
      looping: false,
    );

    return chewieController;
  }

  Future<void> _loadVideos() async {
    if (!_hasMoreVideos) return;

    List<String> videoFiles = [];
    List<String> temp = await fetchVideosFromServer(_currentPage);
    videoFiles.addAll(temp);

    if (videoFiles.isEmpty) {
      _hasMoreVideos = false;
      return;
    }

    List<Future<ChewieController>> videoPromises = [];

    for (String downloadUrl in videoFiles) {
      videoPromises.add(_initializeVideo(downloadUrl, _currentIndex == 0));
      _currentIndex++;
    }

    List<ChewieController> loadedChewieControllers = await Future.wait(videoPromises);

    setState(() {
      _chewieControllers.addAll(loadedChewieControllers);
    });

    _currentPage++;
  }

  Future<List<String>> fetchVideosFromServer(int page) async {
    final response = await dio.get(
      'http://100.100.109.207:8080/videos?page=$page',
    );

    if (response.statusCode == 200) {
      return List<String>.from(response.data);
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView.builder(
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              _chewieControllers[index].play();
            },
            child: Chewie(
              controller: _chewieControllers[index],
            ),
          );
        },
        itemCount: _chewieControllers.length,
        onPageChanged: (int index) {
          for (int i = 0; i < _chewieControllers.length; i++) {
            if (i == index) {
              _chewieControllers[i].play();
            } else {
              _chewieControllers[i].pause();
              _chewieControllers[i].videoPlayerController.seekTo(Duration.zero);
            }
          }

          if (index == _chewieControllers.length - 1 && _hasMoreVideos) {
            _loadVideos();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (ChewieController chewieController in _chewieControllers) {
      chewieController.dispose();
    }
    super.dispose();
  }
}