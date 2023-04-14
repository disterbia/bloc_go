
import 'package:eatall/app/bloc/login_bloc.dart';
import 'package:eatall/app/repository/login_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) =>
            context.pushReplacement("/home"),
        listenWhen: (previous, current) => current.isLogin!,
        child:  Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Center(
            child: ElevatedButton(
                child: Text("카카오 로그인"),
                onPressed: () => context.read<LoginBloc>().add(KakaoLoginEvent())),
          ),
          ElevatedButton(
            onPressed: () =>
                context.read<LoginBloc>().add(AppleLoginEvent()),
            child: Text("애플 로그인"),
          ),
          ElevatedButton(
              onPressed: () =>
                  context.read<LoginBloc>().add(NaverLoginEvent()),
              child: Text("네이버 로그인")),
          ElevatedButton(
              onPressed: () =>
                  context.read<LoginBloc>().add(GoogleLoginEvent()),
              child: Text("구글로그인")),
        ]),

        );
  }
}
