import 'package:DTalk/app/bloc/chat_bloc.dart';
import 'package:DTalk/app/bloc/spalsh_bloc.dart';
import 'package:DTalk/app/bloc/video_stream_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class VideoAspectRatio{
  static double? aspectRatio;
  static double? aspectRatio2;
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VideoStreamBloc>().add(LoadVideoEvent());
    context.read<ChatBloc>().add(InitialChatEvent());
  }

  @override
  Widget build(BuildContext context) {
    VideoAspectRatio.aspectRatio = MediaQuery.of(context).size.width/( MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top-kBottomNavigationBarHeight );
    VideoAspectRatio.aspectRatio2 = MediaQuery.of(context).size.width/( MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top);
    return Scaffold(
      body: BlocListener<SplashBloc, bool>(
        listenWhen: (previous, current) => current,
        listener: (context, state) {
          context.pushReplacement("/home");
        },
        child: Center(child: Image.asset("assets/logo.png",height: 40.h,)),
      ),
    );
  }
}
