import 'package:eatall/app/bloc/login_bloc.dart';
import 'package:eatall/app/repository/login_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();

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
