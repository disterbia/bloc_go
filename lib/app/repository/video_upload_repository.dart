import 'package:dio/dio.dart';
import 'package:eatall/app/const/addr.dart';

class VideoUploadRepository{
  final dio = Dio();

  Future<Response<dynamic>> upload(FormData formData) async {
    var result;
    try{
      result=await dio.post(
        '${Address.addr}uploads',
        data: formData,
      );
      return result;
    }catch(e){
      print(e);
      return result;
    }

  }
}