import 'package:dio/dio.dart';
import 'package:Dtalk/app/const/addr.dart';

class VideoUploadRepository{
  final dio = Dio();

  Future<Response<dynamic>> upload(FormData formData) async {
    var result;
    try{
      print('Uploading image...');
      final startTime = DateTime.now();
      result=await dio.post(
        '${Address.addr}uploads',
        data: formData,
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('Image uploaded in ${duration.inMilliseconds} ms');
      return result;
    }catch(e){
      print(e);
      return result;
    }

  }
}