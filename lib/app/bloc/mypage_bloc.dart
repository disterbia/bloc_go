
import 'package:DTalk/app/model/my_page.dart';
import 'package:DTalk/app/model/user_info.dart';
import 'package:DTalk/app/model/user_video.dart';
import 'package:DTalk/app/repository/mypage_repository.dart';
import 'package:DTalk/app/repository/video_stream_repository.dart';
import 'package:DTalk/main.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class MyPageBloc extends Bloc<MyPageEvent, MyPageState> {
  final MyPageRepository myPageRepository;

  MyPageBloc({required this.myPageRepository})
      : super(MyPageInitialState()) {
    on<GetMyPageEvent>(_onGetUserProfileEvent);
  }

  Future<void> _onGetUserProfileEvent(
      GetMyPageEvent event, Emitter<MyPageState> emit) async {
    emit(MyPageLoadingState());
    try {
      MyPage? mypage =
      await myPageRepository.getMyPage(event.userId);
      UserID.nickname=mypage!.nickname;
      UserID.userImage=mypage!.nickname;
      emit(MyPageLoadedState( mypage: mypage));
    } catch (error) {
      print(error);
    }
  }

}

abstract class MyPageState extends Equatable{
  final MyPage? mypage;
  MyPageState({this.mypage});
}

class MyPageInitialState extends MyPageState {
  MyPageInitialState({super.mypage});
  @override
  List<Object?> get props => [mypage];
}

class MyPageLoadingState extends MyPageState {
  MyPageLoadingState({super.mypage});

  @override
  List<Object?> get props => [mypage];
}

class MyPageLoadedState extends MyPageState {
  MyPageLoadedState({super.mypage});

  @override
  List<Object?> get props => [mypage];
}



abstract class MyPageEvent extends Equatable {}

class GetMyPageEvent extends MyPageEvent {
  final String userId;

  GetMyPageEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}