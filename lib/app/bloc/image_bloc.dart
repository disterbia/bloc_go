import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:eatall/app/model/object_data.dart';
import 'package:eatall/app/repository/image_repository.dart';
import 'package:image_picker/image_picker.dart';

class ImageBloc extends Bloc<ImageUploadEvent, String> {

  final ImageRepository imageRepository;

  ImageBloc(this.imageRepository) : super("") {
    on<ImageUploadEvent>((event, emit) async{
      final picker = ImagePicker();
      List<ObjectData> objects = [];
        final pickedFiles = await picker.pickMultiImage();
        if (pickedFiles != null) {
          final objectData = ObjectData(
            title: 'Object Title',
            description: 'Object Description',
            imageFiles: [],
          );
          for (final pickedFile in pickedFiles) {
            final bytes = File(pickedFile.path).readAsBytesSync();
            final encoded = base64Encode(bytes);
            objectData.imageFiles.add(encoded);
          }
          objects.add(objectData);
          imageRepository.uploadObjects(objects);
        }

    });
  }
}
class ImageUploadEvent {
  // final String id;
  // final String pw;
  // ImageUploadEvent(this.id,this.pw);
}