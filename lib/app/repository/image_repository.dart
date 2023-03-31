import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eatall/app/model/object_data.dart';

class ImageRepository{
  Future<void> uploadObjects(List<ObjectData> objects) async {
    try {
      final dio = Dio();
      final data = jsonEncode(objects.map((obj) => obj.toJson()).toList());
      final response = await dio.post(
        'http://192.168.0.21:8080/multiupload',
        data: data,
        options: Options(contentType: 'application/json'),
      );
      print(response.data);
    } catch (e) {
      print(e);
    }
  }
}


