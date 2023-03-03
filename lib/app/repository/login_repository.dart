import 'package:dio/dio.dart';

class LoginRepository{
  final dio = Dio();

  Future<int> request(String id,String pw) async {
    Response response = await dio.post('http://10.0.2.2:8080/login',data: {"id":id,"pw":pw});
    print("========${response.data}");
    return response.data;
  }
}