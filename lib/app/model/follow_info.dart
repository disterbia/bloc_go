import 'package:DTalk/app/model/user_info.dart';

class FollowInfo {
  final int followingCount;
  final int followerCount;
  final int totalLike;
  final UserInfo userInfo;


  FollowInfo({
    required this.followingCount,
    required this.followerCount,
    required this.totalLike,
    required this.userInfo,
  });

  factory FollowInfo.fromJson(Map<String, dynamic> json) {
    return FollowInfo(
        followingCount:json['following_count'],
        totalLike: json['total_likes'],
        followerCount: json['follower_count'],
        userInfo: UserInfo.fromJson(json['user_info']));
  }
}
