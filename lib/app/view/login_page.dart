
import 'package:DTalk/app/bloc/follow_bloc.dart';
import 'package:DTalk/app/bloc/login_bloc.dart';
import 'package:DTalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class LoginPage extends StatelessWidget {
  bool canPop;
  PageController? controller;
  LoginPage(this.canPop,{this.controller});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) async
          {
            if(canPop){
              await context.push("/bridge");
              controller!.jumpToPage(1);
            }else{
               context.pushReplacement("/bridge");
            }
        },
          listenWhen: (previous, current) => current.isLogin!,
          child:  Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity,80.h),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white, // 버튼의 배경색을 흰색으로 설정
                      side: BorderSide(color: Color(0xFFE6E6E6)), // 버튼의 테두리 색을 회색으로 설정
                      elevation: 0
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/img/ic_kakao.png', width: 30, height: 30),
                        SizedBox(width: 10), // 이미지와 텍스트 사이에 간격을 추가
                        Text('카카오 로그인',style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                      ],
                    ),
                    onPressed: () => context.read<LoginBloc>().add(KakaoLoginEvent())),
              ),
            ),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.white, // 버튼의 배경색을 흰색으로 설정
            //     side: BorderSide(color: Colors.grey), // 버튼의 테두리 색을 회색으로 설정
            //   ),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Image.asset('assets/img/ic_kakao.png', width: 24, height: 24),
            //       SizedBox(width: 8), // 이미지와 텍스트 사이에 간격을 추가
            //       Text('애플',style: TextStyle(color: Colors.black),),
            //     ],
            //   ),
            //   onPressed: () =>
            //       context.read<LoginBloc>().add(AppleLoginEvent()),
            // ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity,80.h),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.white, // 버튼의 배경색을 흰색으로 설정
                      side: BorderSide(color: Color(0xFFE6E6E6)), // 버튼의 테두리 색을 회색으로 설정
                      elevation: 0
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/img/ic_naver.png', width: 30, height: 30),
                      SizedBox(width: 10), // 이미지와 텍스트 사이에 간격을 추가
                      Text('네이버 로그인',style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                    ],
                  ),
                  onPressed: () =>
                      context.read<LoginBloc>().add(NaverLoginEvent()),
                 ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity,80.h),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.white, // 버튼의 배경색을 흰색으로 설정
                      side: BorderSide(color: Color(0xFFE6E6E6)), // 버튼의 테두리 색을 회색으로 설정
                      elevation: 0
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/img/ic_goole.png', width: 30, height: 30),
                      SizedBox(width: 10), // 이미지와 텍스트 사이에 간격을 추가
                      Text('구글 로그인  ',style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                    ],
                  ),
                  onPressed: () =>
                      context.read<LoginBloc>().add(GoogleLoginEvent()),
                ),
            ),
          ]),

          ),
    );
  }
}
