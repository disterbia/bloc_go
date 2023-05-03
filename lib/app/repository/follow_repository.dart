import 'package:DTalk/app/const/addr.dart';
import 'package:DTalk/app/model/follow_info.dart';
import 'package:dio/dio.dart';

class FollowRepository {
  final Dio _dio = Dio();

  Future<List<FollowInfo>> getFollowingUsersInfo(String userId) async {
    final url = '${Address.addr}follow?user_id=$userId';
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => FollowInfo.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load following users info.');
    }
  }
}