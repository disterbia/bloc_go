import 'package:dio/dio.dart';
import 'package:Dtalk/app/const/addr.dart';
import 'package:Dtalk/app/model/user_video.dart';
import 'package:Dtalk/app/model/video_stream.dart';
import 'package:Dtalk/main.dart';

class VideoStreamRepository {
  final dio = Dio();
  Future<bool> blockVideo(String blockId) async{
    try{
      Response<dynamic> response = await dio.post(
          '${Address.addr}block',
          data: {
          "userId":UserID.uid,
            "blockId":blockId
      }
      );
      if (response.statusCode == 200) {
        print(response.data);
        return true;
      } else if (response.statusCode == 400) {
        print(response.data);
        return false;
      } else {
        throw Exception('Failed to load videos');
      }
    }on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        print(e.response?.data);
        return false;
      } else {
        print(e);
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
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
      String pageToken, String? firstVideoUrl) async {
    try {
      Response<dynamic> response = await dio.get(
        '${Address.addr}videos',
        queryParameters: {
          'user_id' : UserID.uid,
          'pageToken': pageToken,
          'first': firstVideoUrl??"",
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
