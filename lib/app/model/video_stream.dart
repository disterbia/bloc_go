import 'package:eatall/app/model/user_info.dart';

class VideoStream {
  final String title;
  final String uploader;
  final String url;
  final int likeCount;
  final String uploadTime;
  final UserInfo userInfo;

  VideoStream({
    required this.title,
    required this.uploader,
    required this.url,
    required this.uploadTime,
    required this.likeCount,
    required this.userInfo,
  });

  factory VideoStream.fromJson(Map<String, dynamic> json) {
    return VideoStream(
        title: json['title'],
        uploader: json['uploader'],
        url: json['url'],
        uploadTime: json['upload_time'],
        likeCount: json['like_count'],
        userInfo: UserInfo.fromJson(json['user_info']));
  }
}
