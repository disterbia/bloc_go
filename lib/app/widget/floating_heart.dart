import 'package:flutter/material.dart';

class FloatingHeart extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> positionAnimation;
  final Animation<double> opacityAnimation;

  FloatingHeart({required this.controller})
      : positionAnimation = Tween<double>(begin: 0, end: -100).animate(
    CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ),
  ),
        opacityAnimation = Tween<double>(begin: 1, end: 0.5).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(0.7, 1.0, curve: Curves.easeOut),
          ),
        );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0, positionAnimation.value),
            child: Icon(Icons.favorite, size: 20, color: Colors.red),
          ),
        );
      },
    );
  }
}