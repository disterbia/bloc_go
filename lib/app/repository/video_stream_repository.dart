import 'package:dio/dio.dart';
import 'package:eatall/app/const/addr.dart';
import 'package:eatall/app/model/user_video.dart';
import 'package:eatall/app/model/video_stream.dart';

class VideoStreamRepository {
  final dio = Dio();
  Future<List<UserVideo>> fetchUserVideosFromServer(String userId) async{
    try {
      Response<dynamic> response = await dio.get(
        '${Address.addr}user_videos?user_id=$userId',
      );

      if (response.statusCode == 200) {
        print(response.data);
        return (response.data as List)
            .map((json) => UserVideo.fromJson(json))
            .toList();
      } else if (response.statusCode == 400) {
        print(response.data);
        return [];
      } else {
        throw Exception('Failed to load videos');
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        print(e.response?.data);
      } else {
        print(e);
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<List<VideoStream>> fetchVideosFromServer(
      int page, String? firstVideoUrl) async {
    try {
      Response<dynamic> response = await dio.get(
        '${Address.addr}videos',
        queryParameters: {
          'page': page,
          'first': firstVideoUrl,
        },
      );

      if (response.statusCode == 200) {
        print(response.data);
        return (response.data as List)
            .map((json) => VideoStream.fromJson(json))
            .toList();
      } else if (response.statusCode == 400) {
        print(response.data);
        return [];
      } else {
        throw Exception('Failed to load videos');
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        print(e.response?.data);
      } else {
        print(e);
      }
      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }
}
