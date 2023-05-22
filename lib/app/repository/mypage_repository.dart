import 'package:dio/dio.dart';
import 'package:Dtalk/app/const/addr.dart';
import 'package:Dtalk/app/model/my_page.dart';
import 'package:Dtalk/app/model/user_info.dart';

class MyPageRepository{
  final dio = Dio();
 Future<int> removeMyPage(String userId) async{
   try {
     Response<dynamic> response = await dio.post(
       '${Address.addr}remove?user_id=$userId',
     );

     if (response.statusCode == 200) {
       print(response.data);
       return 200;
     } else if (response.statusCode == 400) {
       print(response.data);
       return -1;
     } else {
       throw Exception('Failed to load videos');
     }
   } on DioError catch (e) {
     if (e.type == DioErrorType.response) {
       print(e.response?.data);
     } else {
       print(e);
     }
     return -2;
   } catch (e) {
     print(e);
     return -3;
   }
 }
  Future<MyPage?> getMyPage(String userId) async{
    try {
      Response<dynamic> response = await dio.get(
        '${Address.addr}mypage?user_id=$userId',
      );

      if (response.statusCode == 200) {
        print(response.data);
        return  MyPage.fromJson(response.data);
      } else if (response.statusCode == 400) {
        print(response.data);
        return null;
      } else {
        throw Exception('Failed to load videos');
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.response) {
        print(e.response?.data);
      } else {
        print(e);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}