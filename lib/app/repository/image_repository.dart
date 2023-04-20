import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eatall/app/const/addr.dart';
import 'package:eatall/app/model/object_data.dart';

class ImageRepository{
  Future<String> uploadObjects(List<ObjectData> objects) async {
    try {
      final dio = Dio();
      final data = jsonEncode(objects.map((obj) => obj.toJson()).toList());
      print('Uploading image...');
      final startTime = DateTime.now();
      final response = await dio.post(
        '${Address.addr}multiupload',
        data: data,
        options: Options(contentType: 'application/json'),
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('Image uploaded in ${duration.inMilliseconds} ms');
      return response.data["image_url"];

    } catch (e) {
      print(e);
      return "";

    }
  }
}


