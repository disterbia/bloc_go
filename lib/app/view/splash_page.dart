import 'package:eatall/app/bloc/spalsh_bloc.dart';
import 'package:eatall/app/bloc/video_stream_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VideoStreamBloc>().add(LoadVideoEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, bool>(
        listenWhen: (previous, current) => current,
        listener: (context, state) {
          context.pushReplacement("/home");
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/product_img2.jpeg"),
            Text(
              "스플래쉬 화면",
              style: TextStyle(fontSize: 30),
            )
          ],
        ),
      ),
    );
  }
}
