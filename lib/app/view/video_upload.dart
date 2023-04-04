import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eatall/app/model/video_object.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class VideoUploadScreen extends StatefulWidget {
  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  List<XFile>? _videos;
  final _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final dio = Dio();

  Future<void> _pickVideos() async {
    final pickedFiles = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFiles != null) {
      setState(() {
        _videos = [pickedFiles];
      });
    }
  }

  // 이 메서드는 사용자가 입력한 동영상 제목과 함께 VideoObject 리스트를 생성합니다.
  List<VideoObject> _createVideoObjects(List<String> titles) {
    List<VideoObject> videoObjects = [];
    for (int i = 0; i < _videos!.length; i++) {
      videoObjects.add(
        VideoObject(
          title: titles[i],
          uploader: '사용자 이름', // 업로더 정보를 적절하게 수정하세요.
          path: _videos![i].path,
        ),
      );
    }
    return videoObjects;
  }

  Future<void> _uploadVideos() async {
    if (_videos == null || _videos!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('동영상을 선택하세요.')),
      );
      return;
    }

    // 여기서 titles를 적절한 값으로 설정하십시오.
    List<String> titles = [_titleController.text, '예제2']; // 동영상 제목을 사용자로부터 입력받아 설정하세요.

    try {

      List<MultipartFile> files = [];
      List<VideoObject> videoObjects = _createVideoObjects(titles);


      for (VideoObject videoObject in videoObjects) {
        final videoFile = File(videoObject.path);
        final file = await MultipartFile.fromFile(videoFile.path, filename: videoFile.path.split('/').last);
        files.add(file);
      }

      final metaDataList = jsonEncode(videoObjects.map((videoObject) => videoObject.toJson()).toList());
      final formData = FormData.fromMap({
        'metadata': metaDataList,
        'files': files,
      });
      final response = await dio.post(
        'http://192.168.0.88:8080/uploads',
        data: formData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동영상 업로드에 성공했습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동영상 업로드에 실패했습니다.')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('동영상 업로드 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('동영상 업로드'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_videos != null)
              Container(
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Image.file(File(_videos![0].path)),
                ),
              ),
              SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '동영상 제목',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                ElevatedButton.icon(
                onPressed: _pickVideos,
                icon: Icon(Icons.video_library),
                label: Text('갤러리에서 선택'),
              ),
              ElevatedButton.icon(
                onPressed: _uploadVideos,
                icon: Icon(Icons.cloud_upload),
                label: Text('동영상 업로드'),
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

