import 'package:eatall/app/model/user_info.dart';

class UserVideo {
  final String title;
  final String uploader;
  final String url;
  final int likeCount;
  final String uploadTime;
  final String thumbnail;

  UserVideo({
    required this.title,
    required this.uploader,
    required this.url,
    required this.uploadTime,
    required this.likeCount,
    required this.thumbnail,
  });

  factory UserVideo.fromJson(Map<String, dynamic> json) {
    return UserVideo(
        title: json['title'],
        uploader: json['uploader'],
        url: json['url'],
        uploadTime: json['upload_time'],
        likeCount: json['like_count'],
        thumbnail: json['thumbnail'],);
  }
}
