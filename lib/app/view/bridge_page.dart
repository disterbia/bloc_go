import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BridgePage extends StatelessWidget {
  const BridgePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Center(child: Text("로그인 완료! 못했던것들을 해보세요!")),
              Text("이러이러한 앱이에요!"),
              ElevatedButton(onPressed: (){
                context.pop();
              }, child: Text("권한받기"))
    ]),);
  }
}
