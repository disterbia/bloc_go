import 'package:DTalk/app/model/message.dart';
import 'package:flutter/material.dart';

class ChatRoomState {
  final String roomId;
  final List<Message> messages;
  final TextEditingController controller;
  final bool isLoading;
  final int totalLike;
  final bool isLike;
  final bool animate;

  ChatRoomState({
    required this.roomId,
    required this.messages,
    required this.controller,
    required this.isLoading,
    required this.totalLike,
    required this.isLike,
    required this.animate,
  });

  ChatRoomState.initial()
      : roomId="",
        messages = [],
        controller = TextEditingController(),
        isLoading = true,
        totalLike = 0,
        isLike = false,
        animate = false;

  ChatRoomState copyWith({
    String? roomId,
    List<Message>? messages,
    TextEditingController? controller,
    bool? isLoading,
    int? totalLike,
    bool? isLike,
    bool? animate
  }) {
    return ChatRoomState(
      roomId: roomId ?? this.roomId,
      messages: messages ?? this.messages,
      controller: controller ?? this.controller,
      isLoading: isLoading ?? this.isLoading,
      totalLike: totalLike ?? this.totalLike,
      isLike: isLike ?? this.isLike,
      animate: animate ?? this.animate
    );
  }
}