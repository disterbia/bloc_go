import 'dart:convert';
import 'dart:io';

import 'package:DTalk/app/model/follow_info.dart';
import 'package:DTalk/app/model/user_info.dart';
import 'package:DTalk/app/repository/follow_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:DTalk/app/model/object_data.dart';
import 'package:DTalk/app/repository/image_repository.dart';
import 'package:DTalk/main.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {

  final FollowRepository followRepository;

  FollowBloc(this.followRepository) : super(FollowIntial()) {
    on<FollowEvent>((event, emit) async{
      List<FollowInfo> followInfo = await followRepository.getFollowingUsersInfo(event.id);
      emit(FollowInfoState(followInfo: followInfo));
    });
  }
}

abstract class FollowState extends Equatable {
  final List<FollowInfo>? followInfo;

  FollowState({this.followInfo});
}

class FollowIntial extends FollowState{
  FollowIntial({super.followInfo});

  @override
  List<Object?> get props => [followInfo];
}

class FollowInfoState extends FollowState{
  FollowInfoState({super.followInfo});

  @override
  List<Object?> get props => [followInfo];
}
class FollowEvent {
  final String id;

  FollowEvent(this.id);
  // final String pw;
  // ImageUploadEvent(this.id,this.pw);
}