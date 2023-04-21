import 'package:eatall/app/model/user_info.dart';

class UserVideo {
  final String id;
  final String title;
  final String uploader;
  final String url;
  final int likeCount;
  final String uploadTime;
  final String thumbnail;
  final bool userLiked;
  final int chatCount;

  UserVideo({
    required this.id,
    required this.title,
    required this.uploader,
    required this.url,
    required this.uploadTime,
    required this.likeCount,
    required this.thumbnail,
    required this.userLiked,
    required this.chatCount,
  });

  factory UserVideo.fromJson(Map<String, dynamic> json) {
    return UserVideo(
        id: json['id'],
        title: json['title'],
        uploader: json['uploader'],
        url: json['url'],
        uploadTime: json['upload_time'],
        likeCount: json['like_count'],
        thumbnail: json['thumbnail'],
        userLiked: json['user_liked'],
        chatCount: json['chat_count']
    );
  }
}
