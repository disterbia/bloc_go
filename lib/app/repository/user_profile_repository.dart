import 'package:DTalk/app/const/addr.dart';
import 'package:dio/dio.dart';
import 'package:dio/src/form_data.dart'; // Import FormData

class UserService {
  final Dio _dio = Dio();

  Future<bool> updateUser(String userId, String nickname, String introduction) async {
    try {
      FormData formData = FormData.fromMap({
        'nickname': nickname,
        'intro': introduction,
      });

      final response = await _dio.post(
        '${Address.addr}update?user_id=$userId',
        data: formData, // Use FormData here
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }
}
