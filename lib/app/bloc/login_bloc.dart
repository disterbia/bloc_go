import 'package:bloc/bloc.dart';
import 'package:DTalk/app/const/addr.dart';
import 'package:DTalk/app/repository/login_repository.dart';
import 'package:DTalk/main.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:DTalk/app/model/user_info.dart' as myUser;

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository loginRepository;

  LoginBloc(this.loginRepository) : super(LoginState(isLogin: false)) {
    on<KakaoLoginEvent>((event, emit) async {
      if (await isKakaoTalkInstalled()) {
        try {
          kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
          String result = await loginRepository.kakaoLogin(token);
          myUser.UserInfo? userInfo = await loginRepository.login(result);

          if (userInfo!=null) {
            await SharedPreferencesHelper.saveUserUid(result); // Save uid
            await SharedPreferencesHelper.saveUserImage(userInfo.image);
            await SharedPreferencesHelper.saveUserNickname(userInfo.nickname);
            UserID.uid=result;
            UserID.userImage=userInfo.image;
            UserID.nickname=userInfo.nickname;
            emit(LoginState(uid: result, isLogin: true));
          } else {
            print("fuck you");
          }
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            kakao.OAuthToken token =
                await kakao.UserApi.instance.loginWithKakaoAccount();
            print('카카오계정으로 로그인 성공');
            String result = await loginRepository.kakaoLogin(token);
            myUser.UserInfo? userInfo = await loginRepository.login(result);

            if (userInfo!=null) {
              await SharedPreferencesHelper.saveUserUid(result); // Save uid
              await SharedPreferencesHelper.saveUserImage(userInfo.image);
              await SharedPreferencesHelper.saveUserNickname(userInfo.nickname);
              UserID.uid=result;
              UserID.userImage=userInfo.image;
              UserID.nickname=userInfo.nickname;
              emit(LoginState(uid: result, isLogin: true));
            } else {
              print("fuck you");
            }
          } catch (error) {
            print('카카오계정으로 로그인 실패 $error');
          }
        }
      } else {
        try {
          kakao.OAuthToken token =
              await kakao.UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          String result = await loginRepository.kakaoLogin(token);
          myUser.UserInfo? userInfo = await loginRepository.login(result);

          if (userInfo!=null) {
            await SharedPreferencesHelper.saveUserUid(result); // Save uid
            await SharedPreferencesHelper.saveUserImage(userInfo.image);
            await SharedPreferencesHelper.saveUserNickname(userInfo.nickname);
            UserID.uid=result;
            UserID.userImage=userInfo.image;
            UserID.nickname=userInfo.nickname;
            emit(LoginState(uid: result, isLogin: true));
          } else {
            print("fuck you");
          }
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    });

    on<AppleLoginEvent>((event, emit) async {
      try {
        final AuthorizationCredentialAppleID credential =
        await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: "DTalk.DTalk.dmonster.com",
            redirectUri: Uri.parse(
              "https://flawless-gem-chestnut.glitch.me/callbacks/sign_in_with_apple",
            ),
          ),
        );
        myUser.UserInfo? userInfo = await loginRepository.login(credential.userIdentifier!);
        if (userInfo!=null) {
          await SharedPreferencesHelper.saveUserUid(credential.userIdentifier!); // Save uid
          await SharedPreferencesHelper.saveUserImage(userInfo.image);
          await SharedPreferencesHelper.saveUserNickname(userInfo.nickname);
          UserID.uid=credential.userIdentifier!;
          UserID.userImage=userInfo.image;
          UserID.nickname=userInfo.nickname;
          emit(LoginState(uid: credential.userIdentifier!, isLogin: true));
        }
      } catch (error) {
        print('error = $error');
      }
    });

    on<GoogleLoginEvent>((event, emit) async {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      UserCredential result= await FirebaseAuth.instance.signInWithCredential(credential);
      myUser.UserInfo? userInfo = await loginRepository.login(result.user!.uid);

      if (userInfo!=null) {
        await SharedPreferencesHelper.saveUserUid(result.user!.uid); // Save uid
        await SharedPreferencesHelper.saveUserImage(userInfo.image);
        await SharedPreferencesHelper.saveUserNickname(userInfo.nickname);
        UserID.uid=result.user!.uid;
        UserID.userImage=userInfo.image;
        UserID.nickname=userInfo.nickname;
        emit(LoginState(uid: result.user!.uid, isLogin: true));
      } else {
        print("fuck you");
      }
    });

    on<NaverLoginEvent>((event, emit) async {
      try {
        await FlutterNaverLogin.logOut();
        final NaverLoginResult result =
        await FlutterNaverLogin.logIn();
        if (result.status == NaverLoginStatus.loggedIn) {
          myUser.UserInfo? userInfo = await loginRepository.login(result.account.id);

          if (userInfo!=null) {
            await SharedPreferencesHelper.saveUserUid(result.account.id); // Save uid
            await SharedPreferencesHelper.saveUserImage(userInfo.image);
            await SharedPreferencesHelper.saveUserNickname(userInfo.nickname);
            UserID.uid=result.account.id;
            UserID.userImage=userInfo.image;
            UserID.nickname=userInfo.nickname;
            emit(LoginState(uid: result.account.id, isLogin: true));
          } else {
            print("fuck you");
          }
        }
      } catch (e) {
        print("-=-=$e");
      }
    });
  }
}

abstract class LoginEvent extends Equatable {}

class KakaoLoginEvent extends LoginEvent {
  @override
  List<Object?> get props => [];
}

class AppleLoginEvent extends LoginEvent {
  @override
  List<Object?> get props => [];
}

class NaverLoginEvent extends LoginEvent {
  @override
  List<Object?> get props => [];
}

class GoogleLoginEvent extends LoginEvent {
  @override
  List<Object?> get props => [];
}

class LoginState extends Equatable {
  final String? uid;
  final bool? isLogin;

  LoginState({this.uid, this.isLogin});

  @override
  List<Object?> get props => [uid,isLogin];
}
