import 'package:eatall/app/model/message.dart';

class SocketEvent {
  final String eventType;
  final Message? message;
  final int? totalLike;
  final bool? userLike;
  final String? userId;

  SocketEvent({required this.eventType, this.message, this.totalLike,this.userId,this.userLike});

  factory SocketEvent.fromJson(Map<String, dynamic> json) {
    return SocketEvent(
      message:
          json['message'] != null ? Message.fromJson(json['message']) : null,
      eventType: json['event_type'],
      totalLike: json['total_like'],
      userId: json['user_id'],
      userLike: json['user_like'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType,
      'message': message != null ? message!.toJson() : null,
      'user_id': userId
    };
  }
}
