import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:eatall/app/const/addr.dart';
import 'package:eatall/app/model/chat_room_state.dart';
import 'package:eatall/app/model/message.dart';
import 'package:eatall/app/model/socket_event.dart';
import 'package:eatall/app/model/video_stream.dart';
import 'package:eatall/app/repository/video_stream_repository.dart';
import 'package:eatall/main.dart';
import 'package:equatable/equatable.dart';
import 'package:web_socket_channel/io.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final VideoStreamRepository repository;
  Map<String, IOWebSocketChannel> _channels = {};
  String? currentVideo;


  ChatBloc(this.repository) : super(ChatInitial(chatRoomStates: {})) {
    on<SendMessageEvent>((event, emit) {
      _sendMessage(event.roomId,event.text, event.userId);
    });
    on<LikeOrDisLikeEvent>((event, emit) {
      _likeOrDislike(event.roomId,event.userId);
    });
    on<FirstChangeEvent>((event, emit) {
      emit(FirstChange(chatRoomStates: state.chatRoomStates..[event.roomId] = event.chatRoomState));
      emit(ChangeBridge(chatRoomStates: state.chatRoomStates..[event.roomId] = event.chatRoomState));
    });
    on<InitialChatEvent>((event, emit) {
      initialLoad();
    });
    on<ChatChangeEvent>((event, emit) async {
      emit(ChangeBridge(chatRoomStates: state.chatRoomStates..[event.roomId] = event.chatRoomState));
      emit(ChatChange(chatRoomStates: state.chatRoomStates..[event.roomId] = event.chatRoomState));

    });
    on<LikeChangeEvent>((event, emit) {
      emit(ChangeBridge(chatRoomStates: state.chatRoomStates..[event.roomId] = event.chatRoomState));
      emit(LikeChange(chatRoomStates: state.chatRoomStates..[event.roomId] = event.chatRoomState));
    });
    on<ChangeRoomEvent>((event, emit) {
      changeRoom(emit, event.removeRoomId, event.newRoomId);
    });

    on<ResetAnimationEvent>((event, emit) {
      _resetAnimation(emit,event.roomId);
    });

  }

  Future<void> initialLoad() async{
    List<VideoStream> temp = await repository.fetchVideosFromServer(0, null);
    if (temp.isEmpty) {
      return;
    }
    connectWebSocket(temp[0].id);
    connectWebSocket(temp[1].id);
  }

  void _resetAnimation(Emitter<ChatState> emit ,String roomId) {
    ChatRoomState chatRoomState = state.chatRoomStates[roomId]!;
    ChatRoomState updatedChatRoomState = chatRoomState.copyWith(animate: false);
    emit(ChangeBridge(chatRoomStates: state.chatRoomStates..[roomId] = updatedChatRoomState));
  }

  void connectWebSocket(String roomId)  {

      if (_channels.containsKey(roomId)) {
        _channels[roomId]?.sink.close();
        _channels.remove(roomId);
      }

      IOWebSocketChannel channel =
      IOWebSocketChannel.connect('${Address.wsAddr}ws?room_id=$roomId&user_id=${UserID.uid}');
      _channels[roomId] = channel;

      if (!state.chatRoomStates.containsKey(roomId)) {
        state.chatRoomStates[roomId] = ChatRoomState.initial();
        print("-==--=-=-=-=-=-=init ${state.chatRoomStates[roomId]!.totalLike}");
      }
      // await for(final event in _channel!.stream)
      List<Message> messages=[];
      channel.stream.listen((event) {
        Map<String, dynamic> eventData = jsonDecode(event);
        SocketEvent socketEvent = SocketEvent.fromJson(eventData);
        ChatRoomState chatRoomState = state.chatRoomStates[roomId]!;

        if (socketEvent.eventType == "first_message") {
          print("-==--=-=-=-=-=-=message");
          messages.addAll(socketEvent.firstMessage!);
          ChatRoomState updatedChatRoomState = chatRoomState.copyWith(messages: messages);
          add(FirstChangeEvent(updatedChatRoomState, roomId));
          print("-==--=-=-=-=-=-=emitmessage");
        } else if (socketEvent.eventType == "first_like") {
          ChatRoomState updatedChatRoomState;
          if (socketEvent.userId == UserID.uid) {
            updatedChatRoomState = chatRoomState.copyWith(
              totalLike: socketEvent.totalLike,
              isLike: socketEvent.userLike,
            );
          } else {
            updatedChatRoomState = chatRoomState.copyWith(
              totalLike: socketEvent.totalLike,
            );
          }
          add(FirstChangeEvent(updatedChatRoomState, roomId));
        }
        else if (socketEvent.eventType == "message") {
          List<Message> messages = List<Message>.from(chatRoomState.messages)
            ..add(socketEvent.message!);

          ChatRoomState updatedChatRoomState = chatRoomState.copyWith(messages: messages,roomId: roomId,animate: true);
          add(ChatChangeEvent(updatedChatRoomState, roomId));
        } else if (socketEvent.eventType == "total_like") {
          print("-==--=-=-=-=-=-=like");
          ChatRoomState updatedChatRoomState;
          if (socketEvent.userId == UserID.uid) {
            updatedChatRoomState = chatRoomState.copyWith(totalLike: socketEvent.totalLike, isLike: socketEvent.userLike, roomId: roomId, animate: true);
          } else {
            updatedChatRoomState = chatRoomState.copyWith(totalLike: socketEvent.totalLike, roomId: roomId,animate:true);
          }
          add(LikeChangeEvent(updatedChatRoomState, roomId));
          print("-==--=-=-=-=-=-=emitlike");
        }
      });

  }

  void changeRoom(Emitter<ChatState> emit,String removeRoomId,String newRoomId){
    if(newRoomId=="") {
      disposeWebSocket(removeRoomId);
      emit(ChangeBridge(chatRoomStates: state.chatRoomStates..[removeRoomId] = ChatRoomState.initial()));
    } else if(removeRoomId=="") {
      connectWebSocket( newRoomId);
      emit(ChangeBridge(chatRoomStates: state.chatRoomStates..[newRoomId] = ChatRoomState.initial()));
    } else{
      disposeWebSocket(removeRoomId);
      connectWebSocket( newRoomId);
    }

  }

  void _sendMessage(String roomId, String text, String username) {
    if(UserID.uid==null) return;
    if (text.isNotEmpty) {
      SocketEvent socketEvent = SocketEvent(
        eventType: "message",
        message: Message(username: username, text: text),
      );

      _channels[roomId]?.sink.add(jsonEncode(socketEvent.toJson()));
      state.chatRoomStates[roomId]?.controller.clear();
    }
  }

  void _likeOrDislike(String roomId, String userId) {
    if(UserID.uid==null) return;
    SocketEvent socketEvent = SocketEvent(
      eventType: "like",
      userId: userId,
    );

    _channels[roomId]?.sink.add(jsonEncode(socketEvent.toJson()));
  }


  void disposeWebSocket(String roomId) {
    if (_channels.containsKey(roomId)) {
      _channels[roomId]?.sink.close();
      _channels.remove(roomId);
    }
  }


  @override
  Future<void> close() {
    _channels.forEach((roomId, channel) {
      channel.sink.close();
    });
    _channels.clear();
    return super.close();
  }
}


abstract class ChatEvent extends Equatable {}

class SendMessageEvent extends ChatEvent {
  final String roomId;
  final String text;
  final String userId;

  SendMessageEvent({required this.roomId,required this.text,required this.userId});

  @override
  List<Object?> get props => [roomId,text,userId];
}

class LikeOrDisLikeEvent extends ChatEvent {
  final String userId;
  final String roomId;

  LikeOrDisLikeEvent({required this.userId, required this.roomId});

  @override
  List<Object?> get props => [roomId,userId];
}

class InitialChatEvent extends ChatEvent {

  InitialChatEvent();

  @override
  List<Object?> get props => [];
}


class ChatChangeEvent extends ChatEvent {

  final ChatRoomState chatRoomState;
  final String roomId;

  ChatChangeEvent(this.chatRoomState,this.roomId);

  @override
  List<Object?> get props => [chatRoomState,roomId];
}

class LikeChangeEvent extends ChatEvent {

  final ChatRoomState chatRoomState;
  final String roomId;

  LikeChangeEvent(this.chatRoomState,this.roomId);

  @override
  List<Object?> get props => [chatRoomState,roomId];
}

class FirstChangeEvent extends ChatEvent {

  final ChatRoomState chatRoomState;
  final String roomId;

  FirstChangeEvent(this.chatRoomState,this.roomId);

  @override
  List<Object?> get props => [chatRoomState,roomId];
}


class ChangeRoomEvent extends ChatEvent {

  final String newRoomId;
  final String removeRoomId;

  ChangeRoomEvent({required this.newRoomId, required this.removeRoomId});

  @override
  List<Object?> get props => [newRoomId,removeRoomId];
}

class ChangeBridgeEvent extends ChatEvent {
  ChangeBridgeEvent();

  @override
  List<Object?> get props => [];
}

class ResetAnimationEvent extends ChatEvent {
  final String roomId;

  ResetAnimationEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

abstract class ChatState extends Equatable {
  final Map<String, ChatRoomState> chatRoomStates;

  ChatState({required this.chatRoomStates});
}


class FirstChange extends ChatState {
  FirstChange({required super.chatRoomStates});

  @override
  List<Object?> get props => [chatRoomStates];
}

class ChatChange extends ChatState {
  ChatChange({required super.chatRoomStates});

  @override
  List<Object?> get props => [chatRoomStates];
}

class LikeChange extends ChatState {
  LikeChange({required super.chatRoomStates});

  @override
  List<Object?> get props => [chatRoomStates];
}

class ChangeBridge extends ChatState {
  ChangeBridge({required super.chatRoomStates});

  @override
  List<Object?> get props => [chatRoomStates];
}


class ChatInitial extends ChatState {
  ChatInitial({required super.chatRoomStates});

  @override
  List<Object?> get props => [chatRoomStates];
}


