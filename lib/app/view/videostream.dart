import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:eatall/app/view/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoScreenPage extends StatefulWidget {
  VideoScreenPage(this.id);
  String id;
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreenPage> {
  List<GlobalKey<ChatScreenState>> _chatScreenKeys = [];
  List<ChewieController?> _chewieControllers = [];
  List<String> _videoUrls = [];
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  int _currentPage = 0;
  bool _hasMoreVideos = true;

  GlobalKey<ChatScreenState> createChatScreenKey() {
    return GlobalKey<ChatScreenState>();
  }

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
  Future<List<String>> fetchVideosFromServer(int page) async {
    final response = await dio.get(
      'http://192.168.0.88:8080/videos?page=$page',
    );

    if (response.statusCode == 200) {
      return List<String>.from(response.data);
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<void> _loadVideos() async {
    if (!_hasMoreVideos) return;

    List<String> temp = await fetchVideosFromServer(_currentPage);
    _videoUrls.addAll(temp);

    if (temp.isEmpty) {
      _hasMoreVideos = false;
      return;
    }

    setState(() {
      for (int i = 0; i < temp.length; i++) {
        _chewieControllers.add(null);
        GlobalKey<ChatScreenState> chatKey = createChatScreenKey();
        _chatScreenKeys.add(chatKey);
        if (i == 0) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            chatKey.currentState?.updateRoomId('chat_room_0');
            chatKey.currentState?.connectWebSocket();
          });
        }
      }
    });

    _currentPage++;
  }



  Widget _buildVideoWidget(int index) {

    if (_chewieControllers[index] == null) {
      _initializeVideo(_videoUrls[index], index == 0).then((chewieController) {
        setState(() {
          _chewieControllers[index] = chewieController;
        });
      });

      if (index + 1 < _videoUrls.length) {
        _initializeVideo(_videoUrls[index + 1], false).then((chewieController) {
          setState(() {
            _chewieControllers[index + 1] = chewieController;
          });
        });
      }
    }

    if (index + 2 < _videoUrls.length && _chewieControllers[index + 2] == null) {
      _initializeVideo(_videoUrls[index + 2], false).then((chewieController) {
        setState(() {
          _chewieControllers[index + 2] = chewieController;
        });
      });
    }

    return _chewieControllers[index] != null
        ? Chewie(controller: _chewieControllers[index]!)
        : Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              _chewieControllers[index]?.play();
            },
            child: Column(
              children: [
                Expanded(child: _buildVideoWidget(index)),
                Expanded(child: ChatScreen(key: _chatScreenKeys[index], roomId: 'chat_room_$index')),
              ],
            ),
          );
        },
        itemCount: _chewieControllers.length,
        onPageChanged: (int index) {
          for (int i = 0; i < _chewieControllers.length; i++) {
            if (i == index) {
              _chewieControllers[i]?.play();
              _chatScreenKeys[i].currentState?.updateRoomId('chat_room_$index');
              _chatScreenKeys[i].currentState?.connectWebSocket();
            } else {
              _chewieControllers[i]?.pause();
              _chewieControllers[i]?.videoPlayerController.seekTo(Duration.zero);
              _chatScreenKeys[i].currentState?.disposeWebSocket();
              _chatScreenKeys[i].currentState?.clearMessages();
            }
          }

          if (index == _chewieControllers.length - 2 && _hasMoreVideos) {
            _loadVideos();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (ChewieController? chewieController in _chewieControllers) {
      chewieController?.dispose();
    }
    super.dispose();
  }
}