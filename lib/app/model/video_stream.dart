import 'package:Dtalk/app/model/user_info.dart';

class VideoStream {
  final String id;
  final String title;
  final String uploader;
  final String url;
  final String uploadTime;
  final bool isNew;
  final UserInfo userInfo;

  VideoStream({
    required this.id,
    required this.title,
    required this.uploader,
    required this.url,
    required this.uploadTime,
    required this.userInfo,
    required this.isNew,
  });

  factory VideoStream.fromJson(Map<String, dynamic> json) {
    return VideoStream(
        id:json['id'],
        title: json['title'],
        uploader: json['uploader'],
        url: json['url'],
        uploadTime: json['upload_time'],
        isNew: json['is_new'],
        userInfo: UserInfo.fromJson(json['user_info']));
  }
}
