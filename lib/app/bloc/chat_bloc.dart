import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:eatall/app/const/addr.dart';
import 'package:eatall/app/model/message.dart';
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
    on<NewChatEvent>((event, emit) async{
      await connectWebSocket(emit, event.roomId);
    });

  }

  void clearMessages(Emitter<ChatState> emit) async {
    emit(ChatChange(messages: [], controller: state.controller,isLoading: true));
  }

  Future<void> connectWebSocket(Emitter<ChatState> emit, String roomId) async {
    if(curruntVideo != roomId){
      curruntVideo=roomId;
      disposeWebSocket();
      _channel = IOWebSocketChannel.connect('${Address.wsAddr}ws?roomId=$roomId');
      clearMessages(emit);
      //_channel!.stream.listen((event)
      await for(final event in _channel!.stream) {
        Map<String, dynamic> messageData = jsonDecode(event);
        List<Message> messages = List<Message>.from(state.messages!)
          ..add(Message.fromJson(messageData));
        emit(ChatChange(messages: messages, controller: state.controller,isLoading: false));
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //
        // });
      }
    }

  }

  void disposeWebSocket() {
    if (_channel != null) {
      _channel?.sink.close();
      _channel = null;
    }
  }

  void _sendMessage(String text,String username) {
    if (text.isNotEmpty) {
      _channel?.sink.add(jsonEncode({"username": username, "text": text}));
      state.controller!.clear();
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

  ChatState({this.messages, this.controller,this.isLoading});
}

// ChatState
class ChatChange extends ChatState {
  ChatChange({super.messages, super.controller,super.isLoading});

  @override
  List<Object?> get props => [messages, controller,isLoading];
}

class ChatInitial extends ChatState {
  ChatInitial() : super(messages: [], controller: TextEditingController(),isLoading: true);

  @override
  List<Object?> get props => [messages, controller,isLoading];
}
