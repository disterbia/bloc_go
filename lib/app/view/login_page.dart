import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eatall/app/bloc/login_bloc.dart';
import 'package:eatall/app/repository/login_repository.dart';
import 'package:eatall/app/widget/apple_sigin_button.dart';
import 'package:eatall/app/widget/google_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_navi.dart';

class LoginPage extends StatelessWidget {

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  Dio dio = Dio();

  void _get_user_info(OAuthToken token) async {
    print(token);
    dio.options.headers["authorization"] = "Bearer ${token.accessToken}";
    try {
      User user = await UserApi.instance.me();

      print('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}');

      final response = await dio.get(
        "https://kapi.kakao.com/v2/user/me",
      );
      final profileInfo = response.data;
      print(profileInfo);


    } catch (error) {
      print('사용자 정보 요청 실패 $error');
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
                            OAuthToken token=await UserApi.instance.loginWithKakaoTalk();
                            print('카카오톡으로 로그인 성공');
                            _get_user_info(token);
                          } catch (error) {
                            print('카카오톡으로 로그인 실패 $error');
                            // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
                            try {
                              OAuthToken token=await UserApi.instance.loginWithKakaoAccount();
                              print('카카오계정으로 로그인 성공');
                              _get_user_info(token);
                            } catch (error) {
                              print('카카오계정으로 로그인 실패 $error');
                            }
                          }
                        } else {
                          try {
                            OAuthToken token= await UserApi.instance.loginWithKakaoAccount();
                            print('카카오계정으로 로그인 성공');
                            _get_user_info(token);
                          } catch (error) {
                            print('카카오계정으로 로그인 실패 $error');
                          }
                        }
                      }
                  )
              )
          ),
          AppleSignInButton(),
          // GoogleSignInButton(onSignIn: (value) {
          //
          // },),
          ElevatedButton(onPressed: ()async{
            try{
              final NaverLoginResult result = await FlutterNaverLogin.logIn();

              if (result.status == NaverLoginStatus.loggedIn) {
                print('accessToken = ${result.accessToken}');
                print('id = ${result.account.id}');
                print('email = ${result.account.email}');
                print('name = ${result.account.name}');

              }
            }catch(e){
              print("-=-=$e");
            }

          }, child: Text("naver")),
          ElevatedButton(onPressed: (){
            context.push("/upload");
          }, child: Text("google")),
          ElevatedButton(
              onPressed: () =>
                  context.read<LoginBloc>().add(LoginEvent(idController.text,pwController.text)),
              child: Text("로그인")),
          Row(
            children: [Text("아이디 찾기"), Text("비밀번호 재설정")],
          )
        ]),
      ),
    );
  }
}
