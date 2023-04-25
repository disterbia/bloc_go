import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:eatall/app/const/addr.dart';
import 'package:eatall/app/model/message.dart';
import 'package:eatall/app/model/socket_event.dart';
import 'package:eatall/app/model/video_stream.dart';
import 'package:eatall/app/repository/video_stream_repository.dart';
import 'package:eatall/main.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final VideoStreamRepository repository;
  IOWebSocketChannel? _prevChannel;
  IOWebSocketChannel? _currentChannel;
  IOWebSocketChannel? _nextChannel;

  ChatBloc(this.repository) : super(ChatInitial()) {
    on<SendMessageEvent>((event, emit) {
      _sendMessage(event.text, event.userId);
    });
    on<LikeOrDisLikeEvent>((event, emit) {
      _likeOrDislike(event.userId);
    });
    on<InitailConnectEvent>((event, emit) async {
       await initialConnect(emit);
    });
    on<UpdatePrevConnectEvent>((event, emit) async {
      await updatePrevWebSocket(emit, event.videos, event.currentIndex);
    });
    on<UpdateNextConnectEvent>((event, emit) async {
      await updateNextWebSocket(emit, event.videos, event.currentIndex);
    });
  }

  Future<void> initialConnect(Emitter<ChatState> emit) async {
    List<VideoStream> temp = await repository.fetchVideosFromServer(0, null);
      connectWebSocket(emit, temp[0].id, 0);
    await connectWebSocket(emit, temp[1].id, 0);

  }

  Future<void> updatePrevWebSocket(Emitter<ChatState> emit,
      List<VideoStream> video, int currentIndex) async {
    if (currentIndex == 1) {
      //처음으로갈때
      _nextChannel?.sink.close();
      _nextChannel = _currentChannel;
      _currentChannel = _prevChannel;
      _prevChannel=null;
    } else {
      _nextChannel?.sink.close();
      _nextChannel = _currentChannel;
      _currentChannel = _prevChannel;
      await connectWebSocket(emit, video[currentIndex - 2].id, -1);
    }
  }

  Future<void> updateNextWebSocket(Emitter<ChatState> emit,
      List<VideoStream> video, int currentIndex) async {
    if (currentIndex + 2 == video.length) {
      //마지막으로 갈때
      await _prevChannel?.sink.close();
      _prevChannel = _currentChannel;
      _currentChannel = _nextChannel;
      _nextChannel=null;
    } else {
      await _prevChannel?.sink.close();
      _prevChannel = _currentChannel;
      _currentChannel = _nextChannel;
     await connectWebSocket(emit, video[currentIndex + 2].id, 1);
    }
  }


  Future<void> connectWebSocket(
      Emitter<ChatState> emit, String roomId, int notice) async {
    //_channel!.stream.listen((event)
    emit(ChatLoading(
        controller: state.controller,
        prevInfo: state.prevInfo,
        currentInfo: state.currentInfo,
        nextInfo: state.nextInfo));
    List<Message> messages = [];
    if (notice == -1) {
      _prevChannel = IOWebSocketChannel.connect(
          '${Address.wsAddr}ws?room_id=$roomId&user_id=${UserID.uid}');
      await for (final event in _prevChannel!.stream) {
        Map<String, dynamic> eventData = jsonDecode(event);
        SocketEvent socketEvent = SocketEvent.fromJson(eventData);
        if (socketEvent.evnetType == "first_message") {
          messages.add(socketEvent.message!);
          emit(FirstState(
              controller: state.controller,
              prevInfo: SocketState(
                  messages: messages,
                  userLike: state.prevInfo?.userLike,
                  totalLike: state.prevInfo?.totalLike),
              currentInfo: state.currentInfo,
              nextInfo: state.nextInfo));
        } else if (socketEvent.evnetType == "first_like") {
          if (socketEvent.userId == UserID.uid) {
            emit(FirstState(
                controller: state.controller,
                prevInfo: SocketState(
                    messages: state.prevInfo?.messages,
                    userLike: socketEvent.userLike,
                    totalLike: socketEvent.totalLike),
                currentInfo: state.currentInfo,
                nextInfo: state.nextInfo));
          } else {
            emit(FirstState(
                controller: state.controller,
                prevInfo: SocketState(
                    messages: state.prevInfo?.messages,
                    userLike: state.prevInfo?.userLike,
                    totalLike: socketEvent.totalLike),
                currentInfo: state.currentInfo,
                nextInfo: state.nextInfo));
          }
        } else if (socketEvent.evnetType == "message") {
          List<Message> messages = List<Message>.from(state.prevInfo!.messages!)
            ..add(socketEvent.message!);
          emit(ChatChange(
              controller: state.controller,
              prevInfo: SocketState(
                  messages: messages,
                  totalLike: state.prevInfo?.totalLike,
                  userLike: state.prevInfo?.userLike),
              currentInfo: state.currentInfo,
              nextInfo: state.nextInfo));
        } else if (socketEvent.evnetType == "total_like") {
          if (socketEvent.userId == UserID.uid) {
            emit(LikeChange(
                controller: state.controller,
                prevInfo: SocketState(
                    messages: state.prevInfo?.messages,
                    userLike: socketEvent.userLike,
                    totalLike: socketEvent.totalLike),
                currentInfo: state.currentInfo,
                nextInfo: state.nextInfo));
          } else {
            emit(LikeChange(
                controller: state.controller,
                prevInfo: SocketState(
                    messages: state.prevInfo?.messages,
                    userLike: state.prevInfo?.userLike,
                    totalLike: socketEvent.totalLike),
                currentInfo: state.currentInfo,
                nextInfo: state.nextInfo));
          }
        }
      }
    } else if (notice == 0) {
      _currentChannel = IOWebSocketChannel.connect(
          '${Address.wsAddr}ws?room_id=$roomId&user_id=${UserID.uid}');
      await for (final event in _currentChannel!.stream) {
        Map<String, dynamic> eventData = jsonDecode(event);
        SocketEvent socketEvent = SocketEvent.fromJson(eventData);
        print("=-=-=-=${socketEvent.evnetType}");
        if (socketEvent.evnetType == "first_message") {
          messages.add(socketEvent.message!);
          emit(FirstState(
              controller: state.controller,
              currentInfo: SocketState(
                  messages: messages,
                  userLike: state.currentInfo?.userLike,
                  totalLike: state.currentInfo?.totalLike),
              nextInfo: state.nextInfo,
              prevInfo: state.prevInfo));
        } else if (socketEvent.evnetType == "first_like") {
          if (socketEvent.userId == UserID.uid) {
            emit(FirstState(
                controller: state.controller,
                currentInfo: SocketState(
                    messages: state.currentInfo?.messages,
                    userLike: socketEvent.userLike,
                    totalLike: socketEvent.totalLike),
                nextInfo: state.nextInfo,
                prevInfo: state.prevInfo));
          } else {
            emit(FirstState(
                controller: state.controller,
                currentInfo: SocketState(
                    messages: state.currentInfo?.messages,
                    userLike: state.currentInfo?.userLike,
                    totalLike: socketEvent.totalLike),
                nextInfo: state.nextInfo,
                prevInfo: state.prevInfo));
          }
        } else if (socketEvent.evnetType == "message") {
          List<Message> messages =
              List<Message>.from(state.currentInfo!.messages!)
                ..add(socketEvent.message!);
          emit(ChatChange(
              controller: state.controller,
              currentInfo: SocketState(
                  messages: messages,
                  totalLike: state.currentInfo?.totalLike,
                  userLike: state.currentInfo?.userLike),
              nextInfo: state.nextInfo,
              prevInfo: state.prevInfo));
        } else if (socketEvent.evnetType == "total_like") {
          if (socketEvent.userId == UserID.uid) {
            emit(LikeChange(
                controller: state.controller,
                currentInfo: SocketState(
                    messages: state.currentInfo?.messages,
                    userLike: socketEvent.userLike,
                    totalLike: socketEvent.totalLike),
                nextInfo: state.nextInfo,
                prevInfo: state.prevInfo));
          } else {
            emit(LikeChange(
                controller: state.controller,
                currentInfo: SocketState(
                    messages: state.currentInfo?.messages,
                    userLike: state.currentInfo?.userLike,
                    totalLike: socketEvent.totalLike),
                nextInfo: state.nextInfo,
                prevInfo: state.prevInfo));
          }
        }
      }
    } else {
      _nextChannel = IOWebSocketChannel.connect(
          '${Address.wsAddr}ws?room_id=$roomId&user_id=${UserID.uid}');
      await for (final event in _nextChannel!.stream) {
        Map<String, dynamic> eventData = jsonDecode(event);
        SocketEvent socketEvent = SocketEvent.fromJson(eventData);
        if (socketEvent.evnetType == "first_message") {
          messages.add(socketEvent.message!);
          emit(FirstState(
            controller: state.controller,
            nextInfo: SocketState(
                messages: messages,
                userLike: state.nextInfo?.userLike,
                totalLike: state.nextInfo?.totalLike),
            prevInfo: state.prevInfo,
            currentInfo: state.currentInfo,
          ));
        } else if (socketEvent.evnetType == "first_like") {
          if (socketEvent.userId == UserID.uid) {
            emit(FirstState(
                controller: state.controller,
                nextInfo: SocketState(
                    messages: state.nextInfo?.messages,
                    userLike: socketEvent.userLike,
                    totalLike: socketEvent.totalLike),
                prevInfo: state.prevInfo,
                currentInfo: state.currentInfo));
          } else {
            emit(FirstState(
                controller: state.controller,
                nextInfo: SocketState(
                    messages: state.nextInfo?.messages,
                    userLike: state.nextInfo?.userLike,
                    totalLike: socketEvent.totalLike),
                prevInfo: state.prevInfo,
                currentInfo: state.currentInfo));
          }
        } else if (socketEvent.evnetType == "message") {
          List<Message> messages = List<Message>.from(state.nextInfo!.messages!)
            ..add(socketEvent.message!);
          emit(ChatChange(
              controller: state.controller,
              nextInfo: SocketState(
                  messages: messages,
                  totalLike: state.nextInfo?.totalLike,
                  userLike: state.nextInfo?.userLike),
              prevInfo: state.prevInfo,
              currentInfo: state.currentInfo));
        } else if (socketEvent.evnetType == "total_like") {
          if (socketEvent.userId == UserID.uid) {
            emit(LikeChange(
                controller: state.controller,
                nextInfo: SocketState(
                    messages: state.nextInfo?.messages,
                    userLike: socketEvent.userLike,
                    totalLike: socketEvent.totalLike),
                prevInfo: state.prevInfo,
                currentInfo: state.currentInfo));
          } else {
            emit(LikeChange(
                controller: state.controller,
                nextInfo: SocketState(
                    messages: state.nextInfo?.messages,
                    userLike: state.nextInfo?.userLike,
                    totalLike: socketEvent.totalLike),
                prevInfo: state.prevInfo,
                currentInfo: state.currentInfo));
          }
        }
      }
    }
  }

  void _sendMessage(String text, String username) {
    if (text.isNotEmpty) {
      SocketEvent socketEvent = SocketEvent(
        evnetType: "message",
        message: Message(username: username, text: text),
      );
      _currentChannel?.sink.add(jsonEncode(socketEvent.toJson()));
      state.controller!.clear();
    }
  }

  void _likeOrDislike(String userId) {
    SocketEvent socketEvent = SocketEvent(evnetType: "like", userId: userId);
    _currentChannel?.sink.add(jsonEncode(socketEvent.toJson()));
  }

  void disposeWebSocket() {
    if (_prevChannel != null) {
      _prevChannel?.sink.close();
      _prevChannel = null;
    }
    if (_currentChannel != null) {
      _currentChannel?.sink.close();
      _currentChannel = null;
    }
    if (_nextChannel != null) {
      _nextChannel?.sink.close();
      _nextChannel = null;
    }
  }

  @override
  Future<void> close() {
    print("-==-=--=-=-=");
    disposeWebSocket();
    return super.close();
  }
}

abstract class ChatEvent extends Equatable {}

class SendMessageEvent extends ChatEvent {
  final String text;
  final String userId;

  SendMessageEvent({required this.text, required this.userId});

  @override
  List<Object?> get props => [text];
}

class LikeOrDisLikeEvent extends ChatEvent {
  final String userId;

  LikeOrDisLikeEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class InitailConnectEvent extends ChatEvent {
  InitailConnectEvent();

  @override
  List<Object?> get props => [];
}

class UpdateNextConnectEvent extends ChatEvent {
  final List<VideoStream> videos;
  final int currentIndex;

  UpdateNextConnectEvent(this.videos, this.currentIndex);

  @override
  List<Object?> get props => [videos, currentIndex];
}

class UpdatePrevConnectEvent extends ChatEvent {
  final List<VideoStream> videos;
  final int currentIndex;

  UpdatePrevConnectEvent(this.videos, this.currentIndex);

  @override
  List<Object?> get props => [videos, currentIndex];
}

abstract class ChatState extends Equatable {
  final TextEditingController? controller;
  final SocketState? prevInfo;
  final SocketState? currentInfo;
  final SocketState? nextInfo;

  ChatState({this.controller, this.prevInfo, this.currentInfo, this.nextInfo});
}

// ChatState
class ChatChange extends ChatState {
  ChatChange(
      {super.controller, super.prevInfo, super.currentInfo, super.nextInfo});

  @override
  List<Object?> get props => [controller, prevInfo, currentInfo, nextInfo];
}

class LikeChange extends ChatState {
  LikeChange(
      {super.controller, super.prevInfo, super.currentInfo, super.nextInfo});

  @override
  List<Object?> get props => [controller, prevInfo, currentInfo, nextInfo];
}

class FirstState extends ChatState {
  FirstState(
      {super.controller, super.prevInfo, super.currentInfo, super.nextInfo});

  @override
  List<Object?> get props => [controller, prevInfo, currentInfo, nextInfo];
}

class ChatInitial extends ChatState {
  ChatInitial() : super(controller: TextEditingController());

  @override
  List<Object?> get props => [controller];
}

class ChatLoading extends ChatState {
  ChatLoading(
      {super.controller, super.prevInfo, super.currentInfo, super.nextInfo});

  @override
  List<Object?> get props => [controller, prevInfo, currentInfo, nextInfo];
}

 class SocketState{
  final List<Message>? messages;
  final int? totalLike;
  final bool? userLike;
  SocketState({this.totalLike,this.userLike,this.messages});
}
