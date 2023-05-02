import 'dart:convert';
import 'dart:io';

import 'package:DTalk/app/repository/follow_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:DTalk/app/model/object_data.dart';
import 'package:DTalk/app/repository/image_repository.dart';
import 'package:DTalk/main.dart';
import 'package:image_picker/image_picker.dart';

class FollowBloc extends Bloc<FollowEvent, bool> {

  final FollowRepository followRepository;

  FollowBloc(this.followRepository) : super(false) {
    on<FollowEvent>((event, emit) async{

    });
  }
}

class FollowEvent {
  // final String id;
  // final String pw;
  // ImageUploadEvent(this.id,this.pw);
}