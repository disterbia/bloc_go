
import 'package:Dtalk/app/model/video_stream.dart';
import 'package:Dtalk/app/view/admin_page.dart';
import 'package:Dtalk/app/view/bridge_page.dart';
import 'package:Dtalk/app/view/home_page.dart';
import 'package:Dtalk/app/view/login_page.dart';
import 'package:Dtalk/app/view/splash_page.dart';
import 'package:Dtalk/app/view/take_video_page.dart';
import 'package:Dtalk/app/view/update_profile.dart';
import 'package:Dtalk/app/view/upload_page.dart';
import 'package:Dtalk/app/view/user_profile.dart';
import 'package:Dtalk/app/view/user_video_page.dart';
import 'package:Dtalk/app/view/video_review_page.dart';
import 'package:Dtalk/app/view/video_trim_page.dart';
import 'package:Dtalk/app/view/video_upload.dart';
import 'package:Dtalk/app/view/videostream.dart';
import 'package:flutter/cupertino.dart';

import 'package:go_router/go_router.dart';

class MyRoutes {
  static const SPLASH = '/';
  static const HOME = '/home';
  static const Login = '/login';
  static const UPLOAD = '/upload';
  static const VIDEO = '/video';
  static const FOUR = '/four';
  static const VIDEOUPLOAD = '/video_upload';
  static const TAKEVIDEO = '/take_video';
  static const VIDEOREVIEW = '/video_review';
  static const USERVIDEO = '/user_video';
  static const USERPROFILE ='/user_profile';
  static const BRIDGE ='/bridge';
  static const VIDEOTRIM = "/trim";
  static const ADMIN = "/admin";
  static const UPDATEPROFILE = "/update_profile";
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
          path: MyRoutes.ADMIN,
          builder: (context, state) => AdminPage()
      ),
      GoRoute(
          path: MyRoutes.HOME,
          builder: (context, state) => HomePage()
      ),
      GoRoute(
          path: MyRoutes.UPDATEPROFILE,
          builder: (context, state) {
            Map<String,dynamic> result = state.extra as Map<String,dynamic>;
            return UpdateProfileScreen(result["nickname"],result["intro"]);
          }
          ),
      GoRoute(
          path: MyRoutes.TAKEVIDEO,
          builder: (context, state) => TakeVideoScreen()
      ),
      GoRoute(
          path: MyRoutes.BRIDGE,
          builder: (context, state) => BridgePage()
      ),
      GoRoute(
          path: MyRoutes.VIDEOUPLOAD,
          builder: (context, state) => VideoUploadScreen()
      ),
      GoRoute(
          path: MyRoutes.USERVIDEO,
          builder: (context, state) {
            Map<String,dynamic> result = state.extra as Map<String,dynamic>;
            return UserVideoPage(result["index"],result["image"],result["nickname"]);
          }
      ),
      GoRoute(
          path: MyRoutes.USERPROFILE,
          builder: (context, state) => UserProfile(state.extra as VideoStream,true)
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
          builder: (context, state) =>  LoginPage(false),
      ),
      GoRoute(
          path: MyRoutes.UPLOAD,
          builder: (context, state) => UploadPage(title: 'upload')
      ),
      // GoRoute(
      //     path: MyRoutes.VIDEOTRIM,
      //     builder: (context, state) => VideoTrimmerScreen()
      // ),
    ],
  );
}