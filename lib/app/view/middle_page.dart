import 'package:eatall/app/router/custom_go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MiddlePage extends StatelessWidget {
  String id;
  MiddlePage(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
      Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        ElevatedButton(onPressed: ()=>context.push(MyRoutes.VIDEOUPLOAD,extra: id), child: Text("동영상 업로드")),
        ElevatedButton(onPressed: ()=>context.push(MyRoutes.VIDEO,extra: id), child: Text("입장"))
      ])
      ,);
  }
}
