import 'package:Dtalk/app/model/user_info.dart';

class UserVideo {
  final String id;
  final String title;
  final String uploader;
  final String url;
  final String uploadTime;
  final String thumbnail;

  UserVideo({
    required this.id,
    required this.title,
    required this.uploader,
    required this.url,
    required this.uploadTime,
    required this.thumbnail,

  });

  factory UserVideo.fromJson(Map<String, dynamic> json) {
    return UserVideo(
        id: json['id'],
        title: json['title'],
        uploader: json['uploader'],
        url: json['url'],
        uploadTime: json['upload_time'],
        thumbnail: json['thumbnail'],
    );
  }
}
