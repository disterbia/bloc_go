
import 'package:Dtalk/app/model/user_video.dart';
import 'package:Dtalk/app/repository/video_stream_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final VideoStreamRepository videoRepository;

  UserProfileBloc({required this.videoRepository})
      : super(UserProfileInitialState([])) {
    on<GetUserProfileVideosEvent>(_onGetUserProfileVideosEvent);
  }

  Future<void> _onGetUserProfileVideosEvent(
      GetUserProfileVideosEvent event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoadingState( []));
    try {
      List<UserVideo> userVideos =
      await videoRepository.fetchUserVideosFromServer(event.creator);
      emit(UserProfileLoadedState( userVideos));
    } catch (error) {
      print(error);
    }
  }

}

abstract class UserProfileState extends Equatable{
  final List<UserVideo>? userVideos;
  UserProfileState(this.userVideos);
}

class UserProfileInitialState extends UserProfileState {
  UserProfileInitialState(super.userVideos);
  @override
  List<Object?> get props => [userVideos];
}

class UserProfileLoadingState extends UserProfileState {
  UserProfileLoadingState(super.userVideos);

  @override
  List<Object?> get props => [userVideos];
}

class UserProfileLoadedState extends UserProfileState {
  UserProfileLoadedState( super.userVideos);

  @override
  List<Object?> get props => [userVideos];
}



abstract class UserProfileEvent extends Equatable {}

class GetUserProfileVideosEvent extends UserProfileEvent {
  final String userId;
  final String creator;

  GetUserProfileVideosEvent({required this.userId,required this.creator});

  @override
  List<Object?> get props => [userId,creator];
}