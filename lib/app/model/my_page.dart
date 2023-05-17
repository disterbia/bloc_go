
import 'package:Dtalk/app/model/user_video.dart';

class MyPage {
  final String id;
  final String image;
  final String nickname;
  final String intro;
  final List<UserVideo> videos;

  MyPage({required this.id, required this.image,required this.videos,required this.intro,required this.nickname});

  factory MyPage.fromJson(Map<String, dynamic> json) {
    List<dynamic>? videoList = json['videos'] as List<dynamic>?;
    List<UserVideo> videos = [];

    if (videoList != null) {
      videos = videoList.map((video) => UserVideo.fromJson(video)).toList();
    }
    return MyPage(id: json['id'], image: json['image'],videos: videos,intro: json['introduction'],nickname: json['nickname']);
  }
}
