import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:better_player/better_player.dart';

class TakeVideoScreen extends StatefulWidget {
  @override
  _TakeVideoScreenState createState() => _TakeVideoScreenState();
}

class _TakeVideoScreenState extends State<TakeVideoScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  BetterPlayerController? _betterPlayerController;
  String? _videoPath;
  String? _videoTitle;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      _controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  Future<void> _startVideoRecording() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    final Directory appDocDirectory = await getApplicationDocumentsDirectory();
    final String videoPath = '${appDocDirectory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      await _controller!.startVideoRecording();
      _videoPath = videoPath;
    } catch (e) {
      _showSnackBar(context, 'Failed to start video recording: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      return;
    }

    try {
      XFile file = await _controller!.stopVideoRecording();
      _videoPath = file.path;
    } catch (e) {
      _showSnackBar(context, 'Failed to stop video recording: $e');
    } finally {
      setState(() {
        _isRecording = false;
      });

      if (_videoPath != null) {
        _betterPlayerController = BetterPlayerController(
          BetterPlayerConfiguration(
            autoPlay: true,
            looping: true,
            aspectRatio: 16 / 9,
            fit: BoxFit.contain,
            controlsConfiguration: BetterPlayerControlsConfiguration(
              showControls: true,
              enableSkips: false,
              enableFullscreen: false,
              enableOverflowMenu: false,
            ),
          ),
          betterPlayerDataSource: BetterPlayerDataSource.file(_videoPath!),
        );
        setState(() {});
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _uploadVideo() async {
    if (_videoPath != null && _videoTitle != null && _videoTitle!.isNotEmpty) {
      // Implement your video upload logic here
      // You can use your existing VideoUploadBloc and VideoUploadRepository
    } else {
      _showSnackBar(context, 'Please enter a title for the video.');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      body: _controller != null && _controller!.value.isInitialized
          ? Stack(
        children: [
          CameraPreview(_controller!),
          if (_betterPlayerController != null)
            AspectRatio(
              aspectRatio: _betterPlayerController!.videoPlayerController!.value.aspectRatio,
              child: BetterPlayer(controller: _betterPlayerController!),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(height: 50,width: 50,
              child: TextField(
                onChanged: (value) => _videoTitle = value,
                decoration: InputDecoration(
                  labelText: 'Video Title',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!_isRecording)
              FloatingActionButton(
                onPressed: () async {
                  setState(() {
                    _isRecording = true;
                  });
                  await _startVideoRecording();
                },
                child: Icon(Icons.videocam),
              ),
            if (_isRecording)
              FloatingActionButton(
                onPressed: () async {
                  await _stopVideoRecording();
                },
                child: Icon(Icons.stop),
              ),
            if (!_isRecording && _videoPath != null)
              FloatingActionButton(
                onPressed: () async {
                  await _uploadVideo();
                },
                child: Icon(Icons.file_upload),
              ),
          ],
        ),
      ),
    );
  }
}