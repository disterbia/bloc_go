import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    List<String> videoFiles = [
      // Firebase Storage의 m3u8 파일 이름 목록을 입력합니다.
      "videos/e38fc7ec-ab55-4471-8046-d6e41ca27694-39116.mp4.m3u8",
      "videos/bc975c22-9314-4eaa-8b0d-25b0ee23f131-110734.mp4.m3u8",
      "videos/abdc9ab9-6619-4c0b-9a03-4ddbc5109886-120739.mp4.m3u8",
      "videos/78b72825-1770-4462-9e61-9ba97eab48fb-65560.mp4.m3u8",
      "videos/45f922d7-ee45-4c80-9682-1974b41bb118-112957.mp4.m3u8",
      "videos/1dbed92d-668e-48ed-8e6e-ea4e68e56f0c-73847.mp4.m3u8",

    ];

    final firebaseStorage = FirebaseStorage.instance;
    int videoIndex = 0;
    for (String videoFile in videoFiles) {
      String downloadUrl = await firebaseStorage.ref(videoFile).getDownloadURL();
      print('Download URL: $downloadUrl');
      VideoPlayerController videoPlayerController = VideoPlayerController.network(downloadUrl);
      await videoPlayerController.initialize();

      ChewieController chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay:videoIndex == 0,
        looping: false,
      );

      setState(() {
        _chewieControllers.add(chewieController);
      });
      videoIndex++;
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

