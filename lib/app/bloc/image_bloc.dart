import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:eatall/app/model/object_data.dart';
import 'package:eatall/app/repository/image_repository.dart';
import 'package:eatall/main.dart';
import 'package:image_picker/image_picker.dart';

class ImageBloc extends Bloc<ImageUploadEvent, String> {

  final ImageRepository imageRepository;

  ImageBloc(this.imageRepository) : super("") {
    on<ImageUploadEvent>((event, emit) async{
      final picker = ImagePicker();
      List<ObjectData> objects = [];
        final pickedFiles = await picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          final objectData = ObjectData(
              userId: UserID.uid!,
              imageFiles: [],
          );
          for (final pickedFile in pickedFiles) {
            final bytes = File(pickedFile.path).readAsBytesSync();
            final encoded = base64Encode(bytes);
            print('Encoded image size: ${encoded.length} bytes');
            objectData.imageFiles.add(encoded);
          }
          objects.add(objectData);

          String response=await imageRepository.uploadObjects(objects);
          emit(response);
        }

    });
  }
}
class ImageUploadEvent {
  // final String id;
  // final String pw;
  // ImageUploadEvent(this.id,this.pw);
}