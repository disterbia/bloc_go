import 'package:eatall/app/model/user_info.dart';

class VideoStream {
  final String id;
  final String title;
  final String uploader;
  final String url;
  final int likeCount;
  final String uploadTime;
  final bool isNew;
  final UserInfo userInfo;
  final bool userLiked;
  final int chatCount;

  VideoStream({
    required this.id,
    required this.title,
    required this.uploader,
    required this.url,
    required this.uploadTime,
    required this.likeCount,
    required this.userInfo,
    required this.userLiked,
    required this.isNew,
    required this.chatCount
  });

  factory VideoStream.fromJson(Map<String, dynamic> json) {
    return VideoStream(
        id:json['id'],
        title: json['title'],
        uploader: json['uploader'],
        url: json['url'],
        uploadTime: json['upload_time'],
        likeCount: json['like_count'],
        isNew: json['is_new'],
        userLiked: json['user_liked'],
        chatCount: json['chat_count'],
        userInfo: UserInfo.fromJson(json['user_info']));
  }
}
