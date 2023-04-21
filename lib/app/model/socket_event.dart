import 'package:eatall/app/model/message.dart';

class SocketEvent {
  final String evnetType;
  final Message? message;
  final int? totalLike;
  final String? userId;

  SocketEvent({required this.evnetType, this.message, this.totalLike,this.userId});

  factory SocketEvent.fromJson(Map<String, dynamic> json) {
    return SocketEvent(
      message:
          json['message'] != null ? Message.fromJson(json['message']) : null,
      evnetType: json['event_type'],
      totalLike: json['total_like'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_type': evnetType,
      'message': message != null ? message!.toJson() : null,
      'user_id': userId
    };
  }
}
