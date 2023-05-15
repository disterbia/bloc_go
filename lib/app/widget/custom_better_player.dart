import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class YourCustomControls extends StatelessWidget {
  final BetterPlayerController controller;
  final Function(bool visible) onPlayerVisibilityChanged;

  YourCustomControls({
    required this.controller,
    required this.onPlayerVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Image.asset(controller.isPlaying()! ? 'assets/img/up_play.png' : "assets/img/up_play.png"),
          onPressed: () {
            if (controller.isPlaying()!) {
              controller.pause();
            } else {
              controller.play();
            }
          },
        ),
        // Other controls go here...
      ],
    );
  }
}