import 'package:dio/dio.dart';
import 'package:eatall/app/const/addr.dart';

class VideoStreamRepository{
  final dio = Dio();

  Future<List<String>> fetchVideosFromServer(int page) async {
    var response;
    try{
       response = await dio.get(
        '${Address.addr}videos?page=$page',
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else if (response.statusCode == 400){
          return [];
      }else throw Exception('Failed to load videos');
    }catch(e){
      print(e);
      return [];
    }
  }

}