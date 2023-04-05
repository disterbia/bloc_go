import 'package:dio/dio.dart';

class VideoUploadRepository{
  final dio = Dio();

  Future<Response<dynamic>> upload(FormData formData) async {
    var result=await dio.post(
      'http://192.168.0.88:8080/uploads',
      data: formData,
    );
    return result;
  }
}