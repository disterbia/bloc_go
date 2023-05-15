import 'package:DTalk/app/model/user_info.dart';
import 'package:dio/dio.dart';
import 'package:DTalk/app/const/addr.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;

class LoginRepository{
  final dio = Dio();

  Future<String> kakaoLogin(kakao.OAuthToken token) async{
      print(token);
      dio.options.headers["authorization"] = "Bearer ${token.accessToken}";

      try {
        kakao.User user = await kakao.UserApi.instance.me();

        print('사용자 정보 요청 성공'
            '\n회원번호: ${user.id}'
            '\n닉네임: ${user.kakaoAccount?.profile?.nickname}');

        final response = await dio.get(
          "https://kapi.kakao.com/v2/user/me",
        );
        final profileInfo = response.data;
        return profileInfo["id"].toString();

      } catch (error) {
        print(error);
        return "";
      }

  }

  Future<UserInfo?> login(String userID) async {
    try {
      final response = await dio.post(
        '${Address.addr}login',
        data: FormData.fromMap({
          'userID': userID,
        }),
      );

      if (response.statusCode == 200) {

        print('Login or registration successful');
        return UserInfo.fromJson(response.data);
      } else {
        print('Login or registration failed');
        return null;
      }
    } catch (e) {
      print('Error occurred during login or registration: $e');
      return null;
    }
  }
}