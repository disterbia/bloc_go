import 'package:eatall/app/bloc/spalsh_bloc.dart';
import 'package:eatall/app/bloc/video_stream_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {

  bool isFirst=true;
  @override
  Widget build(BuildContext context) {
    if(isFirst) {
      isFirst=false;
      context.read<VideoStreamBloc>().add(LoadVideoEvent());
    }
    return Scaffold(
      body: BlocListener<SplashBloc,bool>(
        listenWhen: (previous, current) => current,
        listener: (context,state) {
          context.pushReplacement("/login");
        },
        child:Center(
      child: Image.asset("assets/product_img2.jpeg"),
    ),
      ),);
  }
}
