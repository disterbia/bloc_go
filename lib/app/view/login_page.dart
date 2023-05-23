
import 'package:Dtalk/app/bloc/follow_bloc.dart';
import 'package:Dtalk/app/bloc/login_bloc.dart';
import 'package:Dtalk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class LoginPage extends StatefulWidget {

  bool canPop;
  PageController? controller;
  LoginPage(this.canPop,{this.controller});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool enabled=true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(backgroundColor: Colors.white,resizeToAvoidBottomInset: false,
        body: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) async
            {
              if(widget.canPop){
                await context.push("/bridge");
                widget. controller!.jumpToPage(1);
              }else{
                 context.pushReplacement("/bridge");
              }
          },
            listenWhen: (previous, current) => current.isLogin!,
            child: BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return state.isLoading! ?Center(child: CircularProgressIndicator(),):Column(mainAxisAlignment: widget.canPop?MainAxisAlignment.center:MainAxisAlignment.start,
                    children: [
                      !widget.canPop?Column(
                        children: [
                          SizedBox(height: 30,),
                          Container(child: InkWell(onTap:()=> context.pop(),child: Image.asset("assets/img/menu_x.png")),height: 30),
                          SizedBox(height: 40,),
                        ],
                      ):Container(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AbsorbPointer(
                        absorbing: !enabled ,
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
                            onPressed: ()
                            {  setState(() {
                              enabled = false;
                            });
                            Future.delayed(Duration(seconds: 1),  ()=>setState(() {
                              enabled = true;
                            }));

                              context.read<LoginBloc>().add(KakaoLoginEvent());}),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: AbsorbPointer(
                      absorbing: !enabled ,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity,80.h),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Colors.white, // 버튼의 배경색을 흰색으로 설정
                          side: BorderSide(color: Color(0xFFE6E6E6)), // 버튼의 테두리 색을 회색으로 설정
                            elevation: 0
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/img/ic_apple.png', width: 30, height: 30),
                            SizedBox(width: 10), // 이미지와 텍스트 사이에 간격을 추가
                            Text('애플 로그인',style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                          ],
                        ),
                        onPressed: ()
                        {
                        setState(() {
                        enabled = false;
                        });
                        Future.delayed(Duration(seconds: 1),  ()=>setState(() {
                        enabled = true;
                        }));
                          context.read<LoginBloc>().add(AppleLoginEvent());},
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: AbsorbPointer(
                      absorbing: !enabled,
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
                          onPressed: () {
                            setState(() {
                              enabled = false;
                            });
                            Future.delayed(Duration(seconds: 1),  ()=>setState(() {
                              enabled = true;
                            }));
                            context.read<LoginBloc>().add(GoogleLoginEvent());},
                        ),
                    ),
                  ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AbsorbPointer(
                          absorbing: !enabled,
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
                            onPressed: () {
                              setState(() {
                                enabled = false;
                              });
                              Future.delayed(Duration(seconds: 1),  ()=>setState(() {
                                enabled = true;
                              }));
                              context.read<LoginBloc>().add(NaverLoginEvent());},
                          ),
                        ),
                      ),
                ]);
              }
            ),

            ),
      ),
    );
  }
}
