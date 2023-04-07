import 'package:eatall/app/bloc/image_bloc.dart';
import 'package:eatall/app/bloc/login_bloc.dart';
import 'package:eatall/app/repository/image_repository.dart';
import 'package:eatall/app/repository/login_repository.dart';
import 'package:eatall/app/view/middle_page.dart';
import 'package:eatall/app/view/splash_page.dart';
import 'package:eatall/app/view/login_page.dart';
import 'package:eatall/app/view/upload_page.dart';
import 'package:eatall/app/view/video_upload.dart';
import 'package:eatall/app/view/videostream.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyRoutes {
  static const SPLASH = '/';
  static const Login = '/login';
  static const UPLOAD = '/upload';
  static const VIDEO = '/video';
  static const MIDDLE = '/middle';
  static const VIDEOUPLOAD = '/video_upload';

}

class MyPages {
  static late final  router = GoRouter(
    initialLocation: "/",
    errorBuilder: (context, state) => Container(child: Text("dd"),),
    routes: [
      GoRoute(
          path: MyRoutes.SPLASH,
          builder: (context, state) => SplashScreen()
      ),
      GoRoute(
          path: MyRoutes.VIDEOUPLOAD,
          builder: (context, state) => VideoUploadScreen(state.extra.toString())
      ),
      GoRoute(
          path: MyRoutes.MIDDLE,
          builder: (context, state) => MiddlePage(state.extra.toString())
      ),
      GoRoute(
          path: MyRoutes.VIDEO,
          builder: (context, state) => VideoScreenPage(state.extra.toString())),
      GoRoute(
          path: MyRoutes.Login,
          builder: (context, state) =>  LoginPage(),
      ),
      GoRoute(
          path: MyRoutes.UPLOAD,
          builder: (context, state) => UploadPage(title: 'upload')
      ),
    ],
  );
}