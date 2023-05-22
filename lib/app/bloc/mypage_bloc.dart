
import 'package:Dtalk/app/model/my_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:Dtalk/app/repository/mypage_repository.dart';
import 'package:Dtalk/main.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';



class MyPageBloc extends Bloc<MyPageEvent, MyPageState> {
  final MyPageRepository myPageRepository;

  MyPageBloc({required this.myPageRepository})
      : super(MyPageInitialState()) {
    on<GetMyPageEvent>(_onGetUserProfileEvent);
    on<RemoveMyPageEvent>(_removeMyPage);
  }

  Future<void> _onGetUserProfileEvent(
      GetMyPageEvent event, Emitter<MyPageState> emit) async {
    emit(MyPageLoadingState());
    try {
      MyPage? mypage =
      await myPageRepository.getMyPage(event.userId);
      UserID.nickname=mypage!.nickname;
      UserID.userImage=mypage!.image;
      emit(MyPageLoadedState( mypage: mypage));
    } catch (error) {
      print(error);
    }
  }

  Future<void> _removeMyPage(RemoveMyPageEvent event, Emitter<MyPageState> emit) async{
    try{
      int result=await myPageRepository.removeMyPage(event.userId);
      if(result==200){
        try{
          GoogleSignIn().signOut();
          kakao.UserApi.instance.logout();
          FlutterNaverLogin.logOut();

        }catch(e){
          print(e);
        }
      }
    }catch(e){
      print(e);
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
class RemoveMyPageEvent extends MyPageEvent {
  final String userId;

  RemoveMyPageEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

