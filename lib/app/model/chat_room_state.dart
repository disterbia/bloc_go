import 'package:eatall/app/model/message.dart';
import 'package:flutter/material.dart';

class ChatRoomState {
  List<Message> messages;
  TextEditingController controller;
  bool isLoading;
  int totalLike;
  bool isLike;

  ChatRoomState({
    required this.messages,
    required this.controller,
    required this.isLoading,
    required this.totalLike,
    required this.isLike,
  });

  ChatRoomState.initial()
      : messages = [],
        controller = TextEditingController(),
        isLoading = true,
        totalLike = 0,
        isLike = false;

  ChatRoomState copyWith({
    List<Message>? messages,
    TextEditingController? controller,
    bool? isLoading,
    int? totalLike,
    bool? isLike,
  }) {
    return ChatRoomState(
      messages: messages ?? this.messages,
      controller: controller ?? this.controller,
      isLoading: isLoading ?? this.isLoading,
      totalLike: totalLike ?? this.totalLike,
      isLike: isLike ?? this.isLike,
    );
  }
}