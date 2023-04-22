import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:eatall/app/const/addr.dart';
import 'package:eatall/app/model/message.dart';
import 'package:eatall/app/model/socket_event.dart';
import 'package:eatall/main.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  IOWebSocketChannel? _channel;
  String? curruntVideo;
  ChatBloc() : super(ChatInitial()) {
    on<SendMessageEvent>((event, emit) {
      _sendMessage(event.text,event.userId);
    });
    on<LikeOrDisLikeEvent>((event, emit) {
      _likeOrDislike(event.userId);
    });
    on<NewChatEvent>((event, emit) async{
      await connectWebSocket(emit, event.roomId);
    });

  }

  void clearMessages(Emitter<ChatState> emit) async {
    emit(ChatChange(messages: [], controller: state.controller,isLoading: true,totalLike:0,isLike: false));
  }

  Future<void> connectWebSocket(Emitter<ChatState> emit, String roomId) async {
    if(curruntVideo != roomId){

      curruntVideo=roomId;
      disposeWebSocket();
      _channel = IOWebSocketChannel.connect('${Address.wsAddr}ws?room_id=$roomId&user_id=${UserID.uid}');
      clearMessages(emit);
      //_channel!.stream.listen((event)
      await for(final event in _channel!.stream) {
        Map<String, dynamic> eventData = jsonDecode(event);
        SocketEvent socketEvent = SocketEvent.fromJson(eventData);
        if(socketEvent.evnetType=="message"){
          List<Message> messages = List<Message>.from(state.messages!)
            ..add(socketEvent.message!);
          emit(ChatChange(messages: messages, controller: state.controller,isLoading: false,totalLike: state.totalLike,isLike: state.isLike));
        }else if(socketEvent.evnetType=="total_like"){
          if(socketEvent.userId==UserID.uid){
            emit(ChatChange(
                messages: state.messages, controller: state.controller,isLoading: false,totalLike: socketEvent.totalLike,isLike: socketEvent.userLike
            ));
          }else{
            emit(ChatChange(
                messages: state.messages, controller: state.controller,isLoading: false,totalLike: socketEvent.totalLike,isLike:state.isLike));
          }
        }

        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //
        // });
      }
    }
  }

  void _sendMessage(String text, String username) {
    if (text.isNotEmpty) {
      SocketEvent socketEvent = SocketEvent(
        evnetType: "message",
        message: Message(username: username, text: text),
      );

      _channel?.sink.add(jsonEncode(socketEvent.toJson()));
      state.controller!.clear();
    }
  }

  void _likeOrDislike(String userId) {
    SocketEvent socketEvent = SocketEvent(
        evnetType: "like",
        userId: userId
    );
    _channel?.sink.add(jsonEncode(socketEvent.toJson()));

  }


  void disposeWebSocket() {
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }


  @override
  Future<void> close() {
    disposeWebSocket();
    return super.close();
  }
}

abstract class ChatEvent extends Equatable {}

class SendMessageEvent extends ChatEvent {
  final String text;
  final String userId;

  SendMessageEvent({required this.text,required this.userId});

  @override
  List<Object?> get props => [text];
}

class LikeOrDisLikeEvent extends ChatEvent {
  final String userId;

  LikeOrDisLikeEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class NewChatEvent extends ChatEvent {
  final String roomId;

  NewChatEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}


abstract class ChatState extends Equatable {
  final List<Message>? messages;
  final TextEditingController? controller;
  final bool? isLoading;
  final int? totalLike;
  final bool? isLike;

  ChatState({this.messages, this.controller,this.isLoading,this.totalLike,this.isLike});
}

// ChatState
class ChatChange extends ChatState {
  ChatChange({super.messages, super.controller,super.isLoading,super.totalLike,super.isLike});

  @override
  List<Object?> get props => [messages, controller,isLoading,totalLike,isLike];
}

class ChatInitial extends ChatState {
  ChatInitial() : super(messages: [], controller: TextEditingController(),isLoading: true,totalLike: 0,isLike:false);

  @override
  List<Object?> get props => [messages, controller,isLoading,totalLike,isLike];
}
