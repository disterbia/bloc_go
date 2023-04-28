
import 'package:DTalk/app/view/home_page.dart';
import 'package:DTalk/app/view/login_page.dart';
import 'package:DTalk/app/view/take_video_page.dart';
import 'package:DTalk/app/view/upload_page.dart';
import 'package:DTalk/app/view/user_video_page.dart';
import 'package:DTalk/app/view/video_review_page.dart';
import 'package:DTalk/app/view/video_upload.dart';
import 'package:DTalk/app/view/videostream.dart';
import 'package:flutter/cupertino.dart';

import 'package:go_router/go_router.dart';

class MyRoutes {
  // static const SPLASH = '/';
  static const HOME = '/';
  static const Login = '/login';
  static const UPLOAD = '/upload';
  static const VIDEO = '/video';
  static const FOUR = '/four';
  static const VIDEOUPLOAD = '/video_upload';
  static const TAKEVIDEO = '/take_video';
  static const VIDEOREVIEW = '/video_review';
  static const USERVIDEO = '/user_video';

}

class MyPages {
  static late final  router = GoRouter(
    
    initialLocation: "/",
    errorBuilder: (context, state) => Container(child: Text("dd"),),
    routes: [
      // GoRoute(
      //     path: MyRoutes.SPLASH,
      //     builder: (context, state) => SplashScreen()
      // ),
      GoRoute(
          path: MyRoutes.HOME,
          builder: (context, state) => HomePage()
      ),
      GoRoute(
          path: MyRoutes.TAKEVIDEO,
          builder: (context, state) => TakeVideoScreen()
      ),
      GoRoute(
          path: MyRoutes.VIDEOUPLOAD,
          builder: (context, state) => VideoUploadScreen()
      ),
      GoRoute(
          path: MyRoutes.USERVIDEO,
          builder: (context, state) => UserVideoPage(int.parse(state.extra.toString()))
      ),
      GoRoute(
          path: MyRoutes.VIDEOREVIEW,
          builder: (context, state) => VideoReviewScreen()
      ),
      
      GoRoute(
          path: MyRoutes.VIDEO,
          builder: (context, state) => VideoScreenPage()),
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