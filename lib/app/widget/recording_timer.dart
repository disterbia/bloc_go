import 'package:flutter/material.dart';

class RecordingTimer extends StatefulWidget {
  final Duration maximumDuration;

  RecordingTimer({required this.maximumDuration});

  @override
  _RecordingTimerState createState() => _RecordingTimerState();
}

class _RecordingTimerState extends State<RecordingTimer> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.maximumDuration,
      vsync: this,
    )..addListener(() {
      setState(() {});
    });
    _controller.forward();
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final elapsedTime = _controller.duration! * _controller.value;
    final formattedElapsedTime = _formatDuration(elapsedTime);

    return Column(
      children: [
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(top: 2, right: 16),
          child: Text(
            formattedElapsedTime,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        LinearProgressIndicator(
          value: _controller.value,
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),

      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}