import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eatall/app/bloc/login_bloc.dart';
import 'package:eatall/app/repository/login_repository.dart';
import 'package:eatall/app/widget/apple_sigin_button.dart';
import 'package:eatall/app/widget/google_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_navi.dart';

class LoginPage extends StatelessWidget {

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  Dio dio = Dio();

  Future<String> _get_user_info(kakao.OAuthToken token) async {
    print(token);
    dio.options.headers["authorization"] = "Bearer ${token.accessToken}";
    try {
      kakao.User user = await kakao.UserApi.instance.me();

      print('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}');

      final response = await dio.get(
        "https://kapi.kakao.com/v2/user/me",
      );
      final profileInfo = response.data;
      return profileInfo["id"].toString();



    } catch (error) {
      print(error);
      return "";
      print('사용자 정보 요청 실패 $error');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<bool> login(String userID) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'http://192.168.0.88:8080/login',
        data: FormData.fromMap({
          'userID': userID,
        }),
      );

      if (response.statusCode == 200) {
        print('Login or registration successful');
        return true;
      } else {
        print('Login or registration failed');
        return false;
      }
    } catch (e) {
      print('Error occurred during login or registration: $e');
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              "assets/product_img2.jpeg",
              fit: BoxFit.fitWidth,
              height: 200,
              width: double.infinity,
            ),
          ),
          TextFormField(
            controller: idController,
          ),
          TextFormField(
            controller: pwController,
          ),
          Container(
              color: Colors.white,
              child: Center(
                  child: ElevatedButton(
                      child: Text("카카오 로그인"),
                      onPressed: () async {
                        if (await isKakaoTalkInstalled()) {
                          try {
                            kakao.OAuthToken token=await kakao.UserApi.instance.loginWithKakaoTalk();
                            print('카카오톡으로 로그인 성공');
                            String result =await _get_user_info(token);
                            bool temp = await login(result);
                            if(temp){
                              context.push("/video",extra: result);
                            }else{
                              print("fuck you");
                            }

                          } catch (error) {
                            print('카카오톡으로 로그인 실패 $error');
                            // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
                            try {
                              kakao.OAuthToken token=await kakao.UserApi.instance.loginWithKakaoAccount();
                              print('카카오계정으로 로그인 성공');
                              String result =await _get_user_info(token);
                              bool temp = await login(result);
                              if(temp){
                                context.push("/video",extra: result);
                              }else{
                                print("fuck you");
                              }
                            } catch (error) {
                              print('카카오계정으로 로그인 실패 $error');
                            }
                          }
                        } else {
                          try {
                            kakao.OAuthToken token= await kakao.UserApi.instance.loginWithKakaoAccount();
                            print('카카오계정으로 로그인 성공');
                            String result =await _get_user_info(token);
                            bool temp = await login(result);
                            if(temp){
                              context.push("/video",extra: result);
                            }else{
                              print("fuck you");
                            }
                          } catch (error) {
                            print('카카오계정으로 로그인 실패 $error');
                          }
                        }
                      }
                  )
              )
          ),
          AppleSignInButton(),
          ElevatedButton(onPressed: ()async{
            try{
              FlutterNaverLogin.logOut();
              final NaverLoginResult result = await FlutterNaverLogin.logIn();
              if (result.status == NaverLoginStatus.loggedIn) {
                bool temp = await login(result.account.id);
                if(temp){
                  context.push("/video",extra: result.account.id);
                }else{
                  print("fuck you");
                }
              }
            }catch(e){
              print("-=-=$e");
            }

          }, child: Text("naver")),
          ElevatedButton(onPressed: ()async{
            UserCredential result=  await signInWithGoogle();
            bool temp = await login(result.user!.uid);
            if(temp){
              context.push("/video",extra: result.user!.uid);
            }else{
              print("fuck you");
            }

          }, child: Text("google")),
          ElevatedButton(
              onPressed: () =>
                  context.read<LoginBloc>().add(LoginEvent(idController.text,pwController.text)),
              child: Text("로그인")),
        ]),
      ),
    );
  }
}
