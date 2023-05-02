import 'package:DTalk/app/const/addr.dart';
import 'package:dio/dio.dart';

class FollowRepository {
  final Dio _dio = Dio();

  Future<void> toggleFollow(String userId, String creatorId) async {
    try {
      final response = await _dio.post(
        '${Address.addr}follow', // 서버 URL을 입력해주세요.
        data: FormData.fromMap({
          'user_id': userId,
          'creator': creatorId,
        }),
      );

      if (response.statusCode == 200) {
        print('Toggle follow success');
      } else {
        print('Toggle follow failed');
      }
    } on DioError catch (e) {
      print('Error occurred: $e');
    }
  }
}